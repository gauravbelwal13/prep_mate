from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user
from app.db.database import get_db
from app.models.test_attempt import TestAttempt
from app.models.user import User
from app.schemas.attempt import (
    AttemptResultResponse,
    StartAttemptResponse,
    SubmitAttemptRequest,
)
from app.services.attempt_service import (
    start_test_attempt,
    submit_test_attempt,
)


router = APIRouter(
    prefix="",
    tags=["Attempts"],
)


@router.post(
    "/tests/{test_id}/attempts",
    response_model=StartAttemptResponse,
    status_code=status.HTTP_201_CREATED,
)
def start_attempt(
    test_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> StartAttemptResponse:
    attempt = start_test_attempt(
        db=db,
        test_id=test_id,
        student_id=current_user.id,
    )

    return StartAttemptResponse(
        id=attempt.id,
        test_id=attempt.test_id,
        student_id=attempt.student_id,
        started_at=attempt.started_at,
        total_questions=attempt.total_questions,
        status=(
            "submitted"
            if attempt.submitted_at is not None
            else "in_progress"
        ),
    )


@router.post(
    "/attempts/{attempt_id}/submit",
    response_model=AttemptResultResponse,
    status_code=status.HTTP_200_OK,
)
def submit_attempt(
    attempt_id: UUID,
    request: SubmitAttemptRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> AttemptResultResponse:
    attempt = submit_test_attempt(
        db=db,
        attempt_id=attempt_id,
        student_id=current_user.id,
        answers=[
            {
                "question_id": answer.question_id,
                "selected_option_id": answer.selected_option_id,
            }
            for answer in request.answers
        ],
    )

    return AttemptResultResponse(
        id=attempt.id,
        test_id=attempt.test_id,
        student_id=attempt.student_id,
        started_at=attempt.started_at,
        submitted_at=attempt.submitted_at,
        total_questions=attempt.total_questions,
        attempted_questions=attempt.attempted_questions,
        correct_answers=attempt.correct_answers,
        incorrect_answers=attempt.incorrect_answers,
        unanswered_questions=attempt.unanswered_questions,
        score=float(attempt.score),
        accuracy=float(attempt.accuracy),
    )


@router.get(
    "/attempts/{attempt_id}",
    response_model=AttemptResultResponse,
    status_code=status.HTTP_200_OK,
)
def get_attempt_result(
    attempt_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> AttemptResultResponse:
    attempt = (
        db.execute(
            select(TestAttempt)
            .where(
                TestAttempt.id == attempt_id,
                TestAttempt.student_id == current_user.id,
            )
        )
        .scalar_one_or_none()
    )

    if attempt is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Attempt not found.",
        )

    if attempt.submitted_at is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This attempt has not been submitted yet.",
        )

    return AttemptResultResponse(
        id=attempt.id,
        test_id=attempt.test_id,
        student_id=attempt.student_id,
        started_at=attempt.started_at,
        submitted_at=attempt.submitted_at,
        total_questions=attempt.total_questions,
        attempted_questions=attempt.attempted_questions,
        correct_answers=attempt.correct_answers,
        incorrect_answers=attempt.incorrect_answers,
        unanswered_questions=attempt.unanswered_questions,
        score=float(attempt.score),
        accuracy=float(attempt.accuracy),
    )