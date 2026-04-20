# RAG Engine

RAG Engine est une plateforme modulaire pour la Recherche Augmentée par Génération (Retrieval-Augmented Generation), combinant des composants backend en Python (FastAPI), un frontend web simple, et une architecture extensible pour l'intégration d'agents, de la mémoire, et de la recherche documentaire.

## Fonctionnalités principales
- **Backend Python (FastAPI)** : API REST pour la gestion des requêtes, agents, mémoire, et recherche documentaire.
- **Frontend Web** : Interface utilisateur simple pour interagir avec le moteur RAG.
- **Support des agents** : Intégration d'agents autonomes et de compétences (skills).
- **Recherche documentaire** : Indexation et interrogation de documents via Qdrant.
- **Extensible** : Ajout facile de nouvelles compétences, agents, ou connecteurs de données.

## Structure du projet
```
backend/        # Backend FastAPI, agents, API, logique métier
engine/         # Cœur du moteur RAG, agents, RAG, sécurité, skills
frontend/       # Frontend web (HTML, JS, CSS)
data/           # Données, knowledge base, stockage Qdrant
skills/         # Compétences JSON pour agents
scripts/        # Scripts utilitaires (démarrage, audit, etc.)
```

## Installation

### Prérequis
- Python 3.13+
- Node.js (pour le frontend)
- Docker (optionnel, pour Qdrant ou déploiement)

### Installation rapide
```bash
# Backend (dans backend/)
cd backend
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt

# Frontend (dans frontend/)
cd ../frontend
npm install
```

### Lancer le backend
```bash
cd backend
source env/bin/activate
uvicorn main:app --reload
```

### Lancer le frontend
```bash
cd frontend
npm start
```

### Lancer Qdrant (optionnel)
```bash
docker-compose up -d
```

## Utilisation
- Accédez à l’API via `http://localhost:8000/docs` (Swagger UI)
- Accédez au frontend via `http://localhost:3000`

## Scripts utiles
- `start.sh` : Démarrage rapide de l’ensemble
- `scripts/` : Outils d’audit, de vérification, de nettoyage, etc.

## Contribution
Les contributions sont les bienvenues !
- Forkez le repo, créez une branche, proposez un PR.
- Voir `ARCHITECTURE.md` pour plus de détails sur la structure.

## Licence
MIT
