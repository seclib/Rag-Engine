from typing import List, Optional
from pydantic import BaseModel


class QueryRequest(BaseModel):
    text: str
    skills: Optional[List[str]] = []


class SkillCreateRequest(BaseModel):
    name: str
    description: Optional[str] = ""
    prompt: str


class ToggleSkillRequest(BaseModel):
    skill_id: str
    enabled: bool


class ExecuteRequest(BaseModel):
    command: str
    confirm: bool = False


class AutonomousTaskRequest(BaseModel):
    task: str
    mode: Optional[str] = "fix"


class KnowledgeAddResponse(BaseModel):
    success: bool
    filename: str


class KnowledgeRemoveResponse(BaseModel):
    success: bool
    filename: str


class KnowledgeRebuildResponse(BaseModel):
    success: bool


class KnowledgeQueryResponse(BaseModel):
    context: str
