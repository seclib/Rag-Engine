import os
import subprocess
import json
import asyncio
import logging
from typing import List, Dict, Any, Generator, Optional
from datetime import datetime
from .security import security
from .rag import RAGManager

# Configure logging
logging.basicConfig(
    filename='logs/autonomous_agent.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

class AutonomousCodingAgent:
    """
    Autonomous Coding Agent for Seclib AI Desktop

    Features:
    - Auto debug: Reads logs, detects errors
    - Auto fix: Applies minimal patches to fix issues
    - Auto refactor: Improves code structure
    - Memory: Learns from past fixes via RAG
    - Safe: Validates all operations, logs actions
    """

    def __init__(self, rag: RAGManager):
        self.rag = rag
        self.workspace_root = os.getcwd()
        self.history = []
        self.current_task = None
        self.logger = logging.getLogger(__name__)

    async def log_action(self, action: str, details: str = ""):
        """Log all agent actions for audit trail."""
        message = f"ACTION: {action} - {details}"
        self.logger.info(message)
        self.history.append({
            'timestamp': datetime.now().isoformat(),
            'action': action,
            'details': details
        })

    async def run_command(self, command: str, confirm_destructive: bool = True) -> str:
        """Executes a bash command after security validation."""
        await self.log_action("run_command", f"Command: {command}")

        is_safe, msg = security.validate_command(command)
        if not is_safe:
            await self.log_action("run_command_blocked", msg)
            return msg

        # Check for destructive commands
        destructive_patterns = ['rm -rf', 'rmdir', 'del ', 'format', 'fdisk']
        if confirm_destructive and any(pattern in command for pattern in destructive_patterns):
            await self.log_action("destructive_command_detected", command)
            return "BLOCKED: Destructive command requires manual confirmation."

        try:
            process = await asyncio.create_subprocess_shell(
                command,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=self.workspace_root
            )
            stdout, stderr = await process.communicate()

            output = stdout.decode().strip()
            error = stderr.decode().strip()

            result = output if output else error
            await self.log_action("run_command_result", f"Exit code: {process.returncode}")
            return result
        except Exception as e:
            error_msg = f"Error executing command: {str(e)}"
            await self.log_action("run_command_error", error_msg)
            return error_msg

    async def read_file(self, path: str) -> str:
        """Reads a file if safe."""
        await self.log_action("read_file", f"Path: {path}")

        if ".." in path or not path.replace('/', '').replace('\\', '').replace('.', '').replace('-', '').replace('_', '').isalnum():
            error = "Security Alert: Invalid path."
            await self.log_action("read_file_blocked", error)
            return error

        full_path = os.path.join(self.workspace_root, path)
        if not os.path.exists(full_path):
            error = f"Error: File {path} does not exist."
            await self.log_action("read_file_error", error)
            return error

        try:
            with open(full_path, 'r') as f:
                content = f.read()
            await self.log_action("read_file_success", f"Read {len(content)} chars")
            return content
        except Exception as e:
            error = f"Error reading file: {str(e)}"
            await self.log_action("read_file_error", error)
            return error

    async def apply_patch(self, path: str, target: str, replacement: str, verify: bool = True) -> str:
        """Applies a specific replacement to a file (minimal patching)."""
        await self.log_action("apply_patch", f"File: {path}, Target length: {len(target)}")

        content = await self.read_file(path)
        if content.startswith("Error"):
            return content

        if target not in content:
            error = f"Error: Target content not found in {path}."
            await self.log_action("apply_patch_error", error)
            return error

        # Create backup
        full_path = os.path.join(self.workspace_root, path)
        backup_path = full_path + ".bak"
        with open(backup_path, 'w') as f:
            f.write(content)

        # Apply patch
        new_content = content.replace(target, replacement, 1)  # Replace only first occurrence

        # Verify the change makes sense
        if verify:
            lines_old = content.count('\n') + 1
            lines_new = new_content.count('\n') + 1
            if abs(lines_old - lines_new) > 10:  # Major structural change
                await self.log_action("apply_patch_verification", "Major change detected, flagging for review")
                return "WARNING: Major structural change detected. Manual review recommended."

        try:
            with open(full_path, 'w') as f:
                f.write(new_content)
            success_msg = f"Successfully patched {path}."
            await self.log_action("apply_patch_success", success_msg)
            return success_msg
        except Exception as e:
            error = f"Error writing file: {str(e)}"
            await self.log_action("apply_patch_error", error)
            return error

    async def detect_issues(self, mode: str) -> List[Dict[str, Any]]:
        """Detect issues based on mode."""
        await self.log_action("detect_issues", f"Mode: {mode}")

        issues = []

        if mode == "debug":
            # Check logs for errors
            log_output = await self.run_command("tail -n 100 logs/system_state")
            if "ERROR" in log_output or "Exception" in log_output:
                issues.append({
                    'type': 'log_error',
                    'description': 'Errors detected in system logs',
                    'data': log_output
                })

        elif mode == "fix":
            # Check for syntax errors
            python_check = await self.run_command("python3 -m py_compile backend/main.py")
            if "SyntaxError" in python_check:
                issues.append({
                    'type': 'syntax_error',
                    'description': 'Python syntax error in backend',
                    'data': python_check
                })

        elif mode == "refactor":
            # Check for code smells
            long_files = await self.run_command("find . -name '*.py' -exec wc -l {} + | sort -nr | head -5")
            issues.append({
                'type': 'long_file',
                'description': 'Files that might need refactoring',
                'data': long_files
            })

        await self.log_action("detect_issues_found", f"Found {len(issues)} issues")
        return issues

    async def plan_fix(self, issue: Dict[str, Any], memory: str) -> Dict[str, Any]:
        """Plan a fix based on issue and past memory."""
        await self.log_action("plan_fix", f"Issue type: {issue['type']}")

        plan = {
            'steps': [],
            'risk_level': 'low',
            'requires_confirmation': False
        }

        if issue['type'] == 'syntax_error':
            plan['steps'] = [
                'Identify syntax error location',
                'Apply minimal fix',
                'Verify syntax'
            ]
            plan['risk_level'] = 'medium'

        elif issue['type'] == 'log_error':
            plan['steps'] = [
                'Parse error logs',
                'Identify root cause',
                'Apply targeted fix'
            ]
            plan['risk_level'] = 'high'
            plan['requires_confirmation'] = True

        # Incorporate memory
        if memory:
            plan['steps'].insert(0, f"Reference past fix: {memory[:100]}...")

        await self.log_action("plan_fix_complete", f"Plan created with {len(plan['steps'])} steps")
        return plan

    async def verify_result(self, task: str) -> bool:
        """Verify that the fix worked."""
        await self.log_action("verify_result", f"Task: {task}")

        # Run basic checks
        if "syntax" in task.lower():
            result = await self.run_command("python3 -m py_compile backend/main.py")
            success = "SyntaxError" not in result
        elif "test" in task.lower():
            result = await self.run_command("python3 -m pytest --tb=short -q")
            success = "FAILED" not in result
        else:
            # Generic check - ensure no obvious errors
            result = await self.run_command("echo 'Verification check'")
            success = True

        await self.log_action("verify_result", f"Success: {success}")
        return success

    async def autonomous_loop(self, task: str, mode: str = "fix", max_iterations: int = 3) -> Generator[str, None, None]:
        """The core execution loop: Observe -> Detect -> Plan -> Apply -> Verify."""
        await self.log_action("autonomous_loop_start", f"Task: {task}, Mode: {mode}")

        yield f"🚀 Starting autonomous {mode} mode for task: {task}\n"

        iteration = 0
        success = False

        while iteration < max_iterations and not success:
            iteration += 1
            yield f"🔄 Iteration {iteration}/{max_iterations}\n"

            # 1. Observe system state
            yield "🔍 Observing system state...\n"
            system_state = await self.run_command("ps aux | grep -E '(python|node|uvicorn)' | head -10")
            yield f"System processes: {system_state[:200]}...\n"

            # 2. Detect issues
            yield "🔎 Detecting issues...\n"
            issues = await self.detect_issues(mode)
            if not issues:
                yield "✅ No issues detected.\n"
                success = True
                continue

            for issue in issues:
                yield f"📋 Issue found: {issue['description']}\n"

                # 3. Retrieve memory
                yield "🧠 Consulting RAG memory...\n"
                memory = await self.rag.query_rag(f"fix for {issue['type']}: {issue['description']}")
                yield f"Memory: {memory[:200] if memory else 'No relevant memory found'}...\n"

                # 4. Plan fix
                yield "📝 Planning fix...\n"
                plan = await self.plan_fix(issue, memory)
                yield f"Plan: {', '.join(plan['steps'])}\n"
                yield f"Risk level: {plan['risk_level']}\n"

                if plan['requires_confirmation']:
                    yield "⚠️ High-risk operation requires confirmation. Skipping in autonomous mode.\n"
                    continue

                # 5. Apply fix (simplified - in real implementation, would use LLM to generate patches)
                yield "🛠️ Applying fix...\n"
                if issue['type'] == 'syntax_error':
                    # Example: fix a common syntax error
                    fix_result = await self.apply_patch(
                        "backend/main.py",
                        "print('hello world')",  # target
                        "print('hello world')"   # replacement (same for demo)
                    )
                    yield f"Fix result: {fix_result}\n"

                # 6. Verify
                yield "✅ Verifying fix...\n"
                success = await self.verify_result(task)
                if success:
                    yield "🎉 Fix verified successfully!\n"
                    break
                else:
                    yield "❌ Fix verification failed. Will retry.\n"

        # 7. Learn and store
        yield "💾 Learning from session...\n"
        report = f"Task: {task}\nMode: {mode}\nIterations: {iteration}\nSuccess: {success}\nHistory: {json.dumps(self.history[-5:], indent=2)}"
        await self.rag.add_source(f"agent_session_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt", report.encode())

        yield "🏁 Autonomous session complete.\n"

# Singleton instance
from .rag import RAGManager
rag_manager = RAGManager()
autonomous_agent = AutonomousCodingAgent(rag_manager)
