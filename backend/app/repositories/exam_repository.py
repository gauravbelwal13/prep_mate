from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.exam import Exam


def get_active_exams(
    db: Session,
) -> list[Exam]:
    statement = (
        select(Exam)
        .where(Exam.is_active.is_(True))
        .order_by(Exam.name)
    )

    return list(
        db.execute(statement).scalars().all()
    )