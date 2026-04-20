from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from engine.skills import create_default_skills
from .routers import router

app = FastAPI(
    title="Seclib AI Desktop API",
    description="Local-first AI assistant API for the Seclib AI Desktop application.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://localhost:8000",
        "http://127.0.0.1:8000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup_event():
    create_default_skills()

app.include_router(router)
