from fastapi import FastAPI, UploadFile, File, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
import os
from typing import List, Optional

from engine.agent import agent
from engine.skills import SkillManager
from engine.rag import RAGManager

app = FastAPI(title="Seclib AI Backend")
skill_manager = SkillManager()
rag_manager = RAGManager()

# CORS for Electron
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class QueryRequest(BaseModel):
    text: str
    skills: List[str] = []

@app.get("/")
async def root():
    return {"status": "ok", "message": "Seclib AI Backend Running"}

from fastapi.responses import StreamingResponse
import json

@app.post("/query")
async def query_ai(request: QueryRequest):
    # Manual check since it's a Pydantic model
    safe, msg = security.sanitize_content(request.text)
    if not safe:
        async def error_stream():
            yield f"data: {json.dumps({'text': msg})}\n\n"
        return StreamingResponse(error_stream(), media_type="text/event-stream")
        
    async def generate():
        async for chunk in agent.chat_stream(request.text, request.skills):
            yield f"data: {json.dumps({'text': chunk})}\n\n"
            
    return StreamingResponse(generate(), media_type="text/event-stream")

class SkillCreate(BaseModel):
    name: str
    description: str
    prompt: str

@app.get("/skills")
async def list_skills():
    return skill_manager.list_skills()

@app.post("/skills/add")
async def add_skill(skill: SkillCreate):
    skill_id = skill.name.lower().replace(" ", "-")
    skill_data = {
        "id": skill_id,
        "name": skill.name,
        "description": skill.description,
        "prompt": skill.prompt,
        "enabled": True
    }
    # We'll add a method to skill_manager for this
    success = skill_manager.add_skill(skill_data)
    return {"status": "success" if success else "failed", "skill": skill_data}

@app.post("/skills/toggle")
async def toggle_skill(skill_id: str, enabled: bool):
    success = skill_manager.toggle_skill(skill_id, enabled)
    return {"status": "success" if success else "failed"}

@app.post("/knowledge/add")
async def add_knowledge(background_tasks: BackgroundTasks, file: UploadFile = File(...)):
    content = await file.read()
    background_tasks.add_task(rag_manager.add_source, file.filename, content)
    return {"status": "indexing", "filename": file.filename}

@app.get("/knowledge/list")
async def list_knowledge():
    return rag_manager.list_sources()

@app.delete("/knowledge/remove/{filename}")
async def remove_knowledge(filename: str):
    success = rag_manager.remove_source(filename)
    return {"status": "success" if success else "failed"}

@app.post("/knowledge/rebuild")
async def rebuild_knowledge(background_tasks: BackgroundTasks):
    background_tasks.add_task(rag_manager.rebuild_index)
    return {"status": "rebuilding"}

@app.get("/knowledge/query")
async def query_knowledge(text: str):
    context = await rag_manager.query_rag(text)
    return {"context": context}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
