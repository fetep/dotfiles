import assert from 'node:assert/strict';
import test from 'node:test';

async function loadTerminalTitleModule() {
  return import('../../home/.pi/agent/extensions/terminal-title.ts');
}

test('uses the explicit session name instead of the first prompt', async () => {
  const { buildTerminalTitle } = await loadTerminalTitleModule();

  assert.equal(
    buildTerminalTitle?.('dotfiles', 'Rename terminal title', 'Ignored first prompt'),
    'dotfiles — Rename terminal title',
  );
});

test('normalizes the first prompt when used as the fallback title', async () => {
  const { buildTerminalTitle } = await loadTerminalTitleModule();

  assert.equal(
    buildTerminalTitle?.('dotfiles', undefined, '  Customize   the\nterminal title  '),
    'dotfiles — Customize the terminal title',
  );
});

test('limits the fallback title to 50 characters', async () => {
  const { buildTerminalTitle } = await loadTerminalTitleModule();

  assert.equal(
    buildTerminalTitle?.(
      'dotfiles',
      undefined,
      '123456789012345678901234567890123456789012345678901234567890',
    ),
    'dotfiles — 1234567890123456789012345678901234567890123456789…',
  );
});

test('finds the first user prompt on the active branch', async () => {
  const { findFirstUserPrompt } = await loadTerminalTitleModule();
  const entries = [
    { type: 'model_change' },
    {
      type: 'message',
      message: {
        role: 'user',
        content: [
          { type: 'text', text: 'First prompt' },
        ],
      },
    },
    {
      type: 'message',
      message: { role: 'user', content: 'Second prompt' },
    },
  ];

  assert.equal(findFirstUserPrompt?.(entries), 'First prompt');
});

test('reads string content from an older user message', async () => {
  const { findFirstUserPrompt } = await loadTerminalTitleModule();
  const entries = [
    {
      type: 'message',
      message: { role: 'user', content: 'Legacy prompt' },
    },
  ];

  assert.equal(findFirstUserPrompt?.(entries), 'Legacy prompt');
});

test('skips an empty legacy user message', async () => {
  const { findFirstUserPrompt } = await loadTerminalTitleModule();
  const entries = [
    {
      type: 'message',
      message: { role: 'user', content: '   ' },
    },
    {
      type: 'message',
      message: { role: 'user', content: 'First meaningful prompt' },
    },
  ];

  assert.equal(findFirstUserPrompt?.(entries), 'First meaningful prompt');
});

test('sets the terminal title when a session starts', async () => {
  const { default: terminalTitleExtension } = await loadTerminalTitleModule();
  const handlers = new Map();
  let terminalTitle;
  const pi = {
    getSessionName: () => 'Rename terminal title',
    on: (event, handler) => handlers.set(event, handler),
  };
  const ctx = {
    cwd: '/home/petef/src/dotfiles',
    sessionManager: { getBranch: () => [] },
    ui: { setTitle: (title) => { terminalTitle = title; } },
  };

  terminalTitleExtension?.(pi);
  await handlers.get('session_start')?.({ type: 'session_start', reason: 'startup' }, ctx);

  assert.equal(terminalTitle, 'dotfiles — Rename terminal title');
});

test('restores the custom title after Pi completes startup binding', async () => {
  const { default: terminalTitleExtension } = await loadTerminalTitleModule();
  const handlers = new Map();
  let terminalTitle;
  const pi = {
    getSessionName: () => 'Rename terminal title',
    on: (event, handler) => handlers.set(event, handler),
  };
  const ctx = {
    cwd: '/home/petef/src/dotfiles',
    sessionManager: { getBranch: () => [] },
    ui: { setTitle: (title) => { terminalTitle = title; } },
  };

  terminalTitleExtension?.(pi);
  await handlers.get('session_start')?.({ type: 'session_start', reason: 'startup' }, ctx);
  terminalTitle = 'π - Rename terminal title - dotfiles';
  await new Promise((resolve) => setTimeout(resolve, 10));

  assert.equal(terminalTitle, 'dotfiles — Rename terminal title');
});

test('updates the terminal title when the session is renamed', async () => {
  const { default: terminalTitleExtension } = await loadTerminalTitleModule();
  const handlers = new Map();
  let sessionName = 'Old title';
  let terminalTitle;
  const pi = {
    getSessionName: () => sessionName,
    on: (event, handler) => handlers.set(event, handler),
  };
  const ctx = {
    cwd: '/home/petef/src/dotfiles',
    sessionManager: { getBranch: () => [] },
    ui: { setTitle: (title) => { terminalTitle = title; } },
  };

  terminalTitleExtension?.(pi);
  await handlers.get('session_start')?.({ type: 'session_start', reason: 'startup' }, ctx);
  sessionName = 'New title';
  await handlers.get('session_info_changed')?.(
    { type: 'session_info_changed', name: sessionName },
    ctx,
  );

  assert.equal(terminalTitle, 'dotfiles — New title');
});

test('uses the first prompt for an unnamed new session', async () => {
  const { default: terminalTitleExtension } = await loadTerminalTitleModule();
  const handlers = new Map();
  let terminalTitle;
  const pi = {
    getSessionName: () => undefined,
    on: (event, handler) => handlers.set(event, handler),
  };
  const ctx = {
    cwd: '/home/petef/src/dotfiles',
    sessionManager: { getBranch: () => [] },
    ui: { setTitle: (title) => { terminalTitle = title; } },
  };

  terminalTitleExtension?.(pi);
  await handlers.get('session_start')?.({ type: 'session_start', reason: 'startup' }, ctx);
  await handlers.get('before_agent_start')?.(
    { type: 'before_agent_start', prompt: 'Customize the terminal title' },
    ctx,
  );

  assert.equal(terminalTitle, 'dotfiles — Customize the terminal title');
});

test('restores the first prompt when an unnamed session resumes', async () => {
  const { default: terminalTitleExtension } = await loadTerminalTitleModule();
  const handlers = new Map();
  let terminalTitle;
  const pi = {
    getSessionName: () => undefined,
    on: (event, handler) => handlers.set(event, handler),
  };
  const ctx = {
    cwd: '/home/petef/src/dotfiles',
    sessionManager: {
      getBranch: () => [
        {
          type: 'message',
          message: { role: 'user', content: 'Customize the terminal title' },
        },
      ],
    },
    ui: { setTitle: (title) => { terminalTitle = title; } },
  };

  terminalTitleExtension?.(pi);
  await handlers.get('session_start')?.({ type: 'session_start', reason: 'resume' }, ctx);

  assert.equal(terminalTitle, 'dotfiles — Customize the terminal title');
});

test('falls back to the first prompt when the session name is cleared', async () => {
  const { default: terminalTitleExtension } = await loadTerminalTitleModule();
  const handlers = new Map();
  let sessionName = 'Temporary title';
  let terminalTitle;
  const pi = {
    getSessionName: () => sessionName,
    on: (event, handler) => handlers.set(event, handler),
  };
  const ctx = {
    cwd: '/home/petef/src/dotfiles',
    sessionManager: {
      getBranch: () => [
        {
          type: 'message',
          message: { role: 'user', content: 'Customize the terminal title' },
        },
      ],
    },
    ui: { setTitle: (title) => { terminalTitle = title; } },
  };

  terminalTitleExtension?.(pi);
  await handlers.get('session_start')?.({ type: 'session_start', reason: 'resume' }, ctx);
  sessionName = undefined;
  await handlers.get('session_info_changed')?.(
    { type: 'session_info_changed', name: sessionName },
    ctx,
  );

  assert.equal(terminalTitle, 'dotfiles — Customize the terminal title');
});
