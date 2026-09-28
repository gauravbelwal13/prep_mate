from uuid import UUID

from sqlalchemy import case, func, select
from sqlalchemy.orm import Session

from app.models.chapter import Chapter
from app.models.exam import Exam
from app.models.question import Question
from app.models.student_profile import StudentProfile
from app.models.subject import Subject
from app.models.test import Test
from app.models.test_answer import TestAnswer
from app.models.test_attempt import TestAttempt
from app.models.topic import Topic


class DashboardRepository:
    def get_student_identity(
        self,
        db: Session,
        user_id: UUID,
    ):
        statement = (
            select(
                StudentProfile.full_name,
                StudentProfile.exam_id,
                Exam.name.label("exam_name"),
            )
            .outerjoin(
                Exam,
                Exam.id == StudentProfile.exam_id,
            )
            .where(
                StudentProfile.user_id == user_id,
            )
        )

        return db.execute(statement).one_or_none()

    def get_overall_statistics(
        self,
        db: Session,
        user_id: UUID,
        exam_id: UUID | None,
    ):
        statement = (
            select(
                func.count(TestAttempt.id).label("completed_tests"),
                func.coalesce(
                    func.sum(TestAttempt.attempted_questions),
                    0,
                ).label("attempted_questions"),
                func.coalesce(
                    func.sum(TestAttempt.correct_answers),
                    0,
                ).label("correct_answers"),
                func.coalesce(
                    func.sum(TestAttempt.incorrect_answers),
                    0,
                ).label("incorrect_answers"),
                func.coalesce(
                    func.sum(TestAttempt.unanswered_questions),
                    0,
                ).label("unanswered_questions"),
            )
            .join(
                Test,
                Test.id == TestAttempt.test_id,
            )
            .where(
                TestAttempt.student_id == user_id,
                TestAttempt.submitted_at.is_not(None),
            )
        )

        if exam_id is not None:
            statement = statement.where(
                Test.exam_id == exam_id,
            )

        return db.execute(statement).one()

    def get_subject_performance(
        self,
        db: Session,
        user_id: UUID,
        exam_id: UUID | None,
    ):
        correct_count = func.sum(
            case(
                (TestAnswer.is_correct.is_(True), 1),
                else_=0,
            )
        )

        attempted_count = func.count(TestAnswer.id)

        statement = (
            select(
                Subject.id.label("subject_id"),
                Subject.name.label("subject_name"),
                attempted_count.label("attempted_questions"),
                correct_count.label("correct_answers"),
            )
            .select_from(TestAnswer)
            .join(
                TestAttempt,
                TestAttempt.id == TestAnswer.attempt_id,
            )
            .join(
                Test,
                Test.id == TestAttempt.test_id,
            )
            .join(
                Question,
                Question.id == TestAnswer.question_id,
            )
            .join(
                Topic,
                Topic.id == Question.topic_id,
            )
            .join(
                Chapter,
                Chapter.id == Topic.chapter_id,
            )
            .join(
                Subject,
                Subject.id == Chapter.subject_id,
            )
            .where(
                TestAttempt.student_id == user_id,
                TestAttempt.submitted_at.is_not(None),
                TestAnswer.is_answered.is_(True),
            )
            .group_by(
                Subject.id,
                Subject.name,
            )
            .order_by(
                Subject.name,
            )
        )

        if exam_id is not None:
            statement = statement.where(
                Test.exam_id == exam_id,
            )

        return db.execute(statement).all()

    def get_topic_performance(
        self,
        db: Session,
        user_id: UUID,
        exam_id: UUID | None,
    ):
        correct_count = func.sum(
            case(
                (TestAnswer.is_correct.is_(True), 1),
                else_=0,
            )
        )

        attempted_count = func.count(TestAnswer.id)

        statement = (
            select(
                Topic.id.label("topic_id"),
                Topic.name.label("topic_name"),
                Chapter.id.label("chapter_id"),
                Chapter.name.label("chapter_name"),
                Subject.id.label("subject_id"),
                Subject.name.label("subject_name"),
                attempted_count.label("attempted_questions"),
                correct_count.label("correct_answers"),
            )
            .select_from(TestAnswer)
            .join(
                TestAttempt,
                TestAttempt.id == TestAnswer.attempt_id,
            )
            .join(
                Test,
                Test.id == TestAttempt.test_id,
            )
            .join(
                Question,
                Question.id == TestAnswer.question_id,
            )
            .join(
                Topic,
                Topic.id == Question.topic_id,
            )
            .join(
                Chapter,
                Chapter.id == Topic.chapter_id,
            )
            .join(
                Subject,
                Subject.id == Chapter.subject_id,
            )
            .where(
                TestAttempt.student_id == user_id,
                TestAttempt.submitted_at.is_not(None),
                TestAnswer.is_answered.is_(True),
            )
            .group_by(
                Topic.id,
                Topic.name,
                Chapter.id,
                Chapter.name,
                Subject.id,
                Subject.name,
            )
        )

        if exam_id is not None:
            statement = statement.where(
                Test.exam_id == exam_id,
            )

        return db.execute(statement).all()

    def get_recent_tests(
        self,
        db: Session,
        user_id: UUID,
        exam_id: UUID | None,
        limit: int = 5,
    ):
        statement = (
            select(
                TestAttempt,
                Test.title,
            )
            .join(
                Test,
                Test.id == TestAttempt.test_id,
            )
            .where(
                TestAttempt.student_id == user_id,
                TestAttempt.submitted_at.is_not(None),
            )
            .order_by(
                TestAttempt.submitted_at.desc(),
            )
            .limit(limit)
        )

        if exam_id is not None:
            statement = statement.where(
                Test.exam_id == exam_id,
            )

        return db.execute(statement).all()