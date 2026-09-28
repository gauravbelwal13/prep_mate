from datetime import datetime
from uuid import UUID

from pydantic import BaseModel


class DashboardExamResponse(BaseModel):
    id: UUID
    name: str


class DashboardStudentResponse(BaseModel):
    name: str


class DashboardOverallResponse(BaseModel):
    completed_tests: int
    attempted_questions: int
    correct_answers: int
    incorrect_answers: int
    unanswered_questions: int
    accuracy: float


class DashboardSubjectPerformanceResponse(BaseModel):
    subject_id: UUID
    subject_name: str
    attempted_questions: int
    correct_answers: int
    incorrect_answers: int
    accuracy: float


class DashboardAreaResponse(BaseModel):
    topic_id: UUID
    topic_name: str
    chapter_id: UUID
    chapter_name: str
    subject_id: UUID
    subject_name: str
    attempted_questions: int
    correct_answers: int
    incorrect_answers: int
    accuracy: float


class DashboardRecentTestResponse(BaseModel):
    attempt_id: UUID
    test_id: UUID
    title: str
    submitted_at: datetime
    total_questions: int
    attempted_questions: int
    correct_answers: int
    incorrect_answers: int
    unanswered_questions: int
    score: float
    accuracy: float


class DashboardSummaryResponse(BaseModel):
    student: DashboardStudentResponse
    exam: DashboardExamResponse | None
    overall: DashboardOverallResponse
    subjects: list[DashboardSubjectPerformanceResponse]
    weak_areas: list[DashboardAreaResponse]
    strong_areas: list[DashboardAreaResponse]
    recent_tests: list[DashboardRecentTestResponse]