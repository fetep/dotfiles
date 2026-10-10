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

function createPi(initialLevel = 'medium') {
  const handlers = new Map();
  let shortcut;
  let level = initialLevel;
  const pi = {
    getThinkingLevel: () => level,
    on: (event, handler) => {
      handlers.set(event, handler);
    },
    registerShortcut: (key, options) => {
      shortcut = { key, ...options };
    },
    setThinkingLevel: (next) => {
      level = next;
    },
  };

  return {
    handlers,
    pi,
    get shortcut() {
      return shortcut;
    },
    get level() {
      return level;
    },
    set level(next) {
      level = next;
    },
  };
}

test('registers shift+tab and sets the next thinking level', () => {
  const state = createPi();

  thinkingCycleExtension(state.pi);

  assert.equal(state.shortcut.key, 'shift+tab');
  state.shortcut.handler();
  assert.equal(state.level, 'high');
});

test('restores the selected thinking level after switching models', () => {
  const state = createPi();
  thinkingCycleExtension(state.pi);

  state.shortcut.handler();
  assert.equal(state.level, 'high');

  state.level = 'medium';
  state.handlers.get('model_select')({ source: 'cycle' });

  assert.equal(state.level, 'high');
});

test('does not override thinking when restoring a session', () => {
  const state = createPi('high');
  thinkingCycleExtension(state.pi);
  state.handlers.get('session_start')({ reason: 'startup' });

  state.level = 'medium';
  state.handlers.get('model_select')({ source: 'restore' });

  assert.equal(state.level, 'medium');

  state.level = 'low';
  state.handlers.get('model_select')({ source: 'set' });
  assert.equal(state.level, 'medium');
});

test('initializes thinking after reload, not during extension loading', () => {
  const state = createPi('xhigh');
  const getThinkingLevel = state.pi.getThinkingLevel;
  state.pi.getThinkingLevel = () => {
    throw new Error('Extension runtime not initialized');
  };

  assert.doesNotThrow(() => thinkingCycleExtension(state.pi));

  state.pi.getThinkingLevel = getThinkingLevel;
  state.handlers.get('session_start')({ reason: 'reload' });
  state.level = 'medium';
  state.handlers.get('model_select')({ source: 'set' });

  assert.equal(state.level, 'xhigh');
});
