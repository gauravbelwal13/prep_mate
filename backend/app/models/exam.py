from uuid import UUID, uuid4

from sqlalchemy import Boolean, String, Text
from sqlalchemy.dialects.postgresql import UUID as PostgreSQLUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base


class Exam(Base):
    __tablename__ = "exams"

    id: Mapped[UUID] = mapped_column(
        PostgreSQLUUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
    )

    code: Mapped[str] = mapped_column(
        String(50),
        unique=True,
        nullable=False,
        index=True,
    )

    name: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    description: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    is_active: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=True,
    )

    student_profiles: Mapped[list["StudentProfile"]] = relationship(
        back_populates="exam",
    )

    exam_subjects: Mapped[list["ExamSubject"]] = relationship(
        back_populates="exam",
        cascade="all, delete-orphan",
    )

    question_exams: Mapped[list["QuestionExam"]] = relationship(
        back_populates="exam",
        cascade="all, delete-orphan",
    )