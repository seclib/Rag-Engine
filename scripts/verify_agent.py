import asyncio
from engine.security import security
from engine.autonomous_agent import autonomous_agent

async def test_security():
    print("--- Testing Security Layer ---")
    commands = [
        ("ls -la", True),
        ("rm -rf /", False),
        ("sudo apt update", False),
        ("git status", True),
        ("python3 --version", True),
        ("cat /etc/passwd", True), # cat is allowed, but let's see
        ("cat ../secrets.txt", False), # Path traversal
        (":(){ :|:& };:", False) # Fork bomb
    ]
    
    for cmd, expected in commands:
        is_safe, msg = security.validate_command(cmd)
        status = "PASSED" if is_safe == expected else "FAILED"
        print(f"[{status}] Command: {cmd} | Safe: {is_safe} | Msg: {msg}")

async def test_agent_loop():
    print("\n--- Testing Agent Loop (Simulated) ---")
    task = "Fix the indentation in backend/main.py"
    async for update in autonomous_agent.autonomous_loop(task, mode="fix"):
        print(f"> {update.strip()}")

if __name__ == "__main__":
    asyncio.run(test_security())
    asyncio.run(test_agent_loop())
