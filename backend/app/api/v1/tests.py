from uuid import UUID

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user
from app.db.database import get_db
from app.models.test import Test
from app.models.user import User
from app.schemas.test import (
    CreateTestRequest,
    TestQuestionOptionResponse,
    TestQuestionResponse,
    TestResponse,
)
from app.services.test_service import (
    create_test_from_questions,
    get_test,
)


router = APIRouter(
    prefix="/tests",
    tags=["Tests"],
)


@router.post(
    "",
    response_model=TestResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_test(
    request: CreateTestRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TestResponse:
    test = create_test_from_questions(
        db=db,
        exam_id=request.exam_id,
        created_by=current_user.id,
        title=request.title,
        description=request.description,
        question_ids=request.question_ids,
        duration_minutes=request.duration_minutes,
    )

    return TestResponse(
        id=test.id,
        exam_id=test.exam_id,
        exam_name=test.exam.name,
        title=test.title,
        description=test.description,
        total_questions=test.total_questions,
        duration_minutes=test.duration_minutes,
        status=test.status,
    )


@router.get(
    "/{test_id}",
    response_model=TestResponse,
    status_code=status.HTTP_200_OK,
)
def get_test_details(
    test_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TestResponse:
    test = get_test(
        db=db,
        test_id=test_id,
    )

    return TestResponse(
        id=test.id,
        exam_id=test.exam_id,
        exam_name=test.exam.name,
        title=test.title,
        description=test.description,
        total_questions=test.total_questions,
        duration_minutes=test.duration_minutes,
        status=test.status,
    )


@router.get(
    "/{test_id}/questions",
    response_model=list[TestQuestionResponse],
    status_code=status.HTTP_200_OK,
)
def get_test_questions(
    test_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[TestQuestionResponse]:
    test = get_test(
        db=db,
        test_id=test_id,
    )

    responses: list[TestQuestionResponse] = []

    for test_question in test.test_questions:
        question = test_question.question
        topic = question.topic
        chapter = topic.chapter
        subject = chapter.subject

        question_exam = next(
            (
                mapping
                for mapping in question.question_exams
                if mapping.exam_id == test.exam_id
                and mapping.is_active
            ),
            None,
        )

        if question_exam is None:
            continue

        responses.append(
            TestQuestionResponse(
                question_id=question.id,
                question_order=test_question.question_order,
                question_text=question.question_text,
                question_type=question.question_type,
                subject_name=subject.name,
                chapter_name=chapter.name,
                topic_name=topic.name,
                explanation=None,
                image_url=question.image_url,
                difficulty=question_exam.difficulty,
                marks=question_exam.marks,
                negative_marks=question_exam.negative_marks,
                options=[
                    TestQuestionOptionResponse(
                        id=option.id,
                        option_order=option.option_order,
                        option_text=option.option_text,
                    )
                    for option in question.options
                ],
            )
        )

    return responses