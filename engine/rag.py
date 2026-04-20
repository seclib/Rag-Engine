import os
import httpx
from typing import List
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct

class RAGManager:
    def __init__(self):
        self.knowledge_base_path = "data/knowledge"
        base_ollama_url = os.getenv("OLLAMA_URL", "http://localhost:11434")
        self.ollama_url = f"{base_ollama_url}/api/embeddings"
        self.model = "qwen2.5-coder:7b"
        
        if not os.path.exists(self.knowledge_base_path):
            os.makedirs(self.knowledge_base_path)
            
        # Connect to Dockerized Qdrant
        qdrant_url = os.getenv("QDRANT_URL", "http://localhost:6333")
        self.client = QdrantClient(url=qdrant_url)
        try:
            self._init_collection()
        except Exception as e:
            print(f"⚠️ Warning: Could not connect to Qdrant at startup: {e}")
            print("RAG features will be limited until Qdrant is active.")

    def _init_collection(self):
        try:
            collections = self.client.get_collections().collections
            exists = any(c.name == "seclib_knowledge" for c in collections)
            if not exists:
                self.client.create_collection(
                    collection_name="seclib_knowledge",
                    vectors_config=VectorParams(size=1536, distance=Distance.COSINE),
                )
        except Exception as e:
            raise ConnectionError(f"Qdrant connection failed: {e}")

    async def _get_embedding(self, text: str) -> List[float]:
        async with httpx.AsyncClient() as client:
            try:
                response = await client.post(
                    self.ollama_url,
                    json={"model": self.model, "prompt": text},
                    timeout=30.0
                )
                return response.json().get("embedding", [])
            except Exception as e:
                print(f"Embedding error: {e}")
                return []

    async def add_source(self, filename: str, content: bytes):
        # 1. Save file
        file_path = os.path.join(self.knowledge_base_path, filename)
        with open(file_path, "wb") as f:
            f.write(content)
        
        # 2. Extract Text (Simplified for now: assumes UTF-8 text)
        try:
            text = content.decode("utf-8")
        except:
            text = "[Non-text content or binary file]"

        # 3. Generate Embedding
        vector = await self._get_embedding(text[:2000]) # Chunking would happen here in production
        
        # 4. Upsert to Qdrant
        if vector:
            self.client.upsert(
                collection_name="seclib_knowledge",
                points=[
                    PointStruct(
                        id=hash(filename) % (10**10), 
                        vector=vector, 
                        payload={"filename": filename, "content": text[:500]}
                    )
                ]
            )
        return True

    async def query_rag(self, query: str, top_k: int = 3) -> str:
        vector = await self._get_embedding(query)
        if not vector:
            return ""
            
        results = self.client.query_points(
            collection_name="seclib_knowledge",
            query=vector,
            limit=top_k
        ).points
        
        contexts = [r.payload.get("content", "") for r in results]
        return "\n---\n".join(contexts)

    def remove_source(self, filename: str):
        path = os.path.join(self.knowledge_base_path, filename)
        if os.path.exists(path):
            os.remove(path)
            # Remove from Qdrant
            # (In a real app, we'd use a better ID management)
            return True
        return False

    async def rebuild_index(self):
        # Clear collection and re-index everything in knowledge_base_path
        self.client.delete_collection("seclib_knowledge")
        self._init_collection()
        for filename in os.listdir(self.knowledge_base_path):
            file_path = os.path.join(self.knowledge_base_path, filename)
            with open(file_path, "rb") as f:
                await self.add_source(filename, f.read())
        return True

    def list_sources(self) -> List[str]:
        return os.listdir(self.knowledge_base_path)
