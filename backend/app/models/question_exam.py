from uuid import UUID, uuid4

from sqlalchemy import Boolean, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID as PostgreSQLUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base


class QuestionExam(Base):
    __tablename__ = "question_exams"

    __table_args__ = (
        UniqueConstraint(
            "question_id",
            "exam_id",
            name="uq_question_exam",
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PostgreSQLUUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
    )

    question_id: Mapped[UUID] = mapped_column(
        PostgreSQLUUID(as_uuid=True),
        ForeignKey("questions.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    exam_id: Mapped[UUID] = mapped_column(
        PostgreSQLUUID(as_uuid=True),
        ForeignKey("exams.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    difficulty: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
        default="medium",
    )

    marks: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=4,
    )

    negative_marks: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=1,
    )

    is_active: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=True,
    )

    question: Mapped["Question"] = relationship(
        back_populates="question_exams",
    )

    exam: Mapped["Exam"] = relationship(
        back_populates="question_exams",
    )