from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.models.question import Question
from app.models.question_exam import QuestionExam
from app.models.question_option import QuestionOption


def get_questions(
    db: Session,
    exam_id: UUID,
    subject_id: UUID | None = None,
    chapter_id: UUID | None = None,
    topic_id: UUID | None = None,
    difficulty: str | None = None,
    limit: int = 20,
) -> list[Question]:
    statement = (
        select(Question)
        .join(
            QuestionExam,
            QuestionExam.question_id == Question.id,
        )
        .options(
            joinedload(Question.topic)
            .joinedload(Question.topic.property.mapper.class_.chapter)
            .joinedload(
                Question.topic.property.mapper.class_.chapter.property.mapper.class_.subject
            ),
            joinedload(Question.options),
        )
        .where(
            QuestionExam.exam_id == exam_id,
            QuestionExam.is_active.is_(True),
            Question.status == "published",
        )
    )

    if subject_id is not None:
        statement = statement.where(
            Question.topic.has(
                Question.topic.property.mapper.class_.chapter.has(
                    Question.topic.property.mapper.class_.chapter.property.mapper.class_.subject.has(
                        id=subject_id,
                    )
                )
            )
        )

    if chapter_id is not None:
        statement = statement.where(
            Question.topic.has(
                Question.topic.property.mapper.class_.chapter.has(
                    id=chapter_id,
                )
            )
        )

    if topic_id is not None:
        statement = statement.where(
            Question.topic_id == topic_id,
        )

    if difficulty is not None:
        statement = statement.where(
            QuestionExam.difficulty == difficulty,
        )

    statement = (
        statement
        .order_by(Question.id)
        .limit(limit)
    )

    return list(
        db.execute(statement)
        .unique()
        .scalars()
        .all()
    )


def get_published_question(
    db: Session,
    question_id: UUID,
) -> Question | None:
    statement = (
        select(Question)
        .where(
            Question.id == question_id,
            Question.status == "published",
        )
    )

    return db.execute(statement).scalar_one_or_none()


def get_question_exam(
    db: Session,
    question_id: UUID,
    exam_id: UUID,
) -> QuestionExam | None:
    statement = (
        select(QuestionExam)
        .where(
            QuestionExam.question_id == question_id,
            QuestionExam.exam_id == exam_id,
            QuestionExam.is_active.is_(True),
        )
    )

    return db.execute(statement).scalar_one_or_none()


def get_question_option(
    db: Session,
    question_id: UUID,
    option_id: UUID,
) -> QuestionOption | None:
    statement = (
        select(QuestionOption)
        .where(
            QuestionOption.id == option_id,
            QuestionOption.question_id == question_id,
        )
    )

    return db.execute(statement).scalar_one_or_none()


def get_correct_question_option(
    db: Session,
    question_id: UUID,
) -> QuestionOption | None:
    statement = (
        select(QuestionOption)
        .where(
            QuestionOption.question_id == question_id,
            QuestionOption.is_correct.is_(True),
        )
        .order_by(QuestionOption.option_order)
    )

    return db.execute(statement).scalars().first()