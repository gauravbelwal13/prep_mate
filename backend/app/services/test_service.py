from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.exam import Exam
from app.models.question import Question
from app.models.question_exam import QuestionExam
from app.models.test import Test
from app.models.test_question import TestQuestion
from app.repositories.test_repository import (
    add_test_question,
    create_test,
    get_test_by_id,
)


def create_test_from_questions(
    db: Session,
    exam_id: UUID,
    created_by: UUID,
    title: str,
    description: str | None,
    question_ids: list[UUID],
    duration_minutes: int,
) -> Test:
    if not question_ids:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="At least one question is required.",
        )

    if len(question_ids) != len(set(question_ids)):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Duplicate question IDs are not allowed.",
        )

    exam = db.execute(
        select(Exam).where(
            Exam.id == exam_id,
            Exam.is_active.is_(True),
        )
    ).scalar_one_or_none()

    if exam is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Exam not found.",
        )

    question_statement = (
        select(Question, QuestionExam)
        .join(
            QuestionExam,
            QuestionExam.question_id == Question.id,
        )
        .where(
            Question.id.in_(question_ids),
            QuestionExam.exam_id == exam_id,
            QuestionExam.is_active.is_(True),
            Question.status == "published",
        )
    )

    rows = db.execute(question_statement).all()

    question_exam_map = {
        question.id: question_exam
        for question, question_exam in rows
    }

    missing_question_ids = [
        question_id
        for question_id in question_ids
        if question_id not in question_exam_map
    ]

    if missing_question_ids:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "One or more questions are invalid for the selected exam."
            ),
        )

    test = Test(
        exam_id=exam_id,
        created_by=created_by,
        title=title,
        description=description,
        total_questions=len(question_ids),
        duration_minutes=duration_minutes,
        status="published",
    )

    try:
        create_test(
            db=db,
            test=test,
        )

        for question_order, question_id in enumerate(
            question_ids,
            start=1,
        ):
            question_exam = question_exam_map[question_id]

            test_question = TestQuestion(
                test_id=test.id,
                question_id=question_id,
                question_order=question_order,

                # Snapshot exam-specific scoring rules.
                marks=question_exam.marks,
                negative_marks=question_exam.negative_marks,
            )

            add_test_question(
                db=db,
                test_question=test_question,
            )

        db.commit()
        db.refresh(test)

        return test

    except HTTPException:
        db.rollback()
        raise

    except Exception:
        db.rollback()
        raise


def get_test(
    db: Session,
    test_id: UUID,
) -> Test:
    test = get_test_by_id(
        db=db,
        test_id=test_id,
    )

    if test is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Test not found.",
        )

    return test