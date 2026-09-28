from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.jwt import create_access_token
from app.core.security import hash_password, verify_password
from app.models.user import User
from app.repositories.student_profile_repository import (
    create_student_profile,
)
from app.repositories.user_repository import (
    create_user,
    get_user_by_email,
)
from app.schemas.auth import LoginRequest, RegisterRequest


def register_student(
    db: Session,
    request: RegisterRequest,
) -> User:
    email = request.email.lower()

    existing_user = get_user_by_email(
        db=db,
        email=email,
    )

    if existing_user is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists.",
        )

    try:
        password_hash = hash_password(request.password)

        user = create_user(
            db=db,
            email=email,
            password_hash=password_hash,
            role="student",
        )

        create_student_profile(
            db=db,
            user_id=user.id,
            full_name=request.full_name,
        )

        db.commit()
        db.refresh(user)

        return user

    except Exception:
        db.rollback()
        raise


def login_student(
    db: Session,
    request: LoginRequest,
) -> str:
    email = request.email.lower()

    user = get_user_by_email(
        db=db,
        email=email,
    )

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )

    if not verify_password(
        request.password,
        user.password_hash,
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive.",
        )

    return create_access_token(
        user_id=user.id,
    )