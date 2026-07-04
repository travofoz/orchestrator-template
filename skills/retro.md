# Skill: Phase Retrospective

## Purpose
After a phase completes (PASS or FAIL with circuit breaker), perform a brief retrospective to capture lessons, update the SDD if design decisions changed during implementation, and surface risks for upcoming phases.

---

## Instructions

Read the following files:
- `specs/completed/<phase_name>.md` — the original spec
- `project/audit_report.md` — the critic's verdict and postmortem
- `state.json` — remediation attempt count for this phase

Then write `planning/retro_<phase_name>.md` with the following sections:

---

### 1. Phase Summary
- Phase name and number
- Final verdict (PASS on attempt N)
- Total remediation cycles required

### 2. What Changed During Implementation
List any requirements that turned out to be wrong, underspecified, or impossible as written. For each:
- Original requirement
- What actually got built
- Whether the SDD needs updating

### 3. Bugs Surfaced by the Critic
List every FAIL finding from `audit_report.md`. For each:
- The defect (quoted from the report)
- Root cause (bad spec? bad implementation? missing constraint?)
- How it was resolved in the remediation pass

### 4. Risks for Upcoming Phases
Based on what you learned, list any risks or dependencies that future phases must account for. Be specific — vague warnings are useless.

| Risk | Affected Phases | Mitigation |
|------|----------------|------------|
| ... | ... | ... |

### 5. SDD Updates Required
If any design decisions changed during implementation, list the SDD sections that need updating and what they should say now. Do NOT update the SDD automatically — flag it for human review.

### 6. Confidence Score for Next Phase
Rate your confidence that the next phase spec is accurate and complete:
- **HIGH**: Spec is solid, no known gaps
- **MEDIUM**: One or more assumptions that may not hold — flag them
- **LOW**: Significant uncertainty — recommend running `skills/grill_me.md` before proceeding

---

## Invocation
```bash
# agy
agy --prompt "$(cat skills/retro.md)"

# opencode
opencode -p "$(cat skills/retro.md)"
```
