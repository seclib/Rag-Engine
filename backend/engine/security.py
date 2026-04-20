import re
from typing import Tuple

# Define regex patterns for detecting secrets
SECRET_PATTERNS = [
    re.compile(r"AKIA[0-9A-Z]{16}"),  # AWS Access Key
    re.compile(r"-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----"),  # Private Keys
    re.compile(r"[a-zA-Z0-9_-]{20,40}"),  # Generic API Keys
]

def sanitize_content(content: str) -> Tuple[bool, str]:
    """
    Scan content for secrets and return whether it is safe.

    Args:
        content (str): The content to scan.

    Returns:
        Tuple[bool, str]: (is_safe, message)
    """
    for pattern in SECRET_PATTERNS:
        if pattern.search(content):
            return False, "Content contains sensitive information."
    return True, "Content is safe."