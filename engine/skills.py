import json
import os
from typing import List, Dict

SKILLS_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "skills")

class SkillManager:
    def __init__(self):
        self.skills_path = SKILLS_DIR
        if not os.path.exists(self.skills_path):
            os.makedirs(self.skills_path)

    def list_skills(self) -> List[Dict]:
        skills = []
        for filename in os.listdir(self.skills_path):
            if filename.endswith(".json"):
                with open(os.path.join(self.skills_path, filename), "r") as f:
                    try:
                        skill_data = json.load(f)
                        skills.append(skill_data)
                    except json.JSONDecodeError:
                        continue
        return skills

    def get_active_prompts(self, active_skill_ids: List[str]) -> str:
        skills = self.list_skills()
        prompts = []
        for skill in skills:
            if skill.get("id") in active_skill_ids and skill.get("enabled", True):
                prompts.append(skill.get("prompt", ""))
        return "\n\n".join(prompts)

    def add_skill(self, skill_data: Dict) -> bool:
        skill_id = skill_data.get("id")
        path = os.path.join(self.skills_path, f"{skill_id}.json")
        with open(path, "w") as f:
            json.dump(skill_data, f, indent=4)
        return True

    def toggle_skill(self, skill_id: str, enabled: bool) -> bool:
        path = os.path.join(self.skills_path, f"{skill_id}.json")
        if os.path.exists(path):
            with open(path, "r") as f:
                skill_data = json.load(f)
            skill_data["enabled"] = enabled
            with open(path, "w") as f:
                json.dump(skill_data, f, indent=4)
            return True
        return False

# Example skill creation
def create_default_skills():
    default_skills = [
        {
            "id": "code-analyzer",
            "name": "Code Analyzer",
            "description": "Expert at analyzing code structure and patterns.",
            "prompt": "You are a senior code analyst. Provide deep insights into code complexity and architecture.",
            "enabled": True
        },
        {
            "id": "bug-fixer",
            "name": "Bug Fixer",
            "description": "Specializes in identifying and fixing bugs.",
            "prompt": "You are a bug-fixing specialist. Focus on finding vulnerabilities and logical errors.",
            "enabled": True
        }
    ]
    for skill in default_skills:
        path = os.path.join(SKILLS_DIR, f"{skill['id']}.json")
        if not os.path.exists(path):
            with open(path, "w") as f:
                json.dump(skill, f, indent=4)

if __name__ == "__main__":
    create_default_skills()
