#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

fixture="$test_root/dotfiles"
overlay="$test_root/dotfiles-cf"
test_home="$test_root/home"
fake_bin="$test_root/bin"

mkdir -p \
  "$fixture/home/.config/opencode" \
  "$fixture/home/.pi/agent" \
  "$fixture/home/.zsh" \
  "$fixture/home-ws" \
  "$overlay/home/.zsh" \
  "$test_home" \
  "$fake_bin"
cp "$repo_root/setup.sh" "$fixture/setup.sh"
printf '# Shared instructions\n' >"$fixture/home/.config/opencode/AGENTS.md"
printf 'public\n' >"$fixture/home/.example"
printf 'public zsh\n' >"$fixture/home/.zsh/shared.zsh"
printf 'public zsh only\n' >"$fixture/home/.zsh/public.zsh"
ln -s ../../.config/opencode/AGENTS.md "$fixture/home/.pi/agent/AGENTS.md"
printf 'cloudflare\n' >"$overlay/home/.example"
printf 'cloudflare only\n' >"$overlay/home/.cf-only"
printf 'cloudflare zsh\n' >"$overlay/home/.zsh/shared.zsh"
printf 'cloudflare zsh only\n' >"$overlay/home/.zsh/cloudflare.zsh"

cat >"$fake_bin/git" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$fake_bin/git"

(
  export DOTFILES_OVERLAY="$overlay"
  export HOME="$test_home"
  export PATH="$fake_bin:/usr/bin:/bin"
  "$fixture/setup.sh" >/dev/null
)

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

if [[ "$(cat "$test_home/.example")" != "cloudflare" ]]; then
  echo "Overlay did not replace the public dotfile" >&2
  exit 1
fi

if [[ "$(cat "$test_home/.cf-only")" != "cloudflare only" ]]; then
  echo "Overlay-only dotfile was not deployed" >&2
  exit 1
fi

if [[ "$(cat "$test_home/.zsh/shared.zsh")" != "cloudflare zsh" ]]; then
  echo "Overlay did not replace the public file in a merged directory" >&2
  exit 1
fi

if [[ "$(cat "$test_home/.zsh/public.zsh")" != "public zsh only" ]]; then
  echo "Public-only file in a merged directory was not deployed" >&2
  exit 1
fi

if [[ "$(cat "$test_home/.zsh/cloudflare.zsh")" != "cloudflare zsh only" ]]; then
  echo "Overlay-only file in a merged directory was not deployed" >&2
  exit 1
fi
