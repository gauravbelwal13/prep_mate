from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.question import Question
from app.repositories.question_repository import (
    get_correct_question_option,
    get_published_question,
    get_question_exam,
    get_question_option,
    get_questions,
)


ALLOWED_DIFFICULTIES = {
    "easy",
    "medium",
    "hard",
}


def get_question_bank(
    db: Session,
    exam_id: UUID,
    subject_id: UUID | None = None,
    chapter_id: UUID | None = None,
    topic_id: UUID | None = None,
    difficulty: str | None = None,
    limit: int = 20,
) -> list[Question]:
    if difficulty is not None:
        difficulty = difficulty.lower()

        if difficulty not in ALLOWED_DIFFICULTIES:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    "Invalid difficulty. "
                    "Allowed values: easy, medium, hard."
                ),
            )

    if limit < 1 or limit > 100:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Limit must be between 1 and 100.",
        )

    return get_questions(
        db=db,
        exam_id=exam_id,
        subject_id=subject_id,
        chapter_id=chapter_id,
        topic_id=topic_id,
        difficulty=difficulty,
        limit=limit,
    )


def check_question_answer(
    db: Session,
    question_id: UUID,
    exam_id: UUID,
    selected_option_id: UUID,
) -> dict:
    question = get_published_question(
        db=db,
        question_id=question_id,
    )

    if question is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Question not found.",
        )

    question_exam = get_question_exam(
        db=db,
        question_id=question_id,
        exam_id=exam_id,
    )

    if question_exam is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Question is not available for this exam.",
        )

    selected_option = get_question_option(
        db=db,
        question_id=question_id,
        option_id=selected_option_id,
    )

    if selected_option is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Selected option does not belong to this question.",
        )

    correct_option = get_correct_question_option(
        db=db,
        question_id=question_id,
    )

    if correct_option is None:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Question does not have a valid correct answer.",
        )

    is_correct = selected_option.id == correct_option.id

    marks_awarded = (
        question_exam.marks
        if is_correct
        else -question_exam.negative_marks
    )

    return {
        "question_id": question.id,
        "selected_option_id": selected_option.id,
        "correct_option_id": correct_option.id,
        "is_correct": is_correct,
        "marks_awarded": marks_awarded,
        "explanation": question.explanation,
    }