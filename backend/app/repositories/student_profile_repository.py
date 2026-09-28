from datetime import date
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.student_profile import StudentProfile


def create_student_profile(
    db: Session,
    user_id: UUID,
    full_name: str,
) -> StudentProfile:
    profile = StudentProfile(
        user_id=user_id,
        full_name=full_name,
    )

    db.add(profile)
    db.flush()

    return profile


def get_student_profile_by_user_id(
    db: Session,
    user_id: UUID,
) -> StudentProfile | None:
    statement = select(StudentProfile).where(
        StudentProfile.user_id == user_id,
    )

    return db.execute(statement).scalar_one_or_none()


def update_basic_info(
    db: Session,
    profile: StudentProfile,
    full_name: str,
    phone: str | None,
    date_of_birth: date | None,
    gender: str | None,
    city: str | None,
    pincode: str | None,
) -> StudentProfile:
    profile.full_name = full_name
    profile.phone = phone
    profile.date_of_birth = date_of_birth
    profile.gender = gender
    profile.city = city
    profile.pincode = pincode

    db.flush()

    return profile


def update_education(
    db: Session,
    profile: StudentProfile,
    school_or_college: str | None,
    education_level: str | None,
    class_or_year: str | None,
    study_status: str | None,
) -> StudentProfile:
    profile.school_or_college = school_or_college
    profile.education_level = education_level
    profile.class_or_year = class_or_year
    profile.study_status = study_status

    db.flush()

    return profile


def update_exam(
    db: Session,
    profile: StudentProfile,
    exam_id: UUID,
) -> StudentProfile:
    profile.exam_id = exam_id

    db.flush()

    return profile