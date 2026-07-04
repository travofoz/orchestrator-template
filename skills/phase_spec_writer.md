# Skill: Phase Spec Writer

## Purpose
Convert a completed SDD or a set of requirements into a clean, ordered set of phase specification files in `future_phases/`. Each file must be independently executable by the inner agent loop and verifiable by the critic gate.

---

## Instructions

Read `planning/sdd.md` Section 11 (Phase Breakdown). For each phase, create a file in `future_phases/` following this contract:

### File Naming
`NN_slug.md` where:
- `NN` is zero-padded execution order (01, 02, ... 99)
- `slug` is a lowercase, underscore-separated descriptor

### File Structure (mandatory for every phase)

```markdown
# Phase NN: <Human-Readable Name>

## Objective
One paragraph. What gets built in this phase and why it matters. 
No forward references to future phases.

## Context
- **Depends on**: Phase NN-1 (or "none" for phase 01)
- **Provides to**: Phase NN+1 (what this phase produces for the next)
- **Working directory**: `project/`

## Tasks
- [ ] Task 1 (specific, atomic, unambiguous)
- [ ] Task 2
- [ ] ...

## Technical Constraints
- List any mandated approaches, libraries, patterns, or anti-patterns
- If a specific algorithm or data structure is required, name it
- Security requirements specific to this phase

## Acceptance Criteria
Numbered list of testable conditions. The critic gate will use these as its checklist.

1. `<specific command or check>` returns `<specific expected result>`
2. ...

## Out of Scope
Explicitly list what NOT to build in this phase. This prevents scope creep.
```

---

## Phase Design Rules

**Sizing**: Each phase should represent 2-4 hours of focused implementation. If it feels bigger, split it.

**Independence**: Each phase must produce a working, testable artifact on its own. No phase should leave the project in a broken state.

**Ordering**:
1. Always start with scaffolding (build system, project structure, smoke test)
2. Data models before business logic
3. Business logic before API/interface layer
4. API layer before integration tests
5. Always end with a full integration test suite

**Task Granularity**: Tasks should be specific enough that an agent reading only this file (with no other context) can implement them correctly. Bad: "Add authentication." Good: "Implement JWT validation middleware that reads the `Authorization: Bearer <token>` header, validates against the HS256 secret in `$JWT_SECRET`, and returns HTTP 401 on failure."

---

## Quality Gates (check before saving each file)
- [ ] Every task is implementable without reading any other file
- [ ] Every acceptance criterion is testable with a specific command or check
- [ ] Out of Scope section is non-empty
- [ ] No task says "implement X" without specifying HOW

---

## Invocation
```bash
# agy
agy --goal "$(cat skills/phase_spec_writer.md)"

# opencode
opencode -p "$(cat skills/phase_spec_writer.md)"
```
