import httpx
import json
from .security import security
from .skills import SkillManager
from .rag import RAGManager

class SeclibAgent:
    def __init__(self):
        self.ollama_url = "http://localhost:11434/api/generate"
        self.model = "qwen2.5-coder:7b"
        self.skills = SkillManager()
        self.rag = RAGManager()

    async def chat_stream(self, user_input: str, active_skills: list = []):
        # 1. Get Prompts (Security already checked in main.py)
        system_prompt = "You are Seclib AI, a helpful and secure local coding assistant. Always prioritize safety and correctness.\n"
        skill_prompts = self.skills.get_active_prompts(active_skills)
        if skill_prompts:
            system_prompt += f"\nActive Skills context:\n{skill_prompts}\n"

        rag_context = await self.rag.query_rag(user_input)
        if rag_context:
            system_prompt += f"\nRelevant Knowledge:\n{rag_context}\n"

        # 2. Call Ollama with streaming
        payload = {
            "model": self.model,
            "prompt": f"{system_prompt}\nUser: {user_input}\nAssistant:",
            "stream": True
        }

        async with httpx.AsyncClient() as client:
            try:
                async with client.stream("POST", self.ollama_url, json=payload, timeout=60.0) as response:
                    async for line in response.aiter_lines():
                        if line:
                            data = json.loads(line)
                            if data.get("done"):
                                break
                            yield data.get("response", "")
            except Exception as e:
                yield f"Error connecting to Ollama: {str(e)}"

agent = SeclibAgent()
