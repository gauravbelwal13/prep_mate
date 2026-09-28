from uuid import UUID

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user
from app.db.database import get_db
from app.models.user import User
from app.schemas.question import (
    CheckAnswerRequest,
    CheckAnswerResponse,
    QuestionResponse,
)
from app.services.question_service import (
    check_question_answer,
    get_question_bank,
)


router = APIRouter(
    prefix="/questions",
    tags=["Questions"],
)


@router.get(
    "",
    response_model=list[QuestionResponse],
    status_code=status.HTTP_200_OK,
)
def get_questions(
    exam_id: UUID,
    subject_id: UUID | None = None,
    chapter_id: UUID | None = None,
    topic_id: UUID | None = None,
    difficulty: str | None = None,
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[QuestionResponse]:
    questions = get_question_bank(
        db=db,
        exam_id=exam_id,
        subject_id=subject_id,
        chapter_id=chapter_id,
        topic_id=topic_id,
        difficulty=difficulty,
        limit=limit,
    )

    responses: list[QuestionResponse] = []

    for question in questions:
        topic = question.topic
        chapter = topic.chapter
        subject = chapter.subject

        question_exam = next(
            (
                mapping
                for mapping in question.question_exams
                if mapping.exam_id == exam_id
                and mapping.is_active
            ),
            None,
        )

        if question_exam is None:
            continue

        responses.append(
            QuestionResponse(
                id=question.id,
                subject_id=subject.id,
                subject_name=subject.name,
                chapter_id=chapter.id,
                chapter_name=chapter.name,
                topic_id=topic.id,
                topic_name=topic.name,
                question_text=question.question_text,
                explanation=question.explanation,
                question_type=question.question_type,
                image_url=question.image_url,
                difficulty=question_exam.difficulty,
                marks=question_exam.marks,
                negative_marks=question_exam.negative_marks,
                options=[
                    {
                        "id": option.id,
                        "option_order": option.option_order,
                        "option_text": option.option_text,
                    }
                    for option in question.options
                ],
            )
        )

    return responses


@router.post(
    "/{question_id}/check-answer",
    response_model=CheckAnswerResponse,
    status_code=status.HTTP_200_OK,
)
def check_answer(
    question_id: UUID,
    request: CheckAnswerRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CheckAnswerResponse:
    result = check_question_answer(
        db=db,
        question_id=question_id,
        exam_id=request.exam_id,
        selected_option_id=request.selected_option_id,
    )

    return CheckAnswerResponse(**result)