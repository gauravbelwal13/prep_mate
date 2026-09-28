from uuid import UUID, uuid4

from sqlalchemy import ForeignKey, Integer, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID as PostgreSQLUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base


class TestQuestion(Base):
    __tablename__ = "test_questions"

    __table_args__ = (
        UniqueConstraint(
            "test_id",
            "question_id",
            name="uq_test_question",
        ),
        UniqueConstraint(
            "test_id",
            "question_order",
            name="uq_test_question_order",
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PostgreSQLUUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
    )

    test_id: Mapped[UUID] = mapped_column(
        PostgreSQLUUID(as_uuid=True),
        ForeignKey("tests.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    question_id: Mapped[UUID] = mapped_column(
        PostgreSQLUUID(as_uuid=True),
        ForeignKey("questions.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )

    question_order: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    # Snapshot of the scoring rules at the time the question
    # is added to this test.
    marks: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    negative_marks: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    test: Mapped["Test"] = relationship(
        back_populates="test_questions",
    )

    question: Mapped["Question"] = relationship()