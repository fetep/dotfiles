## Global Rules

- No EOL whitespace.
- Verify build/lint before reporting done.
- Ask before `sudo`; use it only when root is required.
- Do not assume; ask when context, requirements, conventions, or patterns are unclear.

## Git

- First run `git rev-parse --show-toplevel`; do not assume repo root.
- Run git commands from the repo root, not with `git -C`.
- Never `git push` unless the user asked or confirmed after seeing the push delta.
- Normal push: show local-only commits, e.g. `git log --oneline --decorate @{u}..HEAD`, plus branch/remote context.
- Force push: show remote-vs-local divergence, e.g. left/right log or equivalent summary.

## Per-Project AGENTS.md

Create one if missing. Update it when you discover wrong commands, structure assumptions, dependencies, or setup steps.

## Commit Messages

Use Conventional Commits: `fix|feat|refactor|chore|docs|test|perf|ci|build[(scope)]: <imperative description>`.
Append `!` for breaking changes. Prefer one line; add a body only when needed.

## Commands

- Prefer built-in tools and standard CLI tools over small Python scripts.
- Use `jq` for JSON parsing.
- Set command env vars with `export VAR=value; command`, not `VAR=value command`.
