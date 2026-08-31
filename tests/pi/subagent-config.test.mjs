import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFileSync, readlinkSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const testDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(testDir, '../..');
const agentDir = resolve(repoRoot, 'home/.pi/agent/agents');
const expected = {
  'implementer-fast': ['openai-codex/gpt-5.6-sol', 'low'],
  implementer: ['openai-codex/gpt-5.6-sol', 'medium'],
  'implementer-deep': ['openai-codex/gpt-5.6-sol', 'high'],
  'task-reviewer': ['openrouter/google/gemini-3.7-flash', 'medium'],
  'deep-reviewer': ['openrouter/x-ai/grok-4.6', 'high'],
  explore: ['openrouter/z-ai/glm-5.3-flash', 'low'],
};
const expectedFallbacks = {
  'implementer-fast': ['openrouter/openai/gpt-5.6-sol'],
  implementer: ['openrouter/openai/gpt-5.6-sol'],
  'implementer-deep': ['openrouter/openai/gpt-5.6-sol'],
  'task-reviewer': ['openrouter/z-ai/glm-5.3:low'],
  'deep-reviewer': ['openrouter/moonshotai/kimi-k3:high'],
  explore: ['openrouter/google/gemini-3.7-flash:low'],
};
const expectedTools = {
  'implementer-fast': 'read, grep, find, ls, bash, edit, write, contact_supervisor',
  implementer: 'read, grep, find, ls, bash, edit, write, contact_supervisor',
  'implementer-deep': 'read, grep, find, ls, bash, edit, write, contact_supervisor',
  'task-reviewer': 'read, grep, find, ls',
  'deep-reviewer': 'read, grep, find, ls',
  explore: 'read, grep, find, ls, bash',
};

function readAgent(name) {
  const text = readFileSync(resolve(agentDir, `${name}.md`), 'utf8');
  const parts = text.split('---');
  assert.equal(parts[0], '');
  assert.ok(parts.length >= 3, `${name} has Markdown frontmatter`);

  const frontmatter = {};
  let listKey;
  for (const line of parts[1].trim().split('\n')) {
    const listItem = line.match(/^\s+-\s+(.+)$/);
    if (listItem && listKey) {
      frontmatter[listKey].push(listItem[1]);
      continue;
    }
    const field = line.match(/^([^:]+):(?:\s*(.*))?$/);
    if (!field) continue;
    const [, key, value = ''] = field;
    if (value === '') {
      frontmatter[key] = [];
      listKey = key;
    } else {
      frontmatter[key] = value;
      listKey = undefined;
    }
  }
  return { frontmatter, text };
}

const agents = Object.fromEntries(Object.keys(expected).map((name) => [name, readAgent(name)]));

test('agent profiles use the approved models, thinking levels, and context policy', () => {
  for (const [name, [model, thinking]] of Object.entries(expected)) {
    const { frontmatter } = agents[name];
    assert.equal(frontmatter.name, name);
    assert.equal(frontmatter.model, model);
    assert.deepEqual(frontmatter.fallbackModels, expectedFallbacks[name]);
    assert.equal(frontmatter.thinking, thinking);
    assert.equal(frontmatter.tools, expectedTools[name]);
    assert.equal(frontmatter.systemPromptMode, 'replace');
    assert.equal(frontmatter.inheritProjectContext, 'true');
    assert.equal(frontmatter.inheritGlobalContext, 'true');
    assert.equal(frontmatter.inheritSkills, 'false');
  }
});

test('implementers are Sol-only writers with editing tools', () => {
  for (const name of ['implementer-fast', 'implementer', 'implementer-deep']) {
    const { frontmatter } = agents[name];
    assert.equal(frontmatter.acceptanceRole, 'writer');
    assert.equal(frontmatter.defaultContext, 'fork');
    const tools = frontmatter.tools.split(/,\s*/);
    assert.ok(tools.includes('edit'), `${name} can edit`);
    assert.ok(tools.includes('write'), `${name} can write`);
    for (const model of [frontmatter.model, ...frontmatter.fallbackModels]) {
      assert.match(model.replace(/:(?:low|medium|high)$/, ''), /^(?:openai-codex|openrouter\/openai)\/gpt-5\.6-sol$/);
    }
  }
});

test('reviewers are read-only and cannot execute, edit, write, or delegate', () => {
  for (const name of ['task-reviewer', 'deep-reviewer']) {
    const { frontmatter } = agents[name];
    assert.equal(frontmatter.acceptanceRole, 'read-only');
    const tools = frontmatter.tools.split(/,\s*/);
    for (const forbidden of ['bash', 'edit', 'write', 'subagent']) {
      assert.ok(!tools.includes(forbidden), `${name} excludes ${forbidden}`);
    }
  }
});

test('explore is read-only and cannot edit, write, or delegate', () => {
  const { frontmatter } = agents.explore;
  assert.equal(frontmatter.acceptanceRole, 'read-only');
  const tools = frontmatter.tools.split(/,\s*/);
  for (const forbidden of ['edit', 'write', 'subagent']) {
    assert.ok(!tools.includes(forbidden), `explore excludes ${forbidden}`);
  }
});

test('profiles exclude unsupported thinking levels and Anthropic models', () => {
  for (const [name, { text }] of Object.entries(agents)) {
    assert.doesNotMatch(text, /thinking:\s*(?:xhigh|max)\b/, name);
    assert.doesNotMatch(text, /anthropic\//, name);
  }
});

test('Pi instructions symlink and routed agent names resolve', () => {
  assert.equal(
    readlinkSync(resolve(repoRoot, 'home/.pi/agent/AGENTS.md')),
    '../../.config/opencode/AGENTS.md',
  );
  const instructions = readFileSync(resolve(repoRoot, 'home/.pi/agent/AGENTS-pi.md'), 'utf8');
  const routedNames = [...instructions.matchAll(/\| `([^`]+)` \|/g)].map((match) => match[1]);
  assert.deepEqual([...new Set(routedNames)].sort(), Object.keys(expected).sort());
  for (const name of routedNames) assert.ok(agents[name], `${name} has an agent profile`);
});

test('Superpowers plans and specs are never committed', () => {
  const sharedInstructions = readFileSync(
    resolve(repoRoot, 'home/.config/opencode/AGENTS.md'),
    'utf8',
  );
  const opencodeInstructions = readFileSync(
    resolve(repoRoot, 'home/.config/opencode/AGENTS-opencode.md'),
    'utf8',
  );
  const piInstructions = readFileSync(
    resolve(repoRoot, 'home/.pi/agent/AGENTS-pi.md'),
    'utf8',
  );

  assert.match(sharedInstructions, /Never stage or commit files under `docs\/superpowers\/(?:plans|specs)\/`/);
  for (const instructions of [opencodeInstructions, piInstructions]) {
    assert.match(instructions, /Never stage or commit Superpowers plans or specifications/);
    assert.doesNotMatch(instructions, /unless the user asks/);
  }
});

test('all configured primary and fallback models exist in the Pi registry', () => {
  const modelRows = execFileSync('pi', ['--list-models'], { encoding: 'utf8' })
    .trim()
    .split('\n')
    .slice(1);
  const availableModels = new Set(modelRows.map((row) => {
    const [provider, model] = row.trim().split(/\s+/);
    return `${provider}/${model}`;
  }));
  const configuredModels = [
    'openai-codex/gpt-5.6-sol',
    'openrouter/openai/gpt-5.6-sol',
    'openrouter/google/gemini-3.7-flash',
    'openrouter/z-ai/glm-5.3',
    'openrouter/z-ai/glm-5.3-flash',
    'openrouter/x-ai/grok-4.6',
    'openrouter/moonshotai/kimi-k3',
  ];
  for (const model of configuredModels) assert.ok(availableModels.has(model), model);
});
