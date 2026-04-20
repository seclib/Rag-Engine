import os
import subprocess
import json
import asyncio
from typing import List, Dict, Any, Generator
from .security import security
from .rag import RAGManager

class AutonomousCodingAgent:
    def __init__(self, rag: RAGManager):
        self.rag = rag
        self.workspace_root = os.getcwd()
        self.history = []
        self.current_plan = []

    async def run_command(self, command: str) -> str:
        """Executes a bash command after security validation."""
        is_safe, msg = security.validate_command(command)
        if not is_safe:
            return msg

        try:
            # Use subprocess to run the command in the workspace
            process = await asyncio.create_subprocess_shell(
                command,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=self.workspace_root
            )
            stdout, stderr = await process.communicate()
            
            output = stdout.decode().strip()
            error = stderr.decode().strip()
            
            return output if output else error
        except Exception as e:
            return f"Error executing command: {str(e)}"

    async def read_file(self, path: str) -> str:
        """Reads a file if safe."""
        if ".." in path:
            return "Security Alert: Path traversal blocked."
        
        full_path = os.path.join(self.workspace_root, path)
        if not os.path.exists(full_path):
            return f"Error: File {path} does not exist."
            
        try:
            with open(full_path, 'r') as f:
                return f.read()
        except Exception as e:
            return f"Error reading file: {str(e)}"

    async def apply_patch(self, path: str, target: str, replacement: str) -> str:
        """Applies a specific replacement to a file (minimal patching)."""
        content = await self.read_file(path)
        if content.startswith("Error"):
            return content
            
        if target not in content:
            return f"Error: Target content not found in {path}."
            
        new_content = content.replace(target, replacement)
        
        # Backup before write
        full_path = os.path.join(self.workspace_root, path)
        with open(full_path + ".bak", 'w') as f:
            f.write(content)
            
        try:
            with open(full_path, 'w') as f:
                f.write(new_content)
            return f"Successfully patched {path}."
        except Exception as e:
            return f"Error writing file: {str(e)}"

    async def autonomous_loop(self, task: str, mode: str = "fix"):
        """The core execution loop: Observe -> Plan -> Act -> Verify."""
        yield f"🚀 Starting autonomous {mode} mode for task: {task}\n"
        
        # 1. Observe & Analyze
        yield "🔍 Observing system state...\n"
        logs = await self.run_command("tail -n 50 backend.log") if mode == "debug" else ""
        files = await self.run_command("find . -maxdepth 2 -not -path '*/.*'")
        
        # 2. Retrieve Past Memory
        yield "🧠 Checking RAG memory for similar issues...\n"
        memory = await self.rag.query_rag(task)
        
        # 3. Plan (Simulated for this implementation, would call LLM)
        yield "📝 Planning steps...\n"
        # In a real implementation, we'd send logs + files + memory to the LLM to get a plan.
        # For now, we'll simulate the thought process.
        
        # 4. Act (Simulated execution)
        yield "🛠️ Applying changes...\n"
        # Example action: if mode is fix, we might try to apply a patch.
        
        # 5. Verify
        yield "✅ Verifying results...\n"
        # run_command("pytest") or similar.
        
        # 6. Learn
        yield "💾 Learning from this session...\n"
        report = f"Task: {task}\nResult: Success (Simulated)\nDetails: Improved the system."
        await self.rag.add_source(f"fix_report_{hash(task)}.txt", report.encode())
        
        yield "🏁 Autonomous session complete."

# Singleton instance
from .rag import RAGManager
rag_manager = RAGManager()
autonomous_agent = AutonomousCodingAgent(rag_manager)
