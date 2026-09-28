from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.repositories.dashboard_repository import DashboardRepository
from app.schemas.dashboard import (
    DashboardAreaResponse,
    DashboardExamResponse,
    DashboardOverallResponse,
    DashboardRecentTestResponse,
    DashboardStudentResponse,
    DashboardSubjectPerformanceResponse,
    DashboardSummaryResponse,
)


MIN_TOPIC_QUESTIONS = 3
WEAK_ACCURACY_THRESHOLD = 60.0
STRONG_ACCURACY_THRESHOLD = 80.0
MAX_AREAS = 5


class DashboardService:
    def __init__(
        self,
        repository: DashboardRepository,
    ):
        self.repository = repository

    def get_summary(
        self,
        db: Session,
        user_id: UUID,
    ) -> DashboardSummaryResponse:
        identity = self.repository.get_student_identity(
            db=db,
            user_id=user_id,
        )

        if identity is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Student profile not found.",
            )

        full_name = identity.full_name or "Student"
        exam_id = identity.exam_id

        exam = None

        if exam_id is not None and identity.exam_name is not None:
            exam = DashboardExamResponse(
                id=exam_id,
                name=identity.exam_name,
            )

        overall_row = self.repository.get_overall_statistics(
            db=db,
            user_id=user_id,
            exam_id=exam_id,
        )

        completed_tests = self._to_int(
            overall_row.completed_tests,
        )
        attempted_questions = self._to_int(
            overall_row.attempted_questions,
        )
        correct_answers = self._to_int(
            overall_row.correct_answers,
        )
        incorrect_answers = self._to_int(
            overall_row.incorrect_answers,
        )
        unanswered_questions = self._to_int(
            overall_row.unanswered_questions,
        )

        overall_accuracy = self._calculate_accuracy(
            correct_answers=correct_answers,
            attempted_questions=attempted_questions,
        )

        overall = DashboardOverallResponse(
            completed_tests=completed_tests,
            attempted_questions=attempted_questions,
            correct_answers=correct_answers,
            incorrect_answers=incorrect_answers,
            unanswered_questions=unanswered_questions,
            accuracy=overall_accuracy,
        )

        subjects = self._build_subject_performance(
            db=db,
            user_id=user_id,
            exam_id=exam_id,
        )

        topic_performance = self._build_topic_performance(
            db=db,
            user_id=user_id,
            exam_id=exam_id,
        )

        weak_areas = [
            area
            for area in topic_performance
            if area.attempted_questions >= MIN_TOPIC_QUESTIONS
            and area.accuracy < WEAK_ACCURACY_THRESHOLD
        ]

        strong_areas = [
            area
            for area in topic_performance
            if area.attempted_questions >= MIN_TOPIC_QUESTIONS
            and area.accuracy >= STRONG_ACCURACY_THRESHOLD
        ]

        weak_areas.sort(
            key=lambda area: (
                area.accuracy,
                -area.attempted_questions,
            )
        )

        strong_areas.sort(
            key=lambda area: (
                -area.accuracy,
                -area.attempted_questions,
            )
        )

        weak_areas = weak_areas[:MAX_AREAS]
        strong_areas = strong_areas[:MAX_AREAS]

        recent_tests = self._build_recent_tests(
            db=db,
            user_id=user_id,
            exam_id=exam_id,
        )

        return DashboardSummaryResponse(
            student=DashboardStudentResponse(
                name=full_name,
            ),
            exam=exam,
            overall=overall,
            subjects=subjects,
            weak_areas=weak_areas,
            strong_areas=strong_areas,
            recent_tests=recent_tests,
        )

    def _build_subject_performance(
        self,
        db: Session,
        user_id: UUID,
        exam_id: UUID | None,
    ) -> list[DashboardSubjectPerformanceResponse]:
        rows = self.repository.get_subject_performance(
            db=db,
            user_id=user_id,
            exam_id=exam_id,
        )

        result: list[DashboardSubjectPerformanceResponse] = []

        for row in rows:
            attempted_questions = self._to_int(
                row.attempted_questions,
            )

            correct_answers = self._to_int(
                row.correct_answers,
            )

            incorrect_answers = (
                attempted_questions - correct_answers
            )

            accuracy = self._calculate_accuracy(
                correct_answers=correct_answers,
                attempted_questions=attempted_questions,
            )

            result.append(
                DashboardSubjectPerformanceResponse(
                    subject_id=row.subject_id,
                    subject_name=row.subject_name,
                    attempted_questions=attempted_questions,
                    correct_answers=correct_answers,
                    incorrect_answers=incorrect_answers,
                    accuracy=accuracy,
                )
            )

        return result

    def _build_topic_performance(
        self,
        db: Session,
        user_id: UUID,
        exam_id: UUID | None,
    ) -> list[DashboardAreaResponse]:
        rows = self.repository.get_topic_performance(
            db=db,
            user_id=user_id,
            exam_id=exam_id,
        )

        result: list[DashboardAreaResponse] = []

        for row in rows:
            attempted_questions = self._to_int(
                row.attempted_questions,
            )

            correct_answers = self._to_int(
                row.correct_answers,
            )

            incorrect_answers = (
                attempted_questions - correct_answers
            )

            accuracy = self._calculate_accuracy(
                correct_answers=correct_answers,
                attempted_questions=attempted_questions,
            )

            result.append(
                DashboardAreaResponse(
                    topic_id=row.topic_id,
                    topic_name=row.topic_name,
                    chapter_id=row.chapter_id,
                    chapter_name=row.chapter_name,
                    subject_id=row.subject_id,
                    subject_name=row.subject_name,
                    attempted_questions=attempted_questions,
                    correct_answers=correct_answers,
                    incorrect_answers=incorrect_answers,
                    accuracy=accuracy,
                )
            )

        return result

    def _build_recent_tests(
        self,
        db: Session,
        user_id: UUID,
        exam_id: UUID | None,
    ) -> list[DashboardRecentTestResponse]:
        rows = self.repository.get_recent_tests(
            db=db,
            user_id=user_id,
            exam_id=exam_id,
            limit=5,
        )

        result: list[DashboardRecentTestResponse] = []

        for row in rows:
            attempt = row[0]
            title = row[1]

            result.append(
                DashboardRecentTestResponse(
                    attempt_id=attempt.id,
                    test_id=attempt.test_id,
                    title=title,
                    submitted_at=attempt.submitted_at,
                    total_questions=attempt.total_questions,
                    attempted_questions=attempt.attempted_questions,
                    correct_answers=attempt.correct_answers,
                    incorrect_answers=attempt.incorrect_answers,
                    unanswered_questions=attempt.unanswered_questions,
                    score=float(attempt.score),
                    accuracy=float(attempt.accuracy),
                )
            )

        return result

    @staticmethod
    def _calculate_accuracy(
        correct_answers: int,
        attempted_questions: int,
    ) -> float:
        if attempted_questions <= 0:
            return 0.0

        return round(
            (correct_answers / attempted_questions) * 100,
            2,
        )

    @staticmethod
    def _to_int(value) -> int:
        if value is None:
            return 0

        return int(value)