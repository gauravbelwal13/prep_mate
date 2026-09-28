from datetime import datetime
from uuid import UUID, uuid4

from sqlalchemy import DateTime, ForeignKey, Integer, Numeric, func
from sqlalchemy.dialects.postgresql import UUID as PostgreSQLUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base


class TestAttempt(Base):
    __tablename__ = "test_attempts"

    id: Mapped[UUID] = mapped_column(
        PostgreSQLUUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
    )

    test_id: Mapped[UUID] = mapped_column(
        PostgreSQLUUID(as_uuid=True),
        ForeignKey("tests.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )

    student_id: Mapped[UUID] = mapped_column(
        PostgreSQLUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )

    started_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )

    submitted_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )

    total_questions: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    attempted_questions: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=0,
    )

    correct_answers: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=0,
    )

    incorrect_answers: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=0,
    )

    unanswered_questions: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=0,
    )

    score: Mapped[float] = mapped_column(
        Numeric(10, 2),
        nullable=False,
        default=0,
    )

    accuracy: Mapped[float] = mapped_column(
        Numeric(5, 2),
        nullable=False,
        default=0,
    )

    test: Mapped["Test"] = relationship()

    student: Mapped["User"] = relationship()

    answers: Mapped[list["TestAnswer"]] = relationship(
        back_populates="attempt",
        cascade="all, delete-orphan",
        order_by="TestAnswer.question_order",
    )