#!/bin/bash
# monitor.sh - Zero-Token Hardware Monitor Daemon

CHILD_PID=$(cat child.pid)
LOG_FILE="child_exec.log"
JETSTREAM_LOG="project/.iteratr/logs/jetstream.log"
STAGNATION_TIMEOUT=300 # 5 minutes execution threshold

echo "[*] Telemetry daemon active. Locking onto PID: $CHILD_PID"

while true; do
    # 1. Check if the inner builder process has died naturally
    if ! kill -0 "$CHILD_PID" 2>/dev/null; then
        wait "$CHILD_PID"
        EXIT_CODE=$?
        echo "[!] Execution terminated. Code: $EXIT_CODE"
        
        if [ $EXIT_CODE -eq 0 ]; then
            echo "TRIGGER_LLM_SUCCESS" > monitor.status
        else
            echo "TRIGGER_LLM_CRASH" > monitor.status
        fi
        break
    fi

    # 2. Check if the log files have frozen (Stagnation/Hallucination Loop)
    if [ -f "$JETSTREAM_LOG" ]; then
        LAST_MOD=$(stat -c %Y "$JETSTREAM_LOG" 2>/dev/null)
        CURRENT_TIME=$(date +%s)
        IDLE_TIME=$((CURRENT_TIME - LAST_MOD))

        if [ "$IDLE_TIME" -gt "$STAGNATION_TIMEOUT" ]; then
            echo "[!] CRITICAL: Engine stagnation caught at $IDLE_TIME seconds."
            kill -9 "$CHILD_PID"
            echo "TRIGGER_LLM_TIMEOUT" > monitor.status
            break
        fi
    fi

    # Sleep 15 seconds. Cost: 0 API tokens.
    sleep 15
done
