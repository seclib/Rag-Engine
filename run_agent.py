#!/usr/bin/env python3
"""
Autonomous Coding Agent Runner for Seclib AI Desktop

Usage:
    python3 run_agent.py debug    # Auto debug mode
    python3 run_agent.py fix      # Auto fix mode
    python3 run_agent.py refactor # Auto refactor mode
"""

import asyncio
import sys
from engine.autonomous_agent import autonomous_agent

async def run_agent(mode: str, task: str = None):
    """Run the autonomous agent in specified mode."""

    if not task:
        if mode == "debug":
            task = "Check system logs for errors and fix any issues"
        elif mode == "fix":
            task = "Fix any syntax errors or runtime issues"
        elif mode == "refactor":
            task = "Refactor code for better structure and performance"
        else:
            print("Invalid mode. Use: debug, fix, or refactor")
            return

    print(f"🤖 Starting Autonomous Agent in {mode.upper()} mode")
    print(f"Task: {task}")
    print("=" * 50)

    async for message in autonomous_agent.autonomous_loop(task, mode):
        print(message, end="")

    print("\n" + "=" * 50)
    print("🤖 Agent session completed")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 run_agent.py <mode> [task]")
        print("Modes: debug, fix, refactor")
        sys.exit(1)

    mode = sys.argv[1]
    task = sys.argv[2] if len(sys.argv) > 2 else None

    asyncio.run(run_agent(mode, task))