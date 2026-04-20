# Autonomous Coding Agent for Seclib AI Desktop

The Autonomous Coding Agent is an AI-powered development assistant that can automatically write, fix, and refactor code while maintaining system safety and learning from past experiences.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    AUTONOMOUS AGENT                         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  Observer   │  │   Planner   │  │   Actor     │         │
│  │             │  │             │  │             │         │
│  │ • Read logs │  │ • Analyze   │  │ • Apply     │         │
│  │ • Check     │  │ • Plan      │  │ • patches   │         │
│  │ • files     │  │ • fixes     │  │ • Run cmds  │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Memory    │  │  Security   │  │   Logger    │         │
│  │   (RAG)     │  │             │  │             │         │
│  │ • Past      │  │ • Validate  │  │ • Audit     │         │
│  │ • fixes     │  │ • commands  │  │ • trail     │         │
│  │ • Learning  │  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Execution Loop
The agent operates in a continuous improvement cycle:

1. **Observe** - Monitor system state, logs, and files
2. **Detect** - Identify issues or tasks based on mode
3. **Plan** - Create execution plan using memory and analysis
4. **Apply** - Execute fixes with minimal, targeted changes
5. **Verify** - Test results and ensure improvements
6. **Learn** - Store successful patterns for future use

### 2. Operating Modes

#### Debug Mode
- **Purpose**: Automatically detect and fix runtime errors
- **Actions**:
  - Parse system logs for errors
  - Identify root causes
  - Apply targeted fixes
  - Verify error resolution

#### Fix Mode
- **Purpose**: Correct code issues and bugs
- **Actions**:
  - Check syntax errors
  - Validate code structure
  - Apply minimal patches
  - Run tests to verify

#### Refactor Mode
- **Purpose**: Improve code quality and structure
- **Actions**:
  - Analyze code complexity
  - Identify improvement opportunities
  - Apply structural changes
  - Maintain functionality

### 3. Safety Features

- **Command Validation**: All terminal commands checked for safety
- **File Path Security**: No path traversal or invalid paths allowed
- **Backup Creation**: Automatic backups before file modifications
- **Change Verification**: Structural change detection and warnings
- **Destructive Command Blocks**: High-risk operations require confirmation

### 4. Memory System

- **RAG Integration**: Uses vector search for relevant past fixes
- **Learning Loop**: Stores successful fixes for future reference
- **Context Awareness**: Considers similar issues from history
- **Pattern Recognition**: Learns from repeated problem types

## Usage

### Command Line
```bash
# Run in debug mode
python3 run_agent.py debug

# Run in fix mode with custom task
python3 run_agent.py fix "Fix authentication issues"

# Run in refactor mode
python3 run_agent.py refactor
```

### Programmatic Usage
```python
from engine.autonomous_agent import autonomous_agent

async def run_fix():
    async for message in autonomous_agent.autonomous_loop(
        "Fix syntax errors in backend",
        mode="fix"
    ):
        print(message, end="")
```

## Key Methods

### Core Operations
- `run_command(command)` - Execute safe terminal commands
- `read_file(path)` - Read project files securely
- `apply_patch(path, target, replacement)` - Apply minimal code changes

### Analysis Methods
- `detect_issues(mode)` - Find problems based on operating mode
- `plan_fix(issue, memory)` - Create execution plans
- `verify_result(task)` - Test fix effectiveness

### Memory Integration
- `log_action(action, details)` - Audit trail logging
- RAG queries for past fixes
- Learning from successful sessions

## Configuration

### Safety Settings
- Destructive command detection
- File size limits
- Path validation rules
- Change verification thresholds

### Memory Settings
- RAG collection for fixes
- Learning rate and retention
- Context window size

## Logging

All agent actions are logged to `logs/autonomous_agent.log`:
```
2024-01-15 10:30:15 - INFO - ACTION: apply_patch - File: backend/main.py, Target length: 25
2024-01-15 10:30:16 - INFO - ACTION: verify_result - Success: True
```

## Integration Points

### Backend API
The agent can be triggered via FastAPI endpoints:
- `POST /agent/debug` - Start debug session
- `POST /agent/fix` - Apply fixes
- `POST /agent/refactor` - Code refactoring

### UI Integration
Electron frontend can display agent progress and results in real-time.

### Monitoring
System state monitoring for proactive issue detection.

## Future Enhancements

- **LLM Integration**: Use language models for more sophisticated planning
- **Multi-file Analysis**: Cross-file dependency understanding
- **Performance Profiling**: Automatic optimization suggestions
- **Test Generation**: Create tests for fixed code
- **Documentation Updates**: Auto-update docs for code changes

## Safety Guidelines

1. **Always backup** before major changes
2. **Test in staging** before production deployment
3. **Monitor logs** for unexpected behavior
4. **Use confirmation** for high-risk operations
5. **Review changes** after agent modifications

The autonomous agent represents a significant advancement in self-healing software systems, capable of maintaining and improving code quality autonomously while ensuring system stability and security.