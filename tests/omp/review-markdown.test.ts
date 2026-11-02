import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { basename, join } from 'node:path';
import test from 'node:test';

async function loadReview() {
  return import('../../home/.omp/agent/extensions/review-markdown.ts');
}

test('finds the latest presented Markdown path on the active branch', async () => {
  const { findPresentedMarkdownPaths } = await loadReview();
  const cwd = mkdtempSync(join(tmpdir(), 'omp-md-'));
  try {
    writeFileSync(join(cwd, 'spec.md'), 'spec');
    writeFileSync(join(cwd, 'plan.md'), 'plan');
    const entries = [
      { type: 'message', message: { role: 'assistant', content: [{ type: 'text', text: 'Review `spec.md`.' }] } },
      { type: 'message', message: { role: 'user', content: [{ type: 'text', text: 'lgtm' }] } },
      { type: 'message', message: { role: 'assistant', content: [{ type: 'text', text: 'Plan: `plan.md`. Please review.' }] } },
    ];

    assert.deepEqual(findPresentedMarkdownPaths?.(entries, cwd), [join(cwd, 'plan.md')]);
  } finally {
    rmSync(cwd, { recursive: true, force: true });
  }
});

test('returns all existing paths from the newest presentation, including Markdown links', async () => {
  const { findPresentedMarkdownPaths } = await loadReview();
  const cwd = mkdtempSync(join(tmpdir(), 'omp-md-'));
  try {
    writeFileSync(join(cwd, 'older.md'), 'older');
    writeFileSync(join(cwd, 'plan with spaces.md'), 'plan');
    writeFileSync(join(cwd, 'spec.md'), 'spec');
    const entries = [
      { type: 'message', message: { role: 'assistant', content: [{ type: 'text', text: 'Review `older.md`.' }] } },
      { type: 'message', message: { role: 'assistant', content: [
        { type: 'text', text: 'Review `plan with spaces.md` and [spec](spec.md), not `missing.md`.' },
      ] } },
    ];

    assert.deepEqual(findPresentedMarkdownPaths?.(entries, cwd), [
      join(cwd, 'plan with spaces.md'), join(cwd, 'spec.md'),
    ]);
  } finally {
    rmSync(cwd, { recursive: true, force: true });
  }
});

test('uses the most recent existing document when a newer presented path is missing', async () => {
  const { findPresentedMarkdownPaths } = await loadReview();
  const cwd = mkdtempSync(join(tmpdir(), 'omp-md-'));
  try {
    writeFileSync(join(cwd, 'old.md'), 'old');
    const entries = [
      { type: 'message', message: { role: 'assistant', content: [{ type: 'text', text: 'Review `old.md`.' }] } },
      { type: 'message', message: { role: 'assistant', content: [{ type: 'text', text: 'Review `missing.md`.' }] } },
    ];

    assert.deepEqual(findPresentedMarkdownPaths?.(entries, cwd), [join(cwd, 'old.md')]);
  } finally {
    rmSync(cwd, { recursive: true, force: true });
  }
});

test('finds a bare Markdown path presented without a link or backticks', async () => {
  const { findPresentedMarkdownPaths } = await loadReview();
  const cwd = mkdtempSync(join(tmpdir(), 'omp-md-'));
  try {
    writeFileSync(join(cwd, 'plan.md'), 'plan');
    const entries = [
      { type: 'message', message: { role: 'assistant', content: [{ type: 'text', text: 'Please review plan.md before proceeding.' }] } },
    ];

    assert.deepEqual(findPresentedMarkdownPaths?.(entries, cwd), [join(cwd, 'plan.md')]);
  } finally {
    rmSync(cwd, { recursive: true, force: true });
  }
});

test('/md opens the latest presented document in a new tmux window with the same cwd', async () => {
  const { default: reviewMarkdownExtension } = await loadReview();
  const cwd = mkdtempSync(join(tmpdir(), "omp-md's folder "));
  const originalTmux = process.env.TMUX;
  const originalViewer = process.env.OMP_MD_VIEWER;
  process.env.TMUX = '/tmp/tmux-1000/default,1,0';
  delete process.env.OMP_MD_VIEWER;
  try {
    const file = join(cwd, "Pete's plan.md");
    writeFileSync(file, 'plan');
    const calls: unknown[] = [];
    let command: any;
    const omp = {
      registerCommand: (name: string, options: any) => { if (name === 'md') command = options.handler; },
      registerShortcut: () => { throw Error('shortcuts are reserved'); },
      exec: async (name: string, args: string[]) => { calls.push([name, args]); return { code: 0, stderr: '' }; },
    };
    const ctx = {
      cwd,
      sessionManager: { getBranch: () => [
        { type: 'message', message: { role: 'assistant', content: [{ type: 'text', text: "Review `Pete's plan.md`." }] } },
      ] },
      ui: { notify: () => {}, select: () => { throw Error('unexpected picker'); } },
    };

    reviewMarkdownExtension?.(omp);
    await command?.('', ctx);
    process.env.OMP_MD_VIEWER = '  ';
    await command?.('', ctx);

    assert.deepEqual(calls, [
      ['tmux', ['new-window', '-c', cwd, 'mdless', '--', file]],
      ['tmux', ['new-window', '-c', cwd, 'mdless', '--', file]],
    ]);
  } finally {
    if (originalTmux === undefined) delete process.env.TMUX;
    else process.env.TMUX = originalTmux;
    if (originalViewer === undefined) delete process.env.OMP_MD_VIEWER;
    else process.env.OMP_MD_VIEWER = originalViewer;
    rmSync(cwd, { recursive: true, force: true });
  }
});

test('/md uses OMP_MD_VIEWER with executable and flags as separate arguments', async () => {
  const { default: reviewMarkdownExtension } = await loadReview();
  const cwd = mkdtempSync(join(tmpdir(), 'omp-md-'));
  const originalTmux = process.env.TMUX;
  const originalViewer = process.env.OMP_MD_VIEWER;
  process.env.TMUX = '/tmp/tmux-1000/default,1,0';
  process.env.OMP_MD_VIEWER = 'less -n';
  try {
    writeFileSync(join(cwd, 'plan.md'), 'plan');
    let command: any;
    const calls: unknown[] = [];
    const omp = {
      registerCommand: (_name: string, registration: any) => { command = registration.handler; },
      exec: async (name: string, args: string[]) => { calls.push([name, args]); return { code: 0, stderr: '' }; },
    };
    const ctx = {
      cwd,
      sessionManager: { getBranch: () => [
        { type: 'message', message: { role: 'assistant', content: [{ type: 'text', text: 'Review `plan.md`.' }] } },
      ] },
      ui: { notify: () => {} },
    };

    reviewMarkdownExtension?.(omp);
    await command?.('', ctx);
    process.env.OMP_MD_VIEWER = "less -P 'My prompt: ' -n";
    await command?.('', ctx);
    process.env.OMP_MD_VIEWER = 'less -P \\  -n';
    await command?.('', ctx);
    process.env.OMP_MD_VIEWER = 'less -P "C:\\docs" -n';
    await command?.('', ctx);

    assert.deepEqual(calls, [
      ['tmux', ['new-window', '-c', cwd, 'less', '-n', '--', join(cwd, 'plan.md')]],
      ['tmux', ['new-window', '-c', cwd, 'less', '-P', 'My prompt: ', '-n', '--', join(cwd, 'plan.md')]],
      ['tmux', ['new-window', '-c', cwd, 'less', '-P', ' ', '-n', '--', join(cwd, 'plan.md')]],
      ['tmux', ['new-window', '-c', cwd, 'less', '-P', 'C:\\docs', '-n', '--', join(cwd, 'plan.md')]],
    ]);
  } finally {
    if (originalTmux === undefined) delete process.env.TMUX;
    else process.env.TMUX = originalTmux;
    if (originalViewer === undefined) delete process.env.OMP_MD_VIEWER;
    else process.env.OMP_MD_VIEWER = originalViewer;
    rmSync(cwd, { recursive: true, force: true });
  }
});

test('/md reports a malformed OMP_MD_VIEWER without opening a window', async () => {
  const { default: reviewMarkdownExtension } = await loadReview();
  const cwd = mkdtempSync(join(tmpdir(), 'omp-md-'));
  const originalTmux = process.env.TMUX;
  const originalViewer = process.env.OMP_MD_VIEWER;
  process.env.TMUX = '/tmp/tmux-1000/default,1,0';
  try {
    writeFileSync(join(cwd, 'plan.md'), 'plan');
    let command: any;
    const notifications: unknown[] = [];
    const omp = {
      registerCommand: (_name: string, registration: any) => { command = registration.handler; },
      exec: async () => { throw Error('must not launch'); },
    };
    const ctx = {
      cwd,
      sessionManager: { getBranch: () => [
        { type: 'message', message: { role: 'assistant', content: [{ type: 'text', text: 'Review `plan.md`.' }] } },
      ] },
      ui: { notify: (text: string, level: string) => notifications.push([text, level]) },
    };

    reviewMarkdownExtension?.(omp);
    process.env.OMP_MD_VIEWER = "less -P 'unclosed";
    await command?.('', ctx);
    process.env.OMP_MD_VIEWER = "'' -n";
    await command?.('', ctx);

    assert.deepEqual(notifications, [
      ['Invalid OMP_MD_VIEWER: unmatched quote or escape.', 'error'],
      ['OMP_MD_VIEWER must begin with an executable.', 'error'],
    ]);
  } finally {
    if (originalTmux === undefined) delete process.env.TMUX;
    else process.env.TMUX = originalTmux;
    if (originalViewer === undefined) delete process.env.OMP_MD_VIEWER;
    else process.env.OMP_MD_VIEWER = originalViewer;
    rmSync(cwd, { recursive: true, force: true });
  }
});

test('/md does not allow a viewer flag to start another tmux command', async () => {
  const { default: reviewMarkdownExtension } = await loadReview();
  const cwd = mkdtempSync(join(tmpdir(), 'omp-md-tmux-'));
  const socket = basename(cwd);
  const originalTmux = process.env.TMUX;
  const originalViewer = process.env.OMP_MD_VIEWER;
  const tmux = (args: string[]) => spawnSync('tmux', ['-L', socket, ...args], { encoding: 'utf8' });
  process.env.TMUX = '/tmp/tmux-test/default,1,0';
  process.env.OMP_MD_VIEWER = '/usr/bin/true ";" new-window -n injected /bin/sleep 60';
  try {
    writeFileSync(join(cwd, 'plan.md'), 'plan');
    assert.equal(tmux(['-f', '/dev/null', 'new-session', '-d', '-s', 'md-test']).status, 0);
    let command: any;
    const notifications: unknown[] = [];
    reviewMarkdownExtension?.({
      registerCommand: (_name: string, registration: any) => { command = registration.handler; },
      exec: async (name: string, args: string[]) => {
        assert.equal(name, 'tmux');
        const result = tmux(args);
        return { code: result.status ?? 1, stderr: result.stderr };
      },
    });
    await command?.('', {
      cwd,
      sessionManager: { getBranch: () => [
        { type: 'message', message: { role: 'assistant', content: [{ type: 'text', text: 'Review `plan.md`.' }] } },
      ] },
      ui: { notify: (text: string, level: string) => notifications.push([text, level]) },
    });

    assert.deepEqual(notifications, [['Invalid OMP_MD_VIEWER: tmux command separator is not allowed.', 'error']]);
    assert.doesNotMatch(tmux(['list-windows', '-t', 'md-test', '-F', '#{window_name}']).stdout, /injected/);
  } finally {
    tmux(['kill-server']);
    if (originalTmux === undefined) delete process.env.TMUX;
    else process.env.TMUX = originalTmux;
    if (originalViewer === undefined) delete process.env.OMP_MD_VIEWER;
    else process.env.OMP_MD_VIEWER = originalViewer;
    rmSync(cwd, { recursive: true, force: true });
  }
});

test('/md lets the user select when the latest message presents multiple documents', async () => {
  const { default: reviewMarkdownExtension } = await loadReview();
  const cwd = mkdtempSync(join(tmpdir(), 'omp-md-'));
  const originalTmux = process.env.TMUX;
  const originalViewer = process.env.OMP_MD_VIEWER;
  process.env.TMUX = '/tmp/tmux-1000/default,1,0';
  delete process.env.OMP_MD_VIEWER;
  try {
    writeFileSync(join(cwd, 'spec.md'), 'spec');
    writeFileSync(join(cwd, 'plan.md'), 'plan');
    let command: any;
    let options: string[] = [];
    const calls: unknown[] = [];
    const omp = {
      registerCommand: (_name: string, registration: any) => { command = registration.handler; },
      exec: async (name: string, args: string[]) => { calls.push([name, args]); return { code: 0, stderr: '' }; },
    };
    const ctx = {
      cwd,
      sessionManager: { getBranch: () => [
        { type: 'message', message: { role: 'assistant', content: [{ type: 'text', text: 'Review `spec.md` and `plan.md`.' }] } },
      ] },
      ui: { notify: () => {}, select: async (_title: string, items: string[]) => {
        options = items;
        return items[1];
      } },
    };

    reviewMarkdownExtension?.(omp);
    await command?.('', ctx);

    assert.deepEqual(options, ['spec.md', 'plan.md']);
    assert.deepEqual(calls, [['tmux', ['new-window', '-c', cwd, 'mdless', '--', join(cwd, 'plan.md')]]]);
  } finally {
    if (originalTmux === undefined) delete process.env.TMUX;
    else process.env.TMUX = originalTmux;
    if (originalViewer === undefined) delete process.env.OMP_MD_VIEWER;
    else process.env.OMP_MD_VIEWER = originalViewer;
    rmSync(cwd, { recursive: true, force: true });
  }
});

test('/md warns instead of launching tmux without a presented document', async () => {
  const { default: reviewMarkdownExtension } = await loadReview();
  const originalTmux = process.env.TMUX;
  process.env.TMUX = '/tmp/tmux-1000/default,1,0';
  try {
    let command: any;
    let launches = 0;
    const notifications: unknown[] = [];
    reviewMarkdownExtension?.({
      registerCommand: (_name: string, registration: any) => { command = registration.handler; },
      exec: async () => { launches++; return { code: 0 }; },
    });
    await command?.('', {
      cwd: '/tmp',
      sessionManager: { getBranch: () => [] },
      ui: { notify: (text: string, level: string) => notifications.push([text, level]) },
    });

    assert.equal(launches, 0);
    assert.deepEqual(notifications, [['No presented Markdown document found.', 'warning']]);
  } finally {
    if (originalTmux === undefined) delete process.env.TMUX;
    else process.env.TMUX = originalTmux;
  }
});

test('/md reports a tmux launch error without throwing', async () => {
  const { default: reviewMarkdownExtension } = await loadReview();
  const cwd = mkdtempSync(join(tmpdir(), 'omp-md-'));
  const originalTmux = process.env.TMUX;
  process.env.TMUX = '/tmp/tmux-1000/default,1,0';
  try {
    writeFileSync(join(cwd, 'plan.md'), 'plan');
    let command: any;
    const notifications: unknown[] = [];
    const omp = {
      registerCommand: (_name: string, registration: any) => { command = registration.handler; },
      exec: async () => { throw Error('tmux socket unavailable'); },
    };
    const ctx = {
      cwd,
      sessionManager: { getBranch: () => [
        { type: 'message', message: { role: 'assistant', content: [{ type: 'text', text: 'Review `plan.md`.' }] } },
      ] },
      ui: { notify: (text: string, level: string) => notifications.push([text, level]) },
    };

    reviewMarkdownExtension?.(omp);
    await command?.('', ctx);

    assert.deepEqual(notifications, [['tmux socket unavailable', 'error']]);
  } finally {
    if (originalTmux === undefined) delete process.env.TMUX;
    else process.env.TMUX = originalTmux;
    rmSync(cwd, { recursive: true, force: true });
  }
});
