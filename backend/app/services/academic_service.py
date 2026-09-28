from uuid import UUID

from sqlalchemy.orm import Session

from app.models.chapter import Chapter
from app.models.subject import Subject
from app.models.topic import Topic
from app.repositories.academic_repository import (
    get_chapters_by_subject,
    get_subjects_by_exam,
    get_topics_by_chapter,
)


def get_exam_subjects(
    db: Session,
    exam_id: UUID,
) -> list[Subject]:
    return get_subjects_by_exam(
        db=db,
        exam_id=exam_id,
    )


def get_subject_chapters(
    db: Session,
    subject_id: UUID,
) -> list[Chapter]:
    return get_chapters_by_subject(
        db=db,
        subject_id=subject_id,
    )


def get_chapter_topics(
    db: Session,
    chapter_id: UUID,
) -> list[Topic]:
    return get_topics_by_chapter(
        db=db,
        chapter_id=chapter_id,
    )