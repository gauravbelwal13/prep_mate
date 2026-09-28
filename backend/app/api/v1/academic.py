from uuid import UUID

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.schemas.academic import (
    ChapterResponse,
    SubjectResponse,
    TopicResponse,
)
from app.services.academic_service import (
    get_chapter_topics,
    get_exam_subjects,
    get_subject_chapters,
)


router = APIRouter(
    prefix="/academic",
    tags=["Academic"],
)


@router.get(
    "/exams/{exam_id}/subjects",
    response_model=list[SubjectResponse],
    status_code=status.HTTP_200_OK,
)
def list_exam_subjects(
    exam_id: UUID,
    db: Session = Depends(get_db),
) -> list[SubjectResponse]:
    subjects = get_exam_subjects(
        db=db,
        exam_id=exam_id,
    )

    return [
        SubjectResponse(
            id=subject.id,
            name=subject.name,
            description=subject.description,
        )
        for subject in subjects
    ]


@router.get(
    "/subjects/{subject_id}/chapters",
    response_model=list[ChapterResponse],
    status_code=status.HTTP_200_OK,
)
def list_subject_chapters(
    subject_id: UUID,
    db: Session = Depends(get_db),
) -> list[ChapterResponse]:
    chapters = get_subject_chapters(
        db=db,
        subject_id=subject_id,
    )

    return [
        ChapterResponse(
            id=chapter.id,
            subject_id=chapter.subject_id,
            name=chapter.name,
            description=chapter.description,
            sort_order=chapter.sort_order,
        )
        for chapter in chapters
    ]


@router.get(
    "/chapters/{chapter_id}/topics",
    response_model=list[TopicResponse],
    status_code=status.HTTP_200_OK,
)
def list_chapter_topics(
    chapter_id: UUID,
    db: Session = Depends(get_db),
) -> list[TopicResponse]:
    topics = get_chapter_topics(
        db=db,
        chapter_id=chapter_id,
    )

    return [
        TopicResponse(
            id=topic.id,
            chapter_id=topic.chapter_id,
            name=topic.name,
            description=topic.description,
            sort_order=topic.sort_order,
        )
        for topic in topics
    ]