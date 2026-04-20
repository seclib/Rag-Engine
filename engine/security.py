import re
from typing import List, Tuple, Callable
import functools

class SecurityLayer:
    def __init__(self):
        # Common patterns for secrets
        self.secret_patterns = [
            r"AIza[0-9A-Za-z-_]{35}",           # Google API Key
            r"sk-[a-zA-Z0-9]{48}",               # OpenAI API Key
            r"-----BEGIN RSA PRIVATE KEY-----",
            r"-----BEGIN OPENSSH PRIVATE KEY-----",
            r"AKIA[0-9A-Z]{16}",                  # AWS Access Key
            r"xox[baprs]-[0-9a-zA-Z]{10,48}",    # Slack Token
            r"ghp_[a-zA-Z0-9]{36}"               # GitHub PAT
        ]
        
        # Allowed tool whitelist
        self.allowed_tools = [
            "ls", "cat", "grep", "find", "pwd", "git", "python", "python3",
            "pytest", "npm", "node", "pip", "pip3", "tail", "head", "diff"
        ]

    def scan_for_secrets(self, text: str) -> List[str]:
        found_secrets = []
        for pattern in self.secret_patterns:
            if re.search(pattern, text):
                found_secrets.append(pattern)
        return found_secrets

    def validate_command(self, command: str) -> Tuple[bool, str]:
        # Block dangerous patterns
        blacklist = [
            "rm -rf", "mkfs", "dd if=", "> /dev", "chmod 777", "sudo", 
            ":(){ :|:& };:", # Fork bomb
            "sh -c", "bash -c" # Prevent nested shell escapes
        ]
        for forbidden in blacklist:
            if forbidden in command:
                return False, f"Security Alert: Forbidden command pattern '{forbidden}' detected."
        
        # Whitelist check for tool execution
        parts = command.split()
        if not parts:
            return False, "Empty command."
            
        tool = parts[0].split("/")[-1] # Handle /usr/bin/git etc
        if tool not in self.allowed_tools:
             return False, f"Security Alert: Tool '{tool}' is not in the allowed whitelist."

        # Path boundary check (crude but effective for this demo)
        if ".." in command:
            return False, "Security Alert: Path traversal attempt detected."

        return True, "Safe"

    def sanitize_content(self, text: str) -> Tuple[bool, str]:
        secrets = self.scan_for_secrets(text)
        if secrets:
            return False, "Security Alert: Sensitive data (API keys or private keys) detected. Operation blocked."
        return True, text

security = SecurityLayer()

# Middleware decorator for FastAPI endpoints
def secure_endpoint(func: Callable):
    @functools.wraps(func)
    async def wrapper(*args, **kwargs):
        # Scan all string arguments for secrets
        for name, value in kwargs.items():
            if isinstance(value, str):
                safe, msg = security.sanitize_content(value)
                if not safe:
                    from fastapi import HTTPException
                    raise HTTPException(status_code=403, detail=msg)
        return await func(*args, **kwargs)
    return wrapper
