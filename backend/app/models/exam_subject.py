from uuid import UUID, uuid4

from sqlalchemy import ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID as PostgreSQLUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base


class ExamSubject(Base):
    __tablename__ = "exam_subjects"

    __table_args__ = (
        UniqueConstraint(
            "exam_id",
            "subject_id",
            name="uq_exam_subject",
        ),
    )

    id: Mapped[UUID] = mapped_column(
        PostgreSQLUUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
    )

    exam_id: Mapped[UUID] = mapped_column(
        PostgreSQLUUID(as_uuid=True),
        ForeignKey("exams.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    subject_id: Mapped[UUID] = mapped_column(
        PostgreSQLUUID(as_uuid=True),
        ForeignKey("subjects.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    exam: Mapped["Exam"] = relationship(
        back_populates="exam_subjects",
    )

    subject: Mapped["Subject"] = relationship(
        back_populates="exam_subjects",
    )