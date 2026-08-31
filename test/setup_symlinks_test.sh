#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

fixture="$test_root/dotfiles"
test_home="$test_root/home"
fake_bin="$test_root/bin"

mkdir -p \
  "$fixture/home/.config/opencode" \
  "$fixture/home/.pi/agent" \
  "$fixture/home-ws" \
  "$test_home" \
  "$fake_bin"
cp "$repo_root/setup.sh" "$fixture/setup.sh"
printf '# Shared instructions\n' >"$fixture/home/.config/opencode/AGENTS.md"
ln -s ../../.config/opencode/AGENTS.md "$fixture/home/.pi/agent/AGENTS.md"

cat >"$fake_bin/git" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$fake_bin/git"

HOME="$test_home" PATH="$fake_bin:/usr/bin:/bin" "$fixture/setup.sh" >/dev/null

pi_agents="$test_home/.pi/agent/AGENTS.md"
if [[ ! -L "$pi_agents" ]]; then
  echo "Pi AGENTS.md was not deployed as a symlink" >&2
  exit 1
fi

actual_target="$(readlink -f "$pi_agents")"
expected_target="$fixture/home/.config/opencode/AGENTS.md"
if [[ "$actual_target" != "$expected_target" ]]; then
  echo "Pi AGENTS.md resolves to $actual_target, expected $expected_target" >&2
  exit 1
fi
