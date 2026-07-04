# Project-Agnostic Meta-Orchestrator Specification

## 0. Agent Runtime Configuration
This orchestrator is tool-agnostic. Set the `AGENT` environment variable before launching:

```bash
# Use agy (Antigravity CLI)
export AGENT="agy --goal"

# Use opencode
export AGENT="opencode -p"
```

The supervisor will use `$AGENT` everywhere it needs to invoke a reasoning engine.
Default if unset: `agy --goal`

---

## 1. Directory Scaffolding & Component Mapping

```
GOVERNANCE WORKING DIRECTORY (.)
├── supervisor_goal.md         <-- This active master operational specification
├── monitor.sh                  <-- Cost-free background hardware telemetry script
├── monitor.status              <-- Hardware status communication signal gate
├── child.pid                   <-- Background process identifier tracking file
├── child_exec.log              <-- Inner loop execution capture stream
├── state.json                  <-- Supervisor memory core (Pipeline state cache)
├── skills/                     <-- Reusable prompt skills for planning & review
│   ├── grill_me.md             <-- Requirements elicitation interview
│   ├── sdd.md                  <-- Software Design Document generator
│   ├── phase_spec_writer.md    <-- SDD → phase spec decomposer
│   ├── code_review.md          <-- Adversarial PASS/FAIL critic gate
│   └── retro.md                <-- Post-phase retrospective
├── planning/                   <-- Design documents and templates
│   ├── sdd_template.md         <-- Blank SDD template
│   ├── phase_spec_template.md  <-- Blank phase spec template
│   └── sdd.md                  <-- Your completed SDD (generated)
├── future_phases/              <-- Pool of upcoming phase spec files (*.md)
├── specs/                      <-- Active orchestration directory
│   ├── completed/              <-- Vault for clean, passing phase specs
│   └── current_phase.md        <-- Active target (auto-copied from future_phases)
└── project/                    <-- TARGET EXECUTION SUBDIRECTORY
    ├── config.yaml             <-- Inner agent engine runtime settings
    ├── opencode.json           <-- OpenCode environment parameters (if using opencode)
    └── .agent/                 <-- Inner worker session data (auto-generated)
```

---

## 2. Core Principles

- **Black-Box Principle**: Treat the inner agent loop as an opaque, stateful actor. Never directly edit files that the inner agent is actively processing.
- **Tool Agnosticism**: The supervisor uses `$AGENT` to invoke any compatible reasoning engine. The inner loop in `project/` may use a different tool than the supervisor.
- **Zero-Mutation Rule**: On FAIL, never touch files inside `project/` or `specs/completed/`. Generate a fresh remediation spec instead.
- **Kernel-Level Wait**: Use `inotifywait` to block at the OS level — never poll in a loop.

---

## 3. Pre-Execution Planning (Optional but Recommended)

Before running the automated loop, use the planning skills to produce high-quality phase specs:

```bash
# Step 1: Interview to extract requirements
$AGENT "$(cat skills/grill_me.md)"

# Step 2: Generate the SDD from interview notes
$AGENT "$(cat skills/sdd.md)"

# Step 3: Decompose SDD into phase specs
$AGENT "$(cat skills/phase_spec_writer.md)"
```

Skip to Section 4 if `future_phases/` already contains your phase spec files.

---

## 4. Automated State-Machine Loop

Execute continuously across all files in `./future_phases/` until the pool is exhausted.

### Step 4.1: State Initialization & Crash Recovery

Read `./state.json`:
- If `active_phase` is non-null → resume at **Step 4.2** (crash recovery)
- If `active_phase` is null → copy the next file from `./future_phases/` (lexicographic order) to `./specs/current_phase.md`, update `./state.json`:

```json
{
  "pipeline": {
    "active_phase": "01_scaffolding.md",
    "active_phase_source": "future_phases/01_scaffolding.md",
    "remediation_attempt": 0,
    "status": "RUNNING",
    "last_updated": "<ISO timestamp>"
  }
}
```

### Step 4.2: Asynchronous Background Deployment & Kernel Lock

1. Launch the inner agent loop as a background daemon:
   ```bash
   cd project && <INNER_AGENT_COMMAND> > ../child_exec.log 2>&1 & echo $! > ../child.pid
   ```
   Where `<INNER_AGENT_COMMAND>` depends on the inner tool configured in `project/`:
   - **iteratr**: `iteratr build -s ../specs/current_phase.md --headless`
   - **opencode**: `opencode run ../specs/current_phase.md`
   - **agy**: `agy --goal "$(cat ../specs/current_phase.md)"`

2. Start the hardware gatekeeper:
   ```bash
   ./monitor.sh &
   ```

3. **Kernel-Level Wait Block — DO NOT TIME OUT**:
   ```bash
   inotifywait -q -e modify monitor.status
   ```
   This blocks at the Linux kernel level until `monitor.sh` writes to `monitor.status`. It may take 10–30+ minutes. This is expected. Do not interpret silence as a hang.

### Step 4.3: Zero-Bias Isolated Critic Gate

Once `inotifywait` releases, read `./monitor.status`:

- `TRIGGER_LLM_TIMEOUT` → skip to **Step 4.4 BRANCH B** (treat as automatic FAIL)
- `TRIGGER_LLM_CRASH` → skip to **Step 4.4 BRANCH B** (treat as automatic FAIL)
- `TRIGGER_LLM_SUCCESS` → spawn a fresh, context-blind critic:

```bash
AGENT="${AGENT:-agy --goal}"
$AGENT "$(cat skills/code_review.md)"
```

The critic writes its verdict to `project/audit_report.md`.

### Step 4.4: Control Branching

Read the **first line** of `project/audit_report.md`:

**BRANCH A — `VERDICT: PASS`**
1. `mv ./specs/current_phase.md ./specs/completed/`
2. Update `./state.json`: set `active_phase` to null, append phase to `completed_phases[]`, set `status` to `IDLE`
3. Run retrospective: `$AGENT "$(cat skills/retro.md)"`
4. Loop back to **Step 4.1**

**BRANCH B — `VERDICT: FAIL`**
1. Read `project/audit_report.md` — extract every defect
2. Increment `remediation_attempt` in `./state.json`
3. Check circuit breaker: if `remediation_attempt >= max_remediation_attempts` → **Step 4.5**
4. **Zero-Mutation Step**: Do NOT touch `project/` or `specs/completed/`. Overwrite `specs/current_phase.md` with a fresh remediation spec:
   - Header: `# Remediation Pass N: <phase name>`
   - Translate every critic defect into an unchecked task: `- [ ] Fix: <exact defect>`
5. Loop back to **Step 4.2**

### Step 4.5: Circuit Breaker Intervention

Halt all processes and alert the operator when:
- `remediation_attempt >= max_remediation_attempts` (default: 4)
- `monitor.status` contains `TRIGGER_LLM_TIMEOUT`

```bash
# Kill any background processes
kill $(cat child.pid) 2>/dev/null

# Dump process tree for debugging
ps aux | grep -E "iteratr|opencode|agy"

# Alert operator
echo "========================================================"
echo "CIRCUIT BREAKER TRIPPED: $(date)"
echo "Phase: $(cat state.json | python3 -m json.tool | grep active_phase)"
echo "See project/audit_report.md for last critic findings."
echo "Manual intervention required."
echo "========================================================"
```

Options after circuit breaker:
1. Manually fix the issue in `project/` and reset `remediation_attempt` to 0 in `state.json`
2. Run `$AGENT "$(cat skills/grill_me.md)"` to re-examine the spec that keeps failing
3. Abandon the phase: move `specs/current_phase.md` to `specs/failed/` and update `state.json`

---

## 5. Launch Command

```bash
# Set your agent tool
export AGENT="agy --goal"        # or: export AGENT="opencode -p"

# Launch the supervisor loop
chmod +x monitor.sh && $AGENT "$(cat supervisor_goal.md)"
```
