from datetime import datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.email_verification import EmailVerification


def create_email_verification(
    db: Session,
    user_id: UUID,
    otp_code: str,
    expires_at: datetime,
) -> EmailVerification:
    verification = EmailVerification(
        user_id=user_id,
        otp_code=otp_code,
        expires_at=expires_at,
    )

    db.add(verification)
    db.flush()

    return verification


def get_latest_pending_verification(
    db: Session,
    user_id: UUID,
) -> EmailVerification | None:
    return db.execute(
        select(EmailVerification)
        .where(
            EmailVerification.user_id == user_id,
            EmailVerification.verified_at.is_(None),
        )
        .order_by(EmailVerification.created_at.desc())
    ).scalars().first()


def mark_verification_complete(
    verification: EmailVerification,
    verified_at: datetime,
) -> EmailVerification:
    verification.verified_at = verified_at

    return verification