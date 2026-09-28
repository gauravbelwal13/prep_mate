from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.schemas.exam import ExamResponse
from app.services.exam_service import get_exams


router = APIRouter(
    prefix="/exams",
    tags=["Exams"],
)


@router.get(
    "",
    response_model=list[ExamResponse],
    status_code=status.HTTP_200_OK,
)
def list_exams(
    db: Session = Depends(get_db),
) -> list[ExamResponse]:
    exams = get_exams(db=db)

    return [
        ExamResponse(
            id=exam.id,
            code=exam.code,
            name=exam.name,
            description=exam.description,
        )
        for exam in exams
    ]