import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, readFileSync, rmSync, symlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const picker = fileURLToPath(new URL('../../home/bin/sesh-picker', import.meta.url));
const mock = `#!/usr/bin/env bash
set -euo pipefail
command_name="\${0##*/}"
printf '%s\\n' "$command_name$(printf ' <%s>' "$@")" >> "$TEST_DIR/calls"
case "$command_name:$1" in
    sesh:list) printf 'project\\n' ;;
    sesh:connect)
        if [[ -f "$TEST_DIR/connected" ]]; then
            exit 42 # Stop the outer loop after returning to the sesh picker.
        fi
        touch "$TEST_DIR/connected"
        ;;
    gum:filter) cat ;;
    tmux:has-session)
        count=0
        if [[ -f "$TEST_DIR/attaches" ]]; then
            read -r count < "$TEST_DIR/attaches"
        fi
        (( count < NATIVE_ATTACHES ))
        ;;
    tmux:attach-session)
        count=0
        if [[ -f "$TEST_DIR/attaches" ]]; then
            read -r count < "$TEST_DIR/attaches"
        fi
        echo "$((count + 1))" > "$TEST_DIR/attaches"
        exit "$ATTACH_STATUS"
        ;;
    *) exit 99 ;;
esac
`;

function runPicker(t, { inside = false, attaches = 0, attachStatus = 0 } = {}) {
  const dir = mkdtempSync(join(tmpdir(), 'sesh-picker-test-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  writeFileSync(join(dir, 'mock'), mock, { mode: 0o755 });
  for (const command of ['sesh', 'gum', 'tmux']) {
    symlinkSync('mock', join(dir, command));
  }
  const result = spawnSync('bash', [picker, '--tmux'], {
    env: {
      ...process.env,
      PATH: `${dir}:${process.env.PATH}`,
      TMUX: inside ? '/mock/tmux,1,0' : '',
      TEST_DIR: dir,
      NATIVE_ATTACHES: String(attaches),
      ATTACH_STATUS: String(attachStatus),
    },
    encoding: 'utf8',
    timeout: 5000,
  });
  assert.ifError(result.error);
  assert.equal(result.status, inside ? 0 : 42, result.stderr);
  return readFileSync(join(dir, 'calls'), 'utf8').trim().split('\n');
}

const nativeAttach = 'tmux <attach-session> <;> <choose-window>';

test('inside tmux, switch once without attaching or opening the native chooser', (t) => {
  const calls = runPicker(t, { inside: true, attaches: 2 });
  assert.equal(calls.filter((line) => line === 'sesh <connect> <project>').length, 1);
  assert.ok(calls.includes('sesh <list> <--icons> <--tmux>'));
  assert.ok(!calls.some((line) => line.startsWith('tmux ')));
});

test('after a session ends, attach with the native window chooser', (t) => {
  const calls = runPicker(t, { attaches: 1 });
  const connected = calls.indexOf('sesh <connect> <project>');
  const attached = calls.indexOf(nativeAttach);
  assert.ok(attached > connected);
  assert.equal(calls.filter((line) => line === nativeAttach).length, 1);
});

test('keep using the native chooser until no tmux sessions remain', (t) => {
  const calls = runPicker(t, { attaches: 2 });
  assert.equal(calls.filter((line) => line === nativeAttach).length, 2);
  assert.equal(calls.filter((line) => line.startsWith('gum ')).length, 2);
  assert.ok(calls.lastIndexOf(nativeAttach) < calls.lastIndexOf('sesh <connect> <project>'));
});

test('with no remaining sessions, return directly to the sesh picker', (t) => {
  const calls = runPicker(t);
  assert.ok(!calls.includes(nativeAttach));
  assert.equal(calls.filter((line) => line.startsWith('gum ')).length, 2);
});

test('if attaching fails, return to the sesh picker instead of exiting', (t) => {
  const calls = runPicker(t, { attaches: 2, attachStatus: 1 });
  assert.equal(calls.filter((line) => line === nativeAttach).length, 1);
  assert.equal(calls.filter((line) => line.startsWith('gum ')).length, 2);
});
