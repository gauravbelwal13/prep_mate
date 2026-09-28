"""snapshot test scoring and answer marks

Revision ID: 77df5fddb75d
Revises: 0a606a984ccc
Create Date: 2026-09-10 17:42:09.213658
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "77df5fddb75d"
down_revision: Union[str, Sequence[str], None] = "0a606a984ccc"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""

    # ---------------------------------------------------------
    # test_questions
    # ---------------------------------------------------------
    #
    # Snapshot exam-specific scoring rules when the question
    # becomes part of a test.
    #

    op.add_column(
        "test_questions",
        sa.Column(
            "marks",
            sa.Integer(),
            nullable=True,
        ),
    )

    op.add_column(
        "test_questions",
        sa.Column(
            "negative_marks",
            sa.Integer(),
            nullable=True,
        ),
    )

    # Backfill existing test questions from the corresponding
    # active QuestionExam configuration.
    op.execute(
        """
        UPDATE test_questions AS tq
        SET
            marks = qe.marks,
            negative_marks = qe.negative_marks
        FROM tests AS t,
             question_exams AS qe
        WHERE tq.test_id = t.id
          AND tq.question_id = qe.question_id
          AND t.exam_id = qe.exam_id
          AND qe.is_active = TRUE
        """
    )

    # Do not invent scoring values for historical tests.
    # If a TestQuestion cannot be mapped to an active
    # QuestionExam configuration, abort the migration.
    op.execute(
        """
        DO $$
        BEGIN
            IF EXISTS (
                SELECT 1
                FROM test_questions
                WHERE marks IS NULL
                   OR negative_marks IS NULL
            ) THEN
                RAISE EXCEPTION
                    'Migration aborted: existing test_questions have no valid scoring configuration.';
            END IF;
        END
        $$;
        """
    )

    op.alter_column(
        "test_questions",
        "marks",
        existing_type=sa.Integer(),
        nullable=False,
    )

    op.alter_column(
        "test_questions",
        "negative_marks",
        existing_type=sa.Integer(),
        nullable=False,
    )

    # ---------------------------------------------------------
    # test_answers
    # ---------------------------------------------------------

    op.add_column(
        "test_answers",
        sa.Column(
            "marks_awarded",
            sa.Numeric(precision=10, scale=2),
            nullable=True,
        ),
    )

    # Backfill historical answer scores using the scoring
    # snapshot stored on TestQuestion.
    #
    # Correct    -> +marks
    # Incorrect  -> -negative_marks
    # Unanswered -> 0
    #
    # The target table is referenced directly in WHERE rather
    # than inside a JOIN condition to keep PostgreSQL happy.
    op.execute(
        """
        UPDATE test_answers AS ta
        SET marks_awarded =
            CASE
                WHEN ta.is_answered = FALSE THEN 0
                WHEN ta.is_correct = TRUE THEN tq.marks
                ELSE -tq.negative_marks
            END
        FROM test_attempts AS a,
             test_questions AS tq
        WHERE ta.attempt_id = a.id
          AND tq.test_id = a.test_id
          AND tq.question_id = ta.question_id
        """
    )

    # Do not silently create an incomplete historical result.
    op.execute(
        """
        DO $$
        BEGIN
            IF EXISTS (
                SELECT 1
                FROM test_answers
                WHERE marks_awarded IS NULL
            ) THEN
                RAISE EXCEPTION
                    'Migration aborted: existing test_answers could not be assigned marks_awarded.';
            END IF;
        END
        $$;
        """
    )

    op.alter_column(
        "test_answers",
        "marks_awarded",
        existing_type=sa.Numeric(
            precision=10,
            scale=2,
        ),
        nullable=False,
    )

    # One answer per question per attempt.
    op.create_unique_constraint(
        "uq_test_answer_attempt_question",
        "test_answers",
        ["attempt_id", "question_id"],
    )


def downgrade() -> None:
    """Downgrade schema."""

    op.drop_constraint(
        "uq_test_answer_attempt_question",
        "test_answers",
        type_="unique",
    )

    op.drop_column(
        "test_answers",
        "marks_awarded",
    )

    op.drop_column(
        "test_questions",
        "negative_marks",
    )

    op.drop_column(
        "test_questions",
        "marks",
    )