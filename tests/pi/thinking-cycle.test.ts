import assert from 'node:assert/strict';
import test from 'node:test';

import thinkingCycleExtension, {
  nextThinkingLevel,
} from '../../home/.pi/agent/extensions/thinking-cycle.ts';

test('cycles through medium, high, and xhigh', () => {
  assert.equal(nextThinkingLevel('medium'), 'high');
  assert.equal(nextThinkingLevel('high'), 'xhigh');
  assert.equal(nextThinkingLevel('xhigh'), 'medium');
});

test('starts at medium after another level is selected with /thinking', () => {
  assert.equal(nextThinkingLevel('low'), 'medium');
});

test('registers shift+tab and sets the next thinking level', () => {
  let shortcut;
  let level = 'medium';
  const pi = {
    getThinkingLevel: () => level,
    registerShortcut: (key, options) => {
      shortcut = { key, ...options };
    },
    setThinkingLevel: (next) => {
      level = next;
    },
  };

  thinkingCycleExtension(pi);

  assert.equal(shortcut.key, 'shift+tab');
  shortcut.handler();
  assert.equal(level, 'high');
});
