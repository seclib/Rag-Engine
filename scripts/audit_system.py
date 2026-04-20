import os
from engine.rag import RAGManager
from engine.autonomous_agent import autonomous_agent
from engine.security import security

# We'll use the autonomous agent to "audit" itself and the system
async def run_audit():
    print("--- System Audit Started ---")
    
    # 1. Check for missing packages
    print("Checking __init__.py files...")
    for folder in ["engine", "backend", "skills"]:
        if not os.path.exists(os.path.join(folder, "__init__.py")):
            print(f"MISSING: {folder}/__init__.py")
            
    # 2. Check for duplicate scripts
    print("\nChecking for duplicate scripts...")
    scripts = ["start.sh", "setup.sh", "install.sh"]
    for s in scripts:
        root_path = s
        scripts_path = os.path.join("scripts", s)
        if os.path.exists(root_path) and os.path.exists(scripts_path):
            print(f"DUPLICATE: {root_path} and {scripts_path}")

    # 3. Check for exposed secrets (crude)
    print("\nScanning for secrets...")
    for root, dirs, files in os.walk("."):
        if "env" in dirs: dirs.remove("env") # Skip venv
        if ".git" in dirs: dirs.remove(".git")
        for file in files:
            if file.endswith((".py", ".js", ".sh", ".json", ".yml")):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r') as f:
                        content = f.read()
                        secrets = security.scan_for_secrets(content)
                        if secrets:
                            print(f"SECRET FOUND in {path}: {secrets}")
                except:
                    pass

if __name__ == "__main__":
    import asyncio
    asyncio.run(run_audit())
