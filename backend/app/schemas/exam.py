from uuid import UUID

from pydantic import BaseModel


class ExamResponse(BaseModel):
    id: UUID
    code: str
    name: str
    description: str | None


class ExamSelectionRequest(BaseModel):
    exam_id: UUID