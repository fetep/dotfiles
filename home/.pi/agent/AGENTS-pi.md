# Pi Superpowers Routing

These instructions apply only when Pi starts with `PI_SP_ENABLE=true`.

## Plan execution

- Always use subagent-driven development to implement plans.
- Ask whether it is okay to start; do not ask whether to use inline or subagent execution.
- Never stage or commit Superpowers plans or specifications.
- Keep implementation and tests in the same atomic commit when commits are requested.

## Role routing

| Superpowers role | Pi agent |
| --- | --- |
| Mechanical implementation: 1–2 files, complete specification, no open decisions | `implementer-fast` |
| Integration implementation: multi-file coordination, pattern matching, or debugging | `implementer` |
| Repeated reasoning failure or fresh rounds 4–5 escalation | `implementer-deep` |
| Per-task review or scoped re-review | `task-reviewer` |
| Subtle or high-risk review | `deep-reviewer` |
| Final whole-branch review | `deep-reviewer` |
| Plan or specification review | `deep-reviewer` |
| Codebase research and exploration | `explore` |

Default to `implementer-fast`. Escalate only when the task matches the next tier or a child is blocked for reasoning. Missing-context blockers resume at the same tier with corrected context. Reviewers are read-only and cannot delegate; fixes always return to an implementer.

## Fix loop

For rounds 1–3, resume the original retained implementer with reviewer findings verbatim. In a workflow use a new stable key with `runs.run(key, { resume: retainedRunId, task: findings })`; outside a workflow use `subagent({ action: "resume", id: retainedRunId, message: findings })`. Resume only children reported resumable by `subagent({ action: "children.list" })`.

For rounds 4–5, launch a fresh child at the next tier: `implementer-fast` → `implementer` → `implementer-deep`. Stop after round 5 and report unresolved findings. Keep one writer per working tree.
