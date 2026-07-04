#!/bin/bash

# Ensure we are in the orchestrator root
cd "$(dirname "$0")"

# Helper function to reset state.json to IDLE
reset_state() {
  cat << 'EOF' > state.json
{
  "pipeline": {
    "active_phase": null,
    "active_phase_source": null,
    "remediation_attempt": 0,
    "max_remediation_attempts": 4,
    "completed_phases": [],
    "status": "IDLE",
    "last_updated": null
  }
}
EOF
}

# Helper function to clean runtime artifacts
clean_artifacts() {
  rm -f child.pid child_exec.log monitor.status project/audit_report.md
  rm -rf project/.agent project/.iteratr
}

# Helper function to clean project source code (keeps only config files)
clean_project_src() {
  find project/ -mindepth 1 -maxdepth 1 \
    ! -name 'config.yaml' \
    ! -name 'opencode.json' \
    -exec rm -rf {} +
}

kill_daemons() {
  if [ -f child.pid ]; then
    kill -9 $(cat child.pid) 2>/dev/null
  fi
  pkill -f monitor.sh 2>/dev/null
}

case "$1" in
  --current)
    echo "Resetting current phase..."
    kill_daemons
    clean_artifacts
    clean_project_src
    
    # Move current spec back to future_phases
    if ls specs/current_phase.md 1> /dev/null 2>&1; then
      # Extract original name from state.json if possible, fallback to a timestamped name
      ORIG_NAME=$(cat state.json | grep active_phase | awk -F'"' '{print $4}' | grep -v 'null' || echo "reverted_phase_$(date +%s).md")
      mv specs/current_phase.md "future_phases/$ORIG_NAME"
    fi
    reset_state
    echo "Current phase reverted to future_phases/."
    ;;
    
  --last)
    echo "Resetting last completed phase..."
    kill_daemons
    # Find the most recently modified file in completed/
    LAST_SPEC=$(ls -t specs/completed/*.md 2>/dev/null | head -n 1)
    if [ -n "$LAST_SPEC" ]; then
      mv "$LAST_SPEC" "future_phases/"
      echo "Reverted $(basename "$LAST_SPEC") to future_phases/."
    else
      echo "No completed phases to revert."
    fi
    # Note: We do NOT wipe project/ for --last because we assume they just want to rebuild the last step on top of the existing codebase.
    ;;
    
  --all)
    echo "Resetting all progress (keeping specs)..."
    kill_daemons
    clean_artifacts
    clean_project_src
    
    # Move everything back
    mv specs/completed/*.md future_phases/ 2>/dev/null
    if ls specs/current_phase.md 1> /dev/null 2>&1; then
      ORIG_NAME=$(cat state.json | grep active_phase | awk -F'"' '{print $4}' | grep -v 'null' || echo "reverted_phase_$(date +%s).md")
      mv specs/current_phase.md "future_phases/$ORIG_NAME"
    fi
    reset_state
    echo "All progress reset. Project wiped, specs retained."
    ;;
    
  --wipe)
    echo "Wiping repository to freshly cloned state..."
    kill_daemons
    clean_artifacts
    clean_project_src
    
    rm -f specs/completed/*.md
    rm -f specs/current_phase.md
    rm -f future_phases/*.md
    reset_state
    echo "Total wipe complete. Ready for new specs."
    ;;
    
  *)
    echo "Usage: ./reset.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  --current  Stops execution, wipes current project work, and reverts the active spec back to future_phases."
    echo "  --last     Reverts the most recently completed phase back to future_phases for re-execution."
    echo "  --all      Wipes all project work and state, but moves all specs back to future_phases."
    echo "  --wipe     Total nuclear wipe. Deletes all project work, state, AND all specs everywhere."
    exit 1
    ;;
esac
