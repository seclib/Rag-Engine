# Seclib AI Desktop: Production Architecture

Seclib AI Desktop is designed as a local-first, modular AI assistant that integrates advanced reasoning, extensible skills, and high-performance RAG capabilities into a premium desktop experience, similar to Cursor + Claude Desktop + Open WebUI + RAG engine.

## 1. System Architecture Diagram (Text)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            USER INTERFACE                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │   Electron      │  │   React UI      │  │   IPC Bridge    │             │
│  │   Main Process  │  │   (Claude-like) │  │   (Secure Comm) │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
└─────────────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ HTTP/REST + SSE
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          APPLICATION LAYER                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │   FastAPI       │  │   Security      │  │   Agent         │             │
│  │   Backend API   │  │   Middleware    │  │   Orchestrator  │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
└─────────────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ Internal APIs
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INTELLIGENCE LAYER                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │   Skills        │  │   RAG Engine    │  │   Ollama LLM    │             │
│  │   Plugin System │  │   (Qdrant)      │  │   Inference     │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
└─────────────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ Vector Queries
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            DATA LAYER                                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │   Qdrant        │  │   File Storage  │  │   Skills Config │             │
│  │   Vector DB     │  │   (Documents)   │  │   (JSON)        │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
└─────────────────────────────────────────────────────────────────────────────┘

DATA FLOW: User → UI → Backend → Agent → RAG + LLM → Response
```

## 2. Modular Folder Structure

```
/home/fatsio/rag-engine/
├── frontend/                    # Desktop UI & Shell
│   ├── src/
│   │   ├── components/          # React Components (Chat, Sidebar, etc.)
│   │   ├── App.jsx              # Main UI Logic
│   │   └── main.jsx             # React Entry Point
│   ├── main.js                  # Electron Main Process
│   ├── preload.js               # IPC Security Bridge
│   ├── package.json             # Electron + React Dependencies
│   └── vite.config.js           # Build Configuration
├── backend/                     # Application Logic (FastAPI)
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py              # FastAPI App
│   │   ├── routers/             # API Endpoints
│   │   │   ├── chat.py          # Chat/Message Routes
│   │   │   ├── knowledge.py     # RAG Management
│   │   │   └── skills.py        # Skills Management
│   │   ├── core/                # Core Logic
│   │   │   ├── config.py        # Configuration
│   │   │   ├── security.py      # Security Middleware
│   │   │   └── dependencies.py  # Shared Dependencies
│   │   └── services/            # Business Logic
│   │       ├── agent_service.py # Agent Orchestration
│   │       ├── rag_service.py   # RAG Operations
│   │       └── skills_service.py# Skills Management
│   ├── requirements.txt         # Python Dependencies
│   └── Dockerfile               # Backend Container
├── engine/                      # Core Intelligence Engine
│   ├── __init__.py
│   ├── agent.py                 # Agent Reasoning Loop
│   ├── rag.py                   # RAG Implementation
│   ├── skills.py                # Skills Registry & Loader
│   ├── security.py              # Security & Sandboxing
│   └── llm.py                   # LLM Interface (Ollama)
├── skills/                      # Plug-and-Play Skills
│   ├── __init__.py
│   ├── code-analyzer.json       # Skill Definition
│   ├── summarizer.json          # Skill Definition
│   └── bug-fixer.json           # Skill Definition
├── data/                        # Local Data Persistence
│   ├── knowledge/               # Raw Documents for RAG
│   ├── qdrant_storage/          # Vector Database Files
│   ├── ollama_storage/          # LLM Model Storage
│   └── skills_config/           # User Skill Configurations
├── scripts/                     # Lifecycle Management
│   ├── install.sh               # One-command Installer
│   ├── start.sh                 # Application Launcher
│   ├── backend_start.sh         # Backend Service
│   └── electron_start.sh        # Frontend Launcher
├── docker-compose.yml           # Infrastructure Orchestration
├── requirements.txt             # Global Python Requirements
├── LICENSE                      # MIT License
├── README.md                    # Documentation
└── ARCHITECTURE.md              # This File
```

## 3. System Design Explanation

### A. Modular Design Principles
- **Separation of Concerns**: Each layer (UI, Backend, Intelligence, Data) has clear responsibilities
- **Loose Coupling**: Components communicate via well-defined APIs (HTTP/REST, IPC, Internal Interfaces)
- **Scalability**: Services can be scaled independently (e.g., multiple RAG workers, distributed Qdrant)
- **Extensibility**: New skills and features can be added without modifying core code

### B. Data Flow Architecture
1. **User Input**: User types message in Electron UI
2. **UI Processing**: React component sends request via IPC to Electron main process
3. **API Gateway**: Electron forwards to FastAPI backend via HTTP
4. **Security Layer**: Backend validates input, scans for secrets, applies rate limiting
5. **Agent Orchestration**: Agent service analyzes query, selects relevant skills, plans execution
6. **Intelligence Processing**: 
   - RAG retrieves relevant documents from Qdrant
   - Skills inject specialized prompts/behaviors
   - LLM generates response using Ollama
7. **Streaming Response**: Results stream back via SSE to UI for real-time updates

### C. Component Details

#### Frontend (Electron + React)
- **Purpose**: Premium desktop experience with Claude-like UI
- **Technology**: Electron for system integration, React for UI components
- **Features**: Chat interface, file management, skill configuration, streaming responses
- **Production Mode**: No dev tools, optimized builds, secure IPC

#### Backend (FastAPI)
- **Purpose**: API orchestration and business logic
- **Technology**: FastAPI for high-performance async APIs
- **Features**: REST endpoints, WebSocket/SSE for streaming, middleware stack
- **Security**: Input validation, secret detection, request throttling

#### Agent Core
- **Purpose**: Intelligent query processing and decision making
- **Technology**: Python async services
- **Features**: Multi-step reasoning, skill selection, context management
- **Architecture**: Think-Plan-Act loop with pluggable strategies

#### RAG System
- **Purpose**: Knowledge retrieval and augmentation
- **Technology**: Qdrant vector database, sentence transformers
- **Features**: Document ingestion, semantic search, context injection
- **Local-First**: All data stays on user's machine

#### LLM Integration (Ollama)
- **Purpose**: Language model inference
- **Technology**: Ollama for local model serving
- **Features**: Multiple model support, GPU acceleration, streaming responses
- **Fallback**: Can be extended to cloud providers

#### Skills Plugin System
- **Purpose**: Extensible AI capabilities
- **Technology**: JSON-based plugin definitions
- **Features**: Hot-swappable, no-code configuration, version management
- **Examples**: Code analysis, summarization, bug fixing

### D. Production Considerations
- **No Debug Mode**: Production builds remove all development tools and debugging interfaces
- **Local-First**: All processing happens locally, no mandatory cloud dependencies
- **Security**: Multi-layer security with input sanitization and sandboxing
- **Performance**: Async processing, streaming responses, efficient vector search

### E. Optional Cloud Extension Design
The architecture supports optional cloud integration through:
- **Gateway Pattern**: Pluggable LLM providers (Ollama → OpenAI/Anthropic)
- **Sync Layer**: Optional data synchronization for cross-device knowledge
- **Hybrid Mode**: Local processing with cloud fallback for complex queries
- **Configuration**: User opt-in for cloud features, maintaining local-first default

This design creates a robust, extensible AI desktop platform that prioritizes user privacy, performance, and modularity while providing a premium user experience.
