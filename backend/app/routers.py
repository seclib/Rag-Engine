import json
import re
from uuid import uuid4
from typing import AsyncGenerator
from fastapi import APIRouter, HTTPException, UploadFile, File, Query
from fastapi.responses import StreamingResponse
from engine.agent import agent
from engine.autonomous_agent import autonomous_agent
from engine.security import security, secure_endpoint
from .schemas import (
    QueryRequest,
    SkillCreateRequest,
    ExecuteRequest,
    AutonomousTaskRequest,
)

router = APIRouter()


def _slugify(value: str) -> str:
    normalized = value.lower().strip()
    normalized = re.sub(r"[^a-z0-9]+", "-", normalized)
    normalized = re.sub(r"-+", "-", normalized)
    return normalized.strip("-") or f"skill-{uuid4().hex[:8]}"


def _sse_event(message: str) -> str:
    return f"data: {json.dumps({'text': message})}\n\n"


@router.get("/")
async def root() -> dict:
    return {"status": "Seclib AI Desktop API running"}


@router.get("/status")
async def status() -> dict:
    return {
        "status": "online",
        "model": agent.model,
        "rag_ready": True,
        "skills_count": len(agent.skills.list_skills()),
    }


@router.post("/query")
@secure_endpoint
async def query(payload: QueryRequest):
    async def stream() -> AsyncGenerator[str, None]:
        async for chunk in agent.chat_stream(payload.text, payload.skills or []):
            yield _sse_event(chunk)
        yield _sse_event("[STREAM_COMPLETE]")

    return StreamingResponse(stream(), media_type="text/event-stream")


@router.get("/skills")
async def list_skills() -> dict:
    skills = agent.skills.list_skills()
    return {"skills": skills}


@router.post("/skills/add")
@secure_endpoint
async def add_skill(payload: SkillCreateRequest) -> dict:
    skill_id = _slugify(payload.name)
    skill_data = {
        "id": skill_id,
        "name": payload.name,
        "description": payload.description or "",
        "prompt": payload.prompt,
        "enabled": True,
    }
    agent.skills.add_skill(skill_data)
    return {"success": True, "skill": skill_data}


@router.post("/skills/toggle")
async def toggle_skill(skill_id: str = Query(...), enabled: bool = Query(...)) -> dict:
    if not agent.skills.toggle_skill(skill_id, enabled):
        raise HTTPException(status_code=404, detail="Skill not found")
    return {"success": True, "skill_id": skill_id, "enabled": enabled}


@router.get("/knowledge/list")
async def list_knowledge() -> list:
    return agent.rag.list_sources()


@router.post("/knowledge/add")
async def add_knowledge(file: UploadFile = File(...)) -> dict:
    content = await file.read()
    safe, msg = security.sanitize_content(content.decode("utf-8", errors="ignore"))
    if not safe:
        raise HTTPException(status_code=403, detail=msg)

    await agent.rag.add_source(file.filename, content)
    return {"success": True, "filename": file.filename}


@router.delete("/knowledge/remove/{filename}")
async def remove_knowledge(filename: str) -> dict:
    if not agent.rag.remove_source(filename):
        raise HTTPException(status_code=404, detail="Source not found")
    return {"success": True, "filename": filename}


@router.post("/knowledge/rebuild")
async def rebuild_knowledge() -> dict:
    await agent.rag.rebuild_index()
    return {"success": True}


@router.get("/knowledge/query")
async def query_knowledge(text: str) -> dict:
    context = await agent.rag.query_rag(text)
    return {"context": context}


@router.post("/tools/execute")
async def execute_tool(payload: ExecuteRequest) -> dict:
    if not payload.confirm:
        raise HTTPException(status_code=400, detail="Confirmation required for command execution.")

    is_safe, message = security.validate_command(payload.command)
    if not is_safe:
        raise HTTPException(status_code=403, detail=message)

    result = await autonomous_agent.run_command(payload.command)
    return {"success": True, "command": payload.command, "output": result}


@router.post("/agent/autonomous")
async def autonomous_task(payload: AutonomousTaskRequest):
    async def stream() -> AsyncGenerator[str, None]:
        async for update in autonomous_agent.autonomous_loop(payload.task, payload.mode or "fix"):
            yield _sse_event(update)
        yield _sse_event("[AUTONOMOUS_COMPLETE]")

    return StreamingResponse(stream(), media_type="text/event-stream")
