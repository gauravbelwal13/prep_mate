from fastapi import FastAPI

from app.api.v1.router import api_router


app = FastAPI(
    title="PrepMate API",
    version="1.0.0",
)


app.include_router(api_router)


@app.get("/")
def root() -> dict[str, str]:
    return {
        "message": "PrepMate API is running",
    }


@app.get("/health")
def health_check() -> dict[str, str]:
    return {
        "status": "ok",
    }