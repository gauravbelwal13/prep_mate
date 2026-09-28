from datetime import datetime, timezone
from decimal import Decimal
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.models.question import Question
from app.models.test import Test
from app.models.test_answer import TestAnswer
from app.models.test_attempt import TestAttempt
from app.models.test_question import TestQuestion


def start_test_attempt(
    db: Session,
    test_id: UUID,
    student_id: UUID,
) -> TestAttempt:
    test = (
        db.execute(
            select(Test)
            .where(
                Test.id == test_id,
                Test.status == "published",
            )
        )
        .scalar_one_or_none()
    )

    if test is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Test not found.",
        )

    existing_attempt = (
        db.execute(
            select(TestAttempt)
            .where(
                TestAttempt.test_id == test_id,
                TestAttempt.student_id == student_id,
                TestAttempt.submitted_at.is_(None),
            )
            .order_by(TestAttempt.started_at.desc())
            .limit(1)
        )
        .scalar_one_or_none()
    )

    if existing_attempt is not None:
        return existing_attempt

    if test.total_questions <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This test has no questions.",
        )

    attempt = TestAttempt(
        test_id=test_id,
        student_id=student_id,
        total_questions=test.total_questions,
        attempted_questions=0,
        correct_answers=0,
        incorrect_answers=0,
        unanswered_questions=test.total_questions,
        score=Decimal("0.00"),
        accuracy=Decimal("0.00"),
    )

    try:
        db.add(attempt)
        db.commit()
        db.refresh(attempt)

        return attempt

    except Exception:
        db.rollback()
        raise


def submit_test_attempt(
    db: Session,
    attempt_id: UUID,
    student_id: UUID,
    answers: list[dict],
) -> TestAttempt:
    attempt = (
        db.execute(
            select(TestAttempt)
            .options(
                joinedload(TestAttempt.test)
                .joinedload(Test.test_questions)
                .joinedload(TestQuestion.question)
                .joinedload(Question.options),
            )
            .where(
                TestAttempt.id == attempt_id,
                TestAttempt.student_id == student_id,
            )
        )
        .unique()
        .scalar_one_or_none()
    )

    if attempt is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Attempt not found.",
        )

    if attempt.submitted_at is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This attempt has already been submitted.",
        )

    test_questions = attempt.test.test_questions

    if not test_questions:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This test has no questions.",
        )

    answer_map = {
        answer["question_id"]: answer.get("selected_option_id")
        for answer in answers
    }

    if len(answer_map) != len(answers):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Duplicate question answers are not allowed.",
        )

    test_question_map = {
        test_question.question_id: test_question
        for test_question in test_questions
    }

    invalid_questions = [
        question_id
        for question_id in answer_map
        if question_id not in test_question_map
    ]

    if invalid_questions:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Answer contains a question not belonging to this test.",
        )

    # A submitted attempt should not already have persisted answers.
    # This also makes accidental double-processing much harder.
    existing_answer_count = (
        db.execute(
            select(TestAnswer.id)
            .where(TestAnswer.attempt_id == attempt.id)
            .limit(1)
        )
        .first()
    )

    if existing_answer_count is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Answers have already been recorded for this attempt.",
        )

    correct_answers = 0
    incorrect_answers = 0
    unanswered_questions = 0
    score = Decimal("0.00")

    answer_records: list[TestAnswer] = []

    for test_question in sorted(
        test_questions,
        key=lambda item: item.question_order,
    ):
        question_id = test_question.question_id
        selected_option_id = answer_map.get(question_id)

        question = test_question.question

        if selected_option_id is None:
            unanswered_questions += 1

            answer_records.append(
                TestAnswer(
                    attempt_id=attempt.id,
                    question_id=question_id,
                    selected_option_id=None,
                    question_order=test_question.question_order,
                    is_correct=False,
                    is_answered=False,
                    marks_awarded=Decimal("0.00"),
                )
            )

            continue

        selected_option = next(
            (
                option
                for option in question.options
                if option.id == selected_option_id
            ),
            None,
        )

        if selected_option is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    f"Selected option does not belong to "
                    f"question {question_id}."
                ),
            )

        is_correct = selected_option.is_correct

        if is_correct:
            correct_answers += 1
            marks_awarded = Decimal(test_question.marks)
        else:
            incorrect_answers += 1
            marks_awarded = -Decimal(test_question.negative_marks)

        score += marks_awarded

        answer_records.append(
            TestAnswer(
                attempt_id=attempt.id,
                question_id=question_id,
                selected_option_id=selected_option_id,
                question_order=test_question.question_order,
                is_correct=is_correct,
                is_answered=True,
                marks_awarded=marks_awarded,
            )
        )

    attempted_questions = correct_answers + incorrect_answers

    # Accuracy measures the quality of answered questions.
    # Unanswered questions are reported separately and do not
    # reduce accuracy.
    accuracy = (
        (
            Decimal(correct_answers)
            / Decimal(attempted_questions)
        )
        * Decimal("100")
        if attempted_questions > 0
        else Decimal("0")
    )

    attempt.attempted_questions = attempted_questions
    attempt.correct_answers = correct_answers
    attempt.incorrect_answers = incorrect_answers
    attempt.unanswered_questions = unanswered_questions
    attempt.score = score
    attempt.accuracy = accuracy.quantize(Decimal("0.01"))
    attempt.submitted_at = datetime.now(timezone.utc)

    try:
        db.add_all(answer_records)
        db.commit()
        db.refresh(attempt)

        return attempt

    except Exception:
        db.rollback()
        raise