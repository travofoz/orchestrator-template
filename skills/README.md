# Skills Index

Reusable prompt skills for the meta-orchestrator planning and execution pipeline.

| Skill | File | When to Use |
|-------|------|-------------|
| **Grill Me** | `grill_me.md` | Before writing any code — extract complete requirements via structured interview |
| **SDD Generator** | `sdd.md` | Convert interview notes or requirements into a full Software Design Document |
| **Phase Spec Writer** | `phase_spec_writer.md` | Break an SDD into ordered, executable phase spec files for `future_phases/` |
| **Code Review** | `code_review.md` | Adversarial PASS/FAIL critic gate — run after each build pass |
| **Retrospective** | `retro.md` | Capture lessons, SDD deltas, and risk signals after each phase completes |

## Recommended Workflow

```
1. [PLAN]    Run grill_me.md    →  Complete requirements interview
2. [DESIGN]  Run sdd.md         →  Produces planning/sdd.md
3. [DECOMP]  Run phase_spec_writer.md  →  Populates future_phases/
4. [EXECUTE] Launch supervisor  →  Runs build + code_review.md loop automatically
5. [LEARN]   Run retro.md       →  After each phase, capture lessons
```

## Invocation Pattern

All skills follow the same pattern:

```bash
# agy
agy --prompt "$(cat skills/<skill>.md)"

# opencode
opencode -p "$(cat skills/<skill>.md)"
```
