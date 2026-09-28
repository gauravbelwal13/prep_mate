from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.exam import Exam
from app.models.student_profile import StudentProfile
from app.repositories.exam_repository import get_active_exams
from app.repositories.student_profile_repository import (
    get_student_profile_by_user_id,
    update_exam,
)


def get_exams(
    db: Session,
) -> list[Exam]:
    return get_active_exams(db=db)


def update_student_exam(
    db: Session,
    user_id: UUID,
    exam_id: UUID,
) -> StudentProfile:
    profile = get_student_profile_by_user_id(
        db=db,
        user_id=user_id,
    )

    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student profile not found.",
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
            detail="Exam not found or inactive.",
        )

    try:
        profile = update_exam(
            db=db,
            profile=profile,
            exam_id=exam.id,
        )

        db.commit()
        db.refresh(profile)

        return profile

    except Exception:
        db.rollback()
        raise