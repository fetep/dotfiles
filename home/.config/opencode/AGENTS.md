## Global Rules

| Rule | Reason |
|------|--------|
| No EOL whitespace | Clean diffs |
| Never `git push` | Manual review before push |
| Verify build/lint passes before reporting done | Catch errors early |

## Per-Project AGENTS.md

Create `AGENTS.md` in any project lacking one. Update it when you discover:
- Incorrect build/test/lint commands
- Wrong assumptions about project structure
- Missing dependencies or setup steps

This saves tokens and prevents repeated mistakes across sessions.

## Commit Messages

Use Conventional Commits: `<type>[(scope)]: <description>`

Core types: `fix`, `feat`, `refactor`, `chore`, `docs`, `test`, `perf`, `ci`, `build`
Breaking changes: append `!` (e.g., `feat!:` or `feat(api)!:`)
Keep descriptions brief, imperative mood.

## Handling Unknowns

If you can't find or don't know something, don't assume. Ask me.

When building a plan or executing a task and an unknown comes up — missing
context, ambiguous requirements, unclear conventions, unfamiliar patterns —
stop and ask rather than guessing. Present a recommended default and
options when possible, but never assume and continue without confirmation.

## Using git

- Never run `git -C dir command`, always run `cd dir && git command`.
- Never assume what the git root is based on the directory structure, ALWAYS run `git rev-parse --show-toplevel`.
- Never run `git push` without having the user ask for it or confirm. Some commands (e.g. `/fix-mr`) say to run git push, do not.

## Setting environment variables

To set environment variables for a command, set them with export and then run the command. Don't prepend them
on a command.

Bad:
```bash
ENV=val command
```

Good:
```bash
export ENV=val; command
```

## Preferred commands

- Use `jq` over `python3 -c "import json..."` to parse JSON.
- In general, do not write small python scripts to get work done, try to use either built-in tool calls or standard CLI tools.
