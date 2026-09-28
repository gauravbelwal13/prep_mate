from app.db.database import SessionLocal
from app.services.auth_service import register_student
from app.schemas.auth import RegisterRequest


def test_register_student() -> None:
    db = SessionLocal()

    try:
        request = RegisterRequest(
            email="student_test_3@example.com",
            password="TestPassword123!",
            full_name="Test Student",
        )

        user = register_student(
            db=db,
            request=request,
        )

        print(f"User ID: {user.id}")
        print(f"Email: {user.email}")
        print(f"Role: {user.role}")
        print(f"Active: {user.is_active}")

    finally:
        db.close()