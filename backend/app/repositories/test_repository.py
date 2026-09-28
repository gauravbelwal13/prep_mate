from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.models.test import Test
from app.models.test_question import TestQuestion


def get_test_by_id(
    db: Session,
    test_id: UUID,
) -> Test | None:
    statement = (
        select(Test)
        .options(
            joinedload(Test.exam),
            joinedload(Test.test_questions)
            .joinedload(TestQuestion.question),
        )
        .where(Test.id == test_id)
    )

    return (
        db.execute(statement)
        .unique()
        .scalar_one_or_none()
    )


def create_test(
    db: Session,
    test: Test,
) -> Test:
    db.add(test)
    db.flush()

    return test


def add_test_question(
    db: Session,
    test_question: TestQuestion,
) -> TestQuestion:
    db.add(test_question)
    db.flush()

    return test_question