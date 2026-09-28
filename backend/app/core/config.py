from dataclasses import dataclass
import os


@dataclass(frozen=True)
class Settings:
    app_name: str = "PrepMate API"
    app_version: str = "1.0.0"

    database_url: str = os.getenv(
        "DATABASE_URL",
        "postgresql+psycopg://prep_mate:prep_mate_dev_password@localhost:5432/prep_mate",
    )

    jwt_secret_key: str = os.getenv(
        "JWT_SECRET_KEY",
        "prep_mate_dev_secret_change_later",
    )

    jwt_algorithm: str = "HS256"

    access_token_expire_minutes: int = 60


settings = Settings()