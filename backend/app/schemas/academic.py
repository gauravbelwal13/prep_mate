from uuid import UUID

from pydantic import BaseModel


class SubjectResponse(BaseModel):
    id: UUID
    name: str
    description: str | None


class ChapterResponse(BaseModel):
    id: UUID
    subject_id: UUID
    name: str
    description: str | None
    sort_order: int


class TopicResponse(BaseModel):
    id: UUID
    chapter_id: UUID
    name: str
    description: str | None
    sort_order: int