from uuid import UUID

from pydantic import BaseModel


class QuestionOptionResponse(BaseModel):
    id: UUID
    option_order: int
    option_text: str


class QuestionResponse(BaseModel):
    id: UUID
    subject_id: UUID
    subject_name: str
    chapter_id: UUID
    chapter_name: str
    topic_id: UUID
    topic_name: str

    question_text: str
    explanation: str | None
    question_type: str
    image_url: str | None

    difficulty: str
    marks: int
    negative_marks: int

    options: list[QuestionOptionResponse]


class CheckAnswerRequest(BaseModel):
    exam_id: UUID
    selected_option_id: UUID


class CheckAnswerResponse(BaseModel):
    question_id: UUID
    selected_option_id: UUID
    correct_option_id: UUID
    is_correct: bool
    marks_awarded: int
    explanation: str | None