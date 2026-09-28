from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.student_profile import StudentProfile
from app.repositories.student_profile_repository import (
    get_student_profile_by_user_id,
    update_basic_info,
    update_education,
)
from app.schemas.student_profile import (
    BasicInfoRequest,
    EducationRequest,
)


def get_student_profile(
    db: Session,
    user_id: UUID,
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

    return profile


def update_student_basic_info(
    db: Session,
    user_id: UUID,
    request: BasicInfoRequest,
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

    try:
        profile = update_basic_info(
            db=db,
            profile=profile,
            full_name=request.full_name,
            phone=request.phone,
            date_of_birth=request.date_of_birth,
            gender=request.gender,
            city=request.city,
            pincode=request.pincode,
        )

        db.commit()
        db.refresh(profile)

        return profile

    except Exception:
        db.rollback()
        raise


def update_student_education(
    db: Session,
    user_id: UUID,
    request: EducationRequest,
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

    try:
        profile = update_education(
            db=db,
            profile=profile,
            school_or_college=request.school_or_college,
            education_level=request.education_level,
            class_or_year=request.class_or_year,
            study_status=request.study_status,
        )

        db.commit()
        db.refresh(profile)

        return profile

    except Exception:
        db.rollback()
        raise