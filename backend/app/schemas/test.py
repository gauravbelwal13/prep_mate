from uuid import UUID

from pydantic import BaseModel, Field


class CreateTestRequest(BaseModel):
    exam_id: UUID
    title: str = Field(min_length=1, max_length=200)
    description: str | None = None
    question_ids: list[UUID] = Field(min_length=1, max_length=100)
    duration_minutes: int = Field(gt=0, le=300)


class TestResponse(BaseModel):
    id: UUID
    exam_id: UUID
    exam_name: str
    title: str
    description: str | None
    total_questions: int
    duration_minutes: int
    status: str


class TestQuestionResponse(BaseModel):
    question_id: UUID
    question_order: int
    question_text: str
    question_type: str
    subject_name: str
    chapter_name: str
    topic_name: str
    explanation: str | None
    image_url: str | None
    difficulty: str
    marks: int
    negative_marks: int
    options: list["TestQuestionOptionResponse"]


class TestQuestionOptionResponse(BaseModel):
    id: UUID
    option_order: int
    option_text: str