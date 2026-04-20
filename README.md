# RAG Engine

RAG Engine est une plateforme modulaire pour la Recherche Augmentée par Génération (Retrieval-Augmented Generation), combinant des composants backend en Python (FastAPI), un frontend web simple, et une architecture extensible pour l'intégration d'agents, de la mémoire, et de la recherche documentaire.

## Fonctionnalités principales
- **Backend Python (FastAPI)** : API REST pour la gestion des requêtes, agents, mémoire, et recherche documentaire.
- **Frontend Web** : Interface utilisateur simple pour interagir avec le moteur RAG.
- **Application Desktop** : Version Electron complète avec interface Claude-like, agents autonomes, et packaging professionnel.
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

### Application Desktop (Recommandé)
Téléchargez et installez Seclib AI Desktop depuis les [releases GitHub](https://github.com/your-repo/releases):

#### Windows
- Téléchargez `SeclibAI-Desktop-Setup-x.x.x.exe`
- Lancez l'installeur et suivez les instructions
- L'application s'installe automatiquement avec toutes les dépendances

#### Linux
- Téléchargez `Seclib-AI-Desktop-x.x.x-x86_64.AppImage`
- Rendez le fichier exécutable: `chmod +x Seclib-AI-Desktop-*.AppImage`
- Lancez l'AppImage

#### macOS
- Téléchargez `SeclibAI-Desktop-x.x.x.dmg`
- Ouvrez le DMG et faites glisser l'application dans Applications

### Installation depuis les sources

#### Prérequis
- Python 3.13+
- Node.js (pour le frontend)
- Docker (optionnel, pour Qdrant ou déploiement)

#### Installation rapide
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

#### Lancer le backend
```bash
cd backend
source env/bin/activate
uvicorn main:app --reload
```

#### Lancer le frontend
```bash
cd frontend
npm start
```

### Lancer Qdrant (optionnel)
```bash
docker-compose up -d
```

## Développement et Packaging

### Build de l'application desktop
```bash
# Build pour toutes les plateformes
./build.sh

# Build pour une plateforme spécifique
./build.sh 1.0.0 win    # Windows
./build.sh 1.0.0 linux  # Linux
```

### Gestion des versions
```bash
# Voir la version actuelle
./version.sh current

# Incrémenter la version
./version.sh bump patch  # 1.0.0 → 1.0.1
./version.sh bump minor  # 1.0.0 → 1.1.0

# Définir une version spécifique
./version.sh set 2.0.0
```

Voir `PACKAGING.md` pour plus de détails sur le système de packaging.

## Utilisation
- **Application Desktop** : Lancez Seclib AI Desktop depuis le menu démarrer/raccourci
- **API** : Accédez à l'API via `http://localhost:8000/docs` (Swagger UI)
- **Frontend Web** : Accédez au frontend via `http://localhost:3000`

## Scripts utiles
- `start.sh` : Démarrage rapide de l'ensemble
- `scripts/` : Outils d'audit, de vérification, de nettoyage, etc.
- `build.sh` : Build de l'application desktop
- `version.sh` : Gestion des versions

## Architecture
Voir `ARCHITECTURE.md` pour une description détaillée de l'architecture système.

## Contribution
Les contributions sont les bienvenues !
- Forkez le repo, créez une branche, proposez un PR.
- Voir `ARCHITECTURE.md` pour plus de détails sur la structure.

## Licence
MIT

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
