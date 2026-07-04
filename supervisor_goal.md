# Project-Agnostic Meta-Orchestrator Specification (Lean Edition)

## 1. Directory Scaffolding & Component Mapping
The architecture enforces a strict nested hierarchy separating the macro-governor (parent directory) from the isolated code-generation environment (child directory).

===============================================================================
GOVERNANCE WORKING DIRECTORY (.)
├── supervisor_goal.md         <-- This active master operational specification
├── monitor.sh                  <-- Cost-free background hardware telemetry script
├── monitor.status              <-- Hardware status communication signal gate
├── child.pid                   <-- Background process identifier tracking file
├── state.json                  <-- Supervisor memory core (Pipeline state cache)
├── future_phases/              <-- Pool of upcoming requirement files (*.md)
├── specs/                      <-- Active orchestration directory
│   ├── completed/              <-- Vault for clean, passing phase specifications
│   └── current_phase.md        <-- Copied target phase under active execution
└── project/                    <-- TARGET EXECUTION SUBDIRECTORY (./project)
    ├── config.yaml             <-- Local 'iteratr' engine runtime settings
    ├── opencode.json           <-- Open Code environment setting parameters
    └── .iteratr/               <-- Inner worker's session database arrays
===============================================================================

## 2. Core 'iteratr' & Environment Principles
- **Black-Box Principle**: Treat the inner loop engine as an opaque, stateful actor. Never directly edit, modify, or append strings to files that `iteratr` is actively processing.
- **Behavior Controls**: Global execution behaviors are strictly governed by `project/config.yaml` and `project/opencode.json`.
- **Headless Calling Syntax**: Invoke the headless inner loop engine strictly by targeting the current phase specification with the explicit input flag: `iteratr build -s ../specs/current_phase.md --headless`

## 3. Automated State-Machine Loop Protocols
Execute the following steps continuously across all files stored inside `./future_phases/` until the pipeline pool is entirely exhausted:

### Step 3.1: State Initialization & Crash Recovery Check
1. Read `./state.json` to check for an existing execution checkpoint.
   - If an active phase is recorded, resume directly at **Step 3.2** using that file to recover from a previous system crash.
   - If no checkpoint exists, locate the next file in `./future_phases/`, copy it to `./specs/current_phase.md`, and update `./state.json` with the new active target metadata.

### Step 3.2: Asynchronous Background Deployment & Infinite Lock
1. Launch the inner developer agent loop as a background daemon process inside the sub-folder context, piping standard outputs to a local capture stream:
   ```bash
   cd project && iteratr build -s ../specs/current_phase.md --headless > ../child_exec.log 2>&1 & echo $! > ../child.pid
   ```
2. Instantly execute the hardware watcher script to monitor the process:
   ```bash
   ./monitor.sh &
   ```
3. **The Kernel-Level Wait Block (Do Not Time Out)**: Execute this precise command to pass thread control completely to the Linux kernel via filesystem hooks:
   ```bash
   inotifywait -q -e modify monitor.status
   ```
   *CRITICAL RUNTIME DIRECTIVE: This command will lock the shell thread indefinitely (often taking 10 to 20+ minutes) while the inner loop compiles, cross-assembles, and runs tests. You MUST NOT interpret this long blocking period as a terminal hang, error, or session timeout. Stand down your internal execution timer entirely. The command will release naturally the exact millisecond the background gatekeeper updates the status.*

### Step 3.3: The Zero-Bias Isolated Critic Gate
Once the `inotifywait` block releases, read `./monitor.status`. If process death is confirmed, spawn a completely separate, one-shot, non-interactive `agy` call to execute a cold audit. This critic has zero awareness of the supervisor's historical timeline and zero incentive to cheat:
```bash
agy --goal "Act as a brutal, adversarial forensic systems auditor. Analyze the entire codebase inside project/. Verify absolute alignment against the requirements outlined in specs/current_phase.md. You must evaluate using a strict binary PASS or FAIL framework. Write your explicit final verdict in the first line of project/audit_report.md as exactly 'VERDICT: PASS' or 'VERDICT: FAIL', followed by a detailed technical postmortem. CRITIC AUTOMATIC FAILURE MANDATES: You must return a FAIL if you find any placeholder logic, incomplete methods, comments like '// TODO' or '// Stub', hardcoded mock data, thread-safety violations, or unhandled exceptions."
```

### Step 3.4: Control Branching via Remediation Cascades
Analyze the first line within `project/audit_report.md` to process the binary verdict:

- **BRANCH A: VERDICT: PASS**
  1. Archive the milestone: `mv ./specs/current_phase.md ./specs/completed/`
  2. Wipe the active target fields in `./state.json` to mark the phase cleared.
  3. Cycle clean and advance back to **Step 3.1** to process the next phase.

- **BRANCH B: VERDICT: FAIL**
  1. Extract the explicit bugs and structural omissions from `project/audit_report.md`.
  2. **The Zero-Mutation Step**: Do not touch, alter, or edit any files inside `./project/` or `./specs/completed/`. Overwrite `./specs/current_phase.md` with a completely fresh, brand-new specification containing a clean `# Tasks` markdown header, translating the critic's exact complaints into uncompleted checkboxes (`- [ ]`).
  3. Recycle back directly to **Step 3.2** to run a clean remediation patch pass. Limit these cycles to 4 attempts per phase before tripping the circuit breaker.

### Step 3.5: Circuit Breaker Intervention
Halt all automated procedures, dump process trees, and broadcast an explicit alert terminal block to the human operator if:
- A single phase triggers 4 consecutive remediation specification attempts without hitting a 'PASS' verdict.
- The monitor status file flags a `TRIGGER_LLM_TIMEOUT` (the inner loop engine hung).
