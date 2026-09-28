from datetime import date

from pydantic import BaseModel, Field


class BasicInfoRequest(BaseModel):
    full_name: str = Field(
        min_length=2,
        max_length=150,
    )

    phone: str | None = Field(
        default=None,
        min_length=7,
        max_length=20,
    )

    date_of_birth: date | None = None

    gender: str | None = Field(
        default=None,
        max_length=30,
    )

    city: str | None = Field(
        default=None,
        max_length=100,
    )

    pincode: str | None = Field(
        default=None,
        min_length=4,
        max_length=10,
    )


class EducationRequest(BaseModel):
    school_or_college: str | None = Field(
        default=None,
        max_length=200,
    )

    education_level: str | None = Field(
        default=None,
        max_length=100,
    )

    class_or_year: str | None = Field(
        default=None,
        max_length=50,
    )

    study_status: str | None = Field(
        default=None,
        max_length=100,
    )


class StudentProfileResponse(BaseModel):
    id: str
    user_id: str
    full_name: str
    phone: str | None
    date_of_birth: date | None
    gender: str | None
    city: str | None
    pincode: str | None
    school_or_college: str | None
    education_level: str | None
    class_or_year: str | None
    study_status: str | None
    exam_id: str | None