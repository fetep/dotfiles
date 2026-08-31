import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, rmSync, symlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, resolve } from 'node:path';
import test, { after } from 'node:test';
import { fileURLToPath } from 'node:url';

import superpowersToggle from '../../home/.pi/agent/extensions/superpowers-toggle.ts';

const testDir = dirname(fileURLToPath(import.meta.url));
const repoPiInstructions = resolve(testDir, '../../home/.pi/agent/AGENTS-pi.md');
const fixtureAgentDir = mkdtempSync(resolve(tmpdir(), 'pi-superpowers-fixture-'));
const fixtureSkillDir = resolve(
  fixtureAgentDir,
  'git/github.com/obra/superpowers/skills/using-superpowers',
);
mkdirSync(fixtureSkillDir, { recursive: true });
writeFileSync(
  resolve(fixtureSkillDir, 'SKILL.md'),
  '---\nname: using-superpowers\n---\n\nUse applicable skills.\n',
);
symlinkSync(repoPiInstructions, resolve(fixtureAgentDir, 'AGENTS-pi.md'));
after(() => rmSync(fixtureAgentDir, { recursive: true, force: true }));

function createHarness(enableValue, agentDir = fixtureAgentDir) {
  const commands = new Map();
  const handlers = new Map();
  const notifications = [];
  const statuses = [];

  const pi = {
    on(event, handler) {
      const eventHandlers = handlers.get(event) ?? [];
      eventHandlers.push(handler);
      handlers.set(event, eventHandlers);
    },
    registerCommand(name, options) {
      commands.set(name, options.handler);
    },
  };

  const ctx = {
    ui: {
      notify(text, level) {
        notifications.push({ text, level });
      },
      setStatus(key, text) {
        statuses.push({ key, text });
      },
    },
  };

  const originalEnableValue = process.env.PI_SP_ENABLE;
  const originalAgentDir = process.env.PI_CODING_AGENT_DIR;
  process.env.PI_CODING_AGENT_DIR = agentDir;
  if (enableValue === undefined) delete process.env.PI_SP_ENABLE;
  else process.env.PI_SP_ENABLE = enableValue;

  try {
    superpowersToggle(pi);
  } finally {
    if (originalEnableValue === undefined) delete process.env.PI_SP_ENABLE;
    else process.env.PI_SP_ENABLE = originalEnableValue;
    if (originalAgentDir === undefined) delete process.env.PI_CODING_AGENT_DIR;
    else process.env.PI_CODING_AGENT_DIR = originalAgentDir;
  }

  return { commands, ctx, handlers, notifications, statuses };
}

async function emit(harness, event, payload = {}) {
  let current = payload;
  for (const handler of harness.handlers.get(event) ?? []) {
    const result = await handler(current, harness.ctx);
    if (result?.messages) current = { ...current, messages: result.messages };
  }
  return current;
}

test('PI_SP_ENABLE=true enables Superpowers for the whole process', async () => {
  const harness = createHarness('true');
  await emit(harness, 'session_start', { reason: 'startup' });

  assert.deepEqual(harness.statuses.at(-1), {
    key: 'superpowers-toggle',
    text: 'superpowers:on',
  });

  const discover = harness.handlers.get('resources_discover')[0];
  const result = await discover({ reason: 'startup' }, harness.ctx);
  assert.equal(result.skillPaths.length, 1);
  assert.match(result.skillPaths[0], /superpowers\/skills$/);
});

for (const value of [undefined, '', '0', 'false', 'TRUE', 'yes', 'on']) {
  test(`PI_SP_ENABLE=${String(value)} disables Superpowers`, async () => {
    const harness = createHarness(value);
    await emit(harness, 'session_start', { reason: 'startup' });

    assert.deepEqual(harness.statuses.at(-1), {
      key: 'superpowers-toggle',
      text: 'superpowers:off',
    });

    const discover = harness.handlers.get('resources_discover')[0];
    assert.equal(await discover({ reason: 'startup' }, harness.ctx), undefined);

    const result = await emit(harness, 'context', { messages: [] });
    assert.deepEqual(result.messages, []);
  });
}

test('PI_SP_ENABLE=1 enables Superpowers', async () => {
  const harness = createHarness('1');
  await emit(harness, 'session_start', { reason: 'startup' });
  assert.equal(harness.statuses.at(-1).text, 'superpowers:on');
});

test('enabled sessions inject the bootstrap and custom guidance', async () => {
  const harness = createHarness('true');
  await emit(harness, 'session_start', { reason: 'startup' });

  const result = await emit(harness, 'context', { messages: [] });

  assert.equal(result.messages.length, 1);
  assert.match(result.messages[0].content[0].text, /You have superpowers/);
  assert.match(result.messages[0].content[0].text, /Pi Superpowers Routing/);
  assert.match(result.messages[0].content[0].text, /implementer-deep/);
  assert.doesNotMatch(result.messages[0].content[0].text, /task_id/);
});

test('disabled sessions do not inject Pi-specific routing', async () => {
  const harness = createHarness('false');
  await emit(harness, 'session_start', { reason: 'startup' });
  const result = await emit(harness, 'context', { messages: [] });
  assert.deepEqual(result.messages, []);
  assert.equal(harness.notifications.length, 0);
});

test('missing Pi instructions show one visible warning per session', async () => {
  const emptyAgentDir = mkdtempSync(resolve(tmpdir(), 'pi-superpowers-'));
  try {
    const harness = createHarness('true', emptyAgentDir);
    await emit(harness, 'session_start', { reason: 'startup' });
    await emit(harness, 'context', { messages: [] });
    await emit(harness, 'context', { messages: [] });

    assert.deepEqual(harness.notifications, [{
      text: `Unable to load Pi Superpowers instructions: ${resolve(emptyAgentDir, 'AGENTS-pi.md')}`,
      level: 'warning',
    }]);
  } finally {
    rmSync(emptyAgentDir, { recursive: true });
  }
});

test('bootstrap injection stops after the first enabled agent run', async () => {
  const harness = createHarness('true');
  await emit(harness, 'session_start', { reason: 'startup' });
  await emit(harness, 'context', { messages: [] });
  await emit(harness, 'agent_end', { messages: [] });

  const userMessage = {
    role: 'user',
    content: [{ type: 'text', text: 'next prompt' }],
    timestamp: 2,
  };
  const result = await emit(harness, 'context', { messages: [userMessage] });

  assert.deepEqual(result.messages, [userMessage]);
});

test('commands explain how to disable Superpowers on restart', async () => {
  const harness = createHarness('true');

  assert.deepEqual([...harness.commands.keys()].sort(), ['sp', 'superpower', 'superpowers']);
  for (const command of harness.commands.values()) {
    await command('', harness.ctx);
  }

  assert.equal(harness.notifications.length, 3);
  assert.equal(harness.notifications[0].text, 'Restart Pi with: PI_SP_ENABLE=false pi');
});

test('commands explain how to enable Superpowers on restart', async () => {
  const harness = createHarness();

  await harness.commands.get('sp')('', harness.ctx);

  assert.deepEqual(harness.notifications, [{
    text: 'Restart Pi with: PI_SP_ENABLE=true pi',
    level: 'info',
  }]);
});
