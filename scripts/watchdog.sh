#!/bin/bash
# ==============================================================================
# Seclib AI Desktop - Advanced Auto-Healing Watchdog
# ==============================================================================

LOG_FILE="backend/logs/watchdog.log"
STATE_FILE="backend/logs/system_state"
CHECK_INTERVAL=5
MAX_RETRIES=5

# Service Config
API_URL="http://localhost:8000/"
QDRANT_URL="http://localhost:6333/healthz"

# Backoff State
BACKEND_RETRIES=0
DB_RETRIES=0

log_event() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

set_state() {
    echo "$1" > "$STATE_FILE"
    log_event "System state changed to: $1"
}

# Ensure log directory exists
mkdir -p backend/logs
touch "$LOG_FILE"
set_state "STARTING"

echo "🛡️ Watchdog active. Monitoring Seclib AI Desktop..."

while true; do
    sleep $CHECK_INTERVAL
    
    # 1. Check Backend API
    if ! curl -s "$API_URL" >/dev/null; then
        BACKEND_RETRIES=$((BACKEND_RETRIES + 1))
        set_state "DEGRADED"
        log_event "CRITICAL: Backend API unreachable (Attempt $BACKEND_RETRIES/$MAX_RETRIES)"
        
        if [ $BACKEND_RETRIES -le $MAX_RETRIES ]; then
            # Exponential backoff: 2, 4, 8, 16, 32 seconds
            WAIT=$((2 ** BACKEND_RETRIES))
            log_event "RECOVERY: Attempting backend restart in $WAIT seconds..."
            sleep $WAIT
            
            # Kill old if exists
            fuser -k 8000/tcp >/dev/null 2>&1
            
            # Start Backend (assuming we are in project root)
            source backend/env/bin/activate
            PYTHONPATH=. uvicorn backend.main:app --host 0.0.0.0 --port 8000 --log-level warning >> backend/logs/api.log 2>&1 &
            log_event "RECOVERY: Backend restart command issued."
        else
            log_event "FATAL: Backend failed after maximum retries. Manual intervention required."
        fi
    else
        if [ $BACKEND_RETRIES -gt 0 ]; then
            log_event "SUCCESS: Backend recovered."
            BACKEND_RETRIES=0
            set_state "HEALTHY"
        fi
    fi

    # 2. Check Qdrant Database
    if ! curl -s "$QDRANT_URL" | grep -q "ok"; then
        DB_RETRIES=$((DB_RETRIES + 1))
        set_state "DEGRADED"
        log_event "CRITICAL: Qdrant database unresponsive (Attempt $DB_RETRIES/$MAX_RETRIES)"
        
        if [ $DB_RETRIES -le $MAX_RETRIES ]; then
            log_event "RECOVERY: Restarting Qdrant container..."
            docker compose restart qdrant >/dev/null 2>&1
        else
            log_event "FATAL: Database failed after maximum retries."
        fi
    else
        if [ $DB_RETRIES -gt 0 ]; then
            log_event "SUCCESS: Database recovered."
            DB_RETRIES=0
            set_state "HEALTHY"
        fi
    fi
    
    # Final Healthy Check
    if [ $BACKEND_RETRIES -eq 0 ] && [ $DB_RETRIES -eq 0 ]; then
        set_state "HEALTHY"
    fi
done
