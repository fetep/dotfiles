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
