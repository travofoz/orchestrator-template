# Meta-Orchestrator Template

A project-agnostic, clone-and-go scaffolding for the **Sovereign Armory Meta-Orchestrator** — a hierarchical multi-agent supervisor that drives automated build, audit, and remediation cycles using `iteratr` as its inner loop engine and `agy` as its reasoning governor.

## Quickstart

### 1. Clone the template into your workspace

```bash
cp -r orchestrator-template/ my-project-orchestrator/
cd my-project-orchestrator/
```

### 2. Add your phase specifications

Drop your phase spec files into `future_phases/`. Name them with zero-padded numeric prefixes to control execution order:

```bash
future_phases/
├── 01_project_scaffolding.md
├── 02_data_models.md
├── 03_api_layer.md
└── 04_frontend.md
```

Each file should contain:
- A clear **Objective** section
- A **Tasks** section with checkbox items (`- [ ]`)
- **Acceptance Criteria** defining pass conditions

> **Tip:** An example phase file is included at `future_phases/01_example_scaffolding.md` — review it, then remove or replace it with your own.

### 3. Configure the inner engine

Edit `project/config.yaml` to set your preferred model provider, model name, and execution limits.

Edit `project/opencode.json` to customize MCP servers and behavioral instructions for the inner loop agent.

### 4. Launch the supervisor

```bash
chmod +x monitor.sh && agy --goal "$(cat supervisor_goal.md)" --loop
```

Run this inside a persistent `tmux` or `screen` session for unattended execution.

## Architecture

```
.
├── supervisor_goal.md          # Master operational specification (drives agy)
├── monitor.sh                  # Zero-token hardware gatekeeper daemon
├── monitor.status              # Signal gate (auto-generated at runtime)
├── child.pid                   # Background PID tracker (auto-generated)
├── child_exec.log              # Execution capture stream (auto-generated)
├── state.json                  # Pipeline state cache & crash recovery
├── future_phases/              # Pool of upcoming phase specs (*.md)
│   └── 01_example_scaffolding.md
├── specs/                      # Active orchestration directory
│   ├── completed/              # Archive of passing phase specs
│   └── current_phase.md        # Active target (auto-copied from future_phases)
└── project/                    # Isolated execution subdirectory
    ├── config.yaml             # iteratr engine settings
    ├── opencode.json           # Open Code environment parameters
    └── .iteratr/               # Inner worker session database (auto-generated)
        └── logs/
```

## How It Works

1. **State Init**: The supervisor reads `state.json`, recovers from crashes, or loads the next phase from `future_phases/`
2. **Async Deploy**: Launches `iteratr build` as a background daemon inside `project/`, starts `monitor.sh` to watch the PID
3. **Kernel Wait**: Blocks on `inotifywait` — zero tokens consumed while the inner agent works (10-20+ minutes typical)
4. **Critic Gate**: Spawns a fresh, context-blind `agy` instance for adversarial audit — binary PASS/FAIL verdict
5. **Branch**:
   - **PASS** → Archives the spec, advances to the next phase
   - **FAIL** → Generates a clean remediation spec, retries (up to 4 attempts)
6. **Circuit Breaker**: Halts and alerts the human operator after 4 consecutive failures or a timeout

## Customization

| File | Purpose |
|------|---------|
| `supervisor_goal.md` | Edit to change supervisor loop behavior, retry limits, or audit prompts |
| `monitor.sh` | Modify stagnation timeout, add webhook notifications (Discord/Telegram) |
| `state.json` | Adjust `max_remediation_attempts` to change the circuit breaker threshold |
| `project/config.yaml` | Switch model providers, adjust iteration limits |
| `project/opencode.json` | Add MCP servers, change inner agent instructions |

## Prerequisites

- [agy](https://github.com/google/agy) (Antigravity CLI)
- [iteratr](https://github.com/nicholasgasior/iteratr) or compatible inner loop engine
- `inotify-tools` (`sudo apt install inotify-tools`)
- `tmux` or `screen` (recommended for unattended execution)
