# Skill: Software Design Document (SDD) Generator

## Purpose
Transform raw requirements, interview notes, or a problem statement into a complete, structured Software Design Document ready to drive phase-by-phase execution.

---

## Instructions

You are a principal engineer writing the definitive design document for this system. This document is the source of truth. Every phase spec will derive from it. Be precise and complete — vague design produces broken code.

### Step 1: Parse Inputs
Read any of the following that exist:
- `planning/notes.md` — raw interview notes or brainstorm
- `planning/sdd.md` — partially filled SDD template to complete
- The user's direct prompt describing the system

### Step 2: Produce the SDD

Populate `planning/sdd.md` with the following sections. Do not skip any section. Do not write "TBD".

---

#### 1. Executive Summary
- System name and version
- One-paragraph mission statement
- Primary users / consumers of this system
- Key success metric (how we know this worked)

#### 2. System Context & Boundaries
- What this system does (in scope)
- What this system explicitly does NOT do (out of scope)
- External systems it integrates with (with direction: reads from / writes to)
- System boundary diagram in ASCII or Mermaid

#### 3. Functional Requirements
Numbered list. Each requirement must be:
- Testable (can write a specific pass/fail test)
- Unambiguous (no "fast", "good", "easy" without a number)
- Atomic (one behavior per requirement)

Format: `FR-001: <verb> <object> <condition>`

#### 4. Non-Functional Requirements
- Performance: latency (p50/p95/p99), throughput (req/s or records/s)
- Reliability: uptime target, MTTR, acceptable data loss window
- Security: auth mechanism, data classification, encryption at rest/transit
- Scalability: horizontal/vertical, expected growth rate
- Observability: logs (structured?), metrics (which ones?), traces, alerts

#### 5. Architecture & Design
- High-level component diagram (ASCII or Mermaid)
- Data flow: how data enters, transforms, and exits the system
- Key design decisions and rationale (list alternatives considered)
- Technology stack with justification for each choice

#### 6. Data Model
- Core entities and their attributes
- Relationships between entities
- Schema definitions (table DDL, struct definitions, or JSON Schema as appropriate)
- Data lifecycle: creation, mutation, deletion, retention

#### 7. API / Interface Design
- All public interfaces (REST endpoints, CLI commands, library exports, event schemas)
- Request/response shapes for each
- Authentication and authorization model
- Error response format and error codes

#### 8. Error Handling & Failure Modes
For each external dependency, define:
- What happens when it is unavailable
- Retry strategy (backoff, max attempts)
- Circuit breaker behavior
- What the user/caller experiences

#### 9. Testing Strategy
- Unit test scope and coverage target
- Integration test scenarios (list the critical paths)
- End-to-end test: what a human would do to verify the system works
- Performance test: how to verify NFRs are met

#### 10. Deployment & Operations
- Build artifact type (binary, container image, package)
- Deployment environment and mechanism
- Environment variables / configuration required
- Health check endpoint or liveness probe
- Rollback procedure

#### 11. Phase Breakdown
Decompose the above into an ordered list of independently deliverable phases:

| Phase | Name | Deliverable | Acceptance Test |
|-------|------|-------------|-----------------|
| 01 | Scaffolding | Compiling project skeleton | `make build` exits 0 |
| 02 | Core Models | Data layer with migrations | Schema applies cleanly |
| ... | ... | ... | ... |
| NN | Integration Tests | Full E2E test suite | All tests green |

---

### Step 3: Generate Phase Spec Files
For each phase in Section 11, create the corresponding file in `future_phases/` using the phase spec template (`planning/phase_spec_template.md`).

---

## Invocation
```bash
# agy
agy --goal "$(cat skills/sdd.md)"

# opencode
opencode -p "$(cat skills/sdd.md)"
```
