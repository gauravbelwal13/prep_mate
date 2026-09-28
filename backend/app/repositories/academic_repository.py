from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.chapter import Chapter
from app.models.exam_subject import ExamSubject
from app.models.subject import Subject
from app.models.topic import Topic


def get_subjects_by_exam(
    db: Session,
    exam_id: UUID,
) -> list[Subject]:
    statement = (
        select(Subject)
        .join(
            ExamSubject,
            ExamSubject.subject_id == Subject.id,
        )
        .where(
            ExamSubject.exam_id == exam_id,
            Subject.is_active.is_(True),
        )
        .order_by(Subject.name)
    )

    return list(
        db.execute(statement)
        .scalars()
        .all()
    )


def get_chapters_by_subject(
    db: Session,
    subject_id: UUID,
) -> list[Chapter]:
    statement = (
        select(Chapter)
        .where(
            Chapter.subject_id == subject_id,
            Chapter.is_active.is_(True),
        )
        .order_by(Chapter.sort_order, Chapter.name)
    )

    return list(
        db.execute(statement)
        .scalars()
        .all()
    )


def get_topics_by_chapter(
    db: Session,
    chapter_id: UUID,
) -> list[Topic]:
    statement = (
        select(Topic)
        .where(
            Topic.chapter_id == chapter_id,
            Topic.is_active.is_(True),
        )
        .order_by(Topic.sort_order, Topic.name)
    )

    return list(
        db.execute(statement)
        .scalars()
        .all()
    )