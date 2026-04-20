import json
from pathlib import Path

SKILLS_DIR = Path("skills")

class SkillsManager:
    def __init__(self):
        self.skills = {}
        self.load_skills()

    def load_skills(self):
        for skill_file in SKILLS_DIR.glob("*.json"):
            with open(skill_file, "r") as f:
                skill = json.load(f)
                self.skills[skill["id"]] = skill

    def add_skill(self, skill_data):
        skill_id = skill_data["id"]
        skill_path = SKILLS_DIR / f"{skill_id}.json"
        with open(skill_path, "w") as f:
            json.dump(skill_data, f, indent=4)
        self.skills[skill_id] = skill_data

    def toggle_skill(self, skill_id, enabled):
        if skill_id in self.skills:
            self.skills[skill_id]["enabled"] = enabled
            skill_path = SKILLS_DIR / f"{skill_id}.json"
            with open(skill_path, "w") as f:
                json.dump(self.skills[skill_id], f, indent=4)

    def get_skills(self):
        return self.skills.values()