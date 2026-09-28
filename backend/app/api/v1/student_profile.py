from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_user
from app.db.database import get_db
from app.models.user import User
from app.schemas.exam import ExamSelectionRequest
from app.schemas.student_profile import (
    BasicInfoRequest,
    EducationRequest,
    StudentProfileResponse,
)
from app.services.exam_service import update_student_exam
from app.services.student_profile_service import (
    get_student_profile,
    update_student_basic_info,
    update_student_education,
)


router = APIRouter(
    prefix="/students/profile",
    tags=["Student Profile"],
)


def profile_to_response(profile) -> StudentProfileResponse:
    return StudentProfileResponse(
        id=str(profile.id),
        user_id=str(profile.user_id),
        full_name=profile.full_name,
        phone=profile.phone,
        date_of_birth=profile.date_of_birth,
        gender=profile.gender,
        city=profile.city,
        pincode=profile.pincode,
        school_or_college=profile.school_or_college,
        education_level=profile.education_level,
        class_or_year=profile.class_or_year,
        study_status=profile.study_status,
        exam_id=str(profile.exam_id) if profile.exam_id else None,
    )


@router.get(
    "",
    response_model=StudentProfileResponse,
    status_code=status.HTTP_200_OK,
)
def get_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> StudentProfileResponse:
    profile = get_student_profile(
        db=db,
        user_id=current_user.id,
    )

    return profile_to_response(profile)


@router.patch(
    "/basic-info",
    response_model=StudentProfileResponse,
    status_code=status.HTTP_200_OK,
)
def update_basic_info(
    request: BasicInfoRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> StudentProfileResponse:
    profile = update_student_basic_info(
        db=db,
        user_id=current_user.id,
        request=request,
    )

    return profile_to_response(profile)


@router.patch(
    "/education",
    response_model=StudentProfileResponse,
    status_code=status.HTTP_200_OK,
)
def update_education(
    request: EducationRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> StudentProfileResponse:
    profile = update_student_education(
        db=db,
        user_id=current_user.id,
        request=request,
    )

    return profile_to_response(profile)


@router.patch(
    "/exam",
    response_model=StudentProfileResponse,
    status_code=status.HTTP_200_OK,
)
def update_exam(
    request: ExamSelectionRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> StudentProfileResponse:
    profile = update_student_exam(
        db=db,
        user_id=current_user.id,
        exam_id=request.exam_id,
    )

    return profile_to_response(profile)