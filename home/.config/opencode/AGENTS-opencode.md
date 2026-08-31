# OpenCode Superpowers Routing

These instructions apply only in OpenCode.

## Superpowers skill customization
- Always choose "subagent-driven" to implement plans. Ask if it's ok to start, don't ask for inline or subagent.
- Never stage or commit Superpowers plans or specifications.
- When committing, make as few commits as possible. The atomic commit unit is a set of changes you'd want to rollback
  together. Never split up implementation + tests in different commits.

### Subagent routing (overrides "Subagent (general-purpose)")

Superpowers prompt templates say `Subagent (general-purpose):`, and its Model Selection section requires every
dispatch to name a model. In opencode you cannot: `task` takes only `subagent_type`, and a subagent with no
configured model inherits the caller's (expensive) model. So map the role to a purpose-built subagent instead of
`general`:

| Superpowers role | `subagent_type` |
| --- | --- |
| Implementer, mechanical task: 1-2 files, spec leaves no decisions open | `implementer-fast` |
| Implementer, integration task: multi-file, pattern matching, debugging | `implementer` |
| Per-task review, spec + quality in one pass (`task-reviewer-prompt.md`) | `task-reviewer` |
| Scoped re-review of a fix round (`re-review-prompt.md`) | `task-reviewer` |
| Per-task review of a subtle or high-risk diff (concurrency, security, data loss) | `deep-reviewer` |
| Final whole-branch review (`requesting-code-review/code-reviewer.md`) | `deep-reviewer` |
| Plan / spec document reviewer (writing-plans, brainstorming) | `deep-reviewer` |
| Codebase research and exploration | `explore` |

- Default to `implementer-fast`. Escalate to `implementer` only for the signals above, or when a task returns
  BLOCKED for reasoning (not context) reasons.
- If `implementer` is also BLOCKED for reasoning reasons, escalate to `general` — it inherits my model.
- Re-dispatch the same tier when the blocker was missing context, per the skill.
- Reviewers are read-only and cannot delegate. Fixes always go back to an implementer tier.
- Never dispatch `general` for implementation or review; it is the escalation path of last resort.

**Fix loop (SDD rounds 1-5).** Rounds 1-3 resume the original implementer. opencode supports this natively:
`task` accepts `task_id`, and every dispatch result returns one — record it and resume with the findings verbatim.
The skill's "if your harness cannot send another message to a live subagent" fallback does not apply to us; do not
dispatch a fresh implementer for rounds 1-3. Rounds 4-5 want a fresh implementer one tier up, which is the
`implementer-fast` → `implementer` → `general` ladder above.
