from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.schemas.auth import (
    LoginRequest,
    LoginResponse,
    RegisterRequest,
    RegisterResponse,
)
from app.schemas.email_verification import (
    ResendOtpRequest,
    ResendOtpResponse,
    VerifyEmailRequest,
    VerifyEmailResponse,
)
from app.services.auth_service import login_student, register_student
from app.services.email_verification_service import (
    resend_email_otp,
    verify_email_otp,
)

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)


@router.post(
    "/register",
    response_model=RegisterResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(
    request: RegisterRequest,
    db: Session = Depends(get_db),
):
    user = register_student(
        db=db,
        request=request,
    )

    return RegisterResponse(
        id=user.id,
        email=user.email,
        full_name=request.full_name,
        role=user.role,
    )


@router.post(
    "/verify-email",
    response_model=VerifyEmailResponse,
    status_code=status.HTTP_200_OK,
)
def verify_email(
    request: VerifyEmailRequest,
    db: Session = Depends(get_db),
):
    user = verify_email_otp(
        db=db,
        request=request,
    )

    return VerifyEmailResponse(
        user_id=user.id,
        email=user.email,
        email_verified=user.email_verified,
        message="Email verified successfully.",
    )


@router.post(
    "/resend-otp",
    response_model=ResendOtpResponse,
    status_code=status.HTTP_200_OK,
)
def resend_otp(
    request: ResendOtpRequest,
    db: Session = Depends(get_db),
):
    resend_email_otp(
        db=db,
        request=request,
    )

    return ResendOtpResponse(
        message="A new verification code has been generated.",
    )


@router.post(
    "/login",
    response_model=LoginResponse,
    status_code=status.HTTP_200_OK,
)
def login(
    request: LoginRequest,
    db: Session = Depends(get_db),
):
    access_token = login_student(
        db=db,
        request=request,
    )

    return LoginResponse(
        access_token=access_token,
        token_type="bearer",
    )