from datetime import datetime
from uuid import UUID

from pydantic import BaseModel


class StartAttemptResponse(BaseModel):
    id: UUID
    test_id: UUID
    student_id: UUID
    started_at: datetime
    total_questions: int
    status: str


class SubmitAnswerRequest(BaseModel):
    question_id: UUID
    selected_option_id: UUID | None = None


class SubmitAttemptRequest(BaseModel):
    answers: list[SubmitAnswerRequest]


class AttemptResultResponse(BaseModel):
    id: UUID
    test_id: UUID
    student_id: UUID
    started_at: datetime
    submitted_at: datetime
    total_questions: int
    attempted_questions: int
    correct_answers: int
    incorrect_answers: int
    unanswered_questions: int
    score: float
    accuracy: float