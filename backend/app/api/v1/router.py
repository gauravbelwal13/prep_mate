from fastapi import APIRouter

from app.api.v1.academic import router as academic_router
from app.api.v1.attempt import router as attempt_router
from app.api.v1.auth import router as auth_router
from app.api.v1.dashboard import router as dashboard_router
from app.api.v1.exams import router as exams_router
from app.api.v1.me import router as me_router
from app.api.v1.questions import router as questions_router
from app.api.v1.student_profile import router as student_profile_router
from app.api.v1.system import router as system_router
from app.api.v1.tests import router as tests_router


api_router = APIRouter(
    prefix="/api/v1",
)


api_router.include_router(academic_router)
api_router.include_router(attempt_router)
api_router.include_router(auth_router)
api_router.include_router(dashboard_router)
api_router.include_router(exams_router)
api_router.include_router(me_router)
api_router.include_router(questions_router)
api_router.include_router(student_profile_router)
api_router.include_router(system_router)
api_router.include_router(tests_router)