from datetime import datetime, timedelta, timezone

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.user import User
from app.repositories.email_verification_repository import (
    create_email_verification,
    get_latest_pending_verification,
    mark_verification_complete,
)
from app.repositories.user_repository import get_user_by_email
from app.schemas.email_verification import (
    ResendOtpRequest,
    VerifyEmailRequest,
)


OTP_CODE = "123456"
OTP_EXPIRY_MINUTES = 10


def create_email_otp(
    db: Session,
    user: User,
) -> None:
    expires_at = datetime.now(timezone.utc) + timedelta(
        minutes=OTP_EXPIRY_MINUTES
    )

    create_email_verification(
        db=db,
        user_id=user.id,
        otp_code=OTP_CODE,
        expires_at=expires_at,
    )


def verify_email_otp(
    db: Session,
    request: VerifyEmailRequest,
) -> User:
    email = request.email.lower()

    user = get_user_by_email(
        db=db,
        email=email,
    )

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Account not found.",
        )

    if user.email_verified:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email is already verified.",
        )

    verification = get_latest_pending_verification(
        db=db,
        user_id=user.id,
    )

    if verification is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No pending verification code found.",
        )

    now = datetime.now(timezone.utc)

    if now > verification.expires_at:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Verification code has expired.",
        )

    if request.otp_code != verification.otp_code:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid verification code.",
        )

    user.email_verified = True

    mark_verification_complete(
        verification=verification,
        verified_at=now,
    )

    db.commit()
    db.refresh(user)

    return user


def resend_email_otp(
    db: Session,
    request: ResendOtpRequest,
) -> None:
    email = request.email.lower()

    user = get_user_by_email(
        db=db,
        email=email,
    )

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Account not found.",
        )

    if user.email_verified:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email is already verified.",
        )

    create_email_otp(
        db=db,
        user=user,
    )

    db.commit()