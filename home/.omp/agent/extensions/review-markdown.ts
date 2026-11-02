import { statSync } from 'node:fs';
import { relative, resolve } from 'node:path';
import type { ExtensionAPI, ExtensionContext } from '@oh-my-pi/pi-coding-agent';

export function findPresentedMarkdownPaths(entries: unknown[], cwd: string): string[] {
  for (const entry of [...entries].reverse()) {
    if (!entry || typeof entry !== 'object' || !('type' in entry) || entry.type !== 'message') continue;
    const message = 'message' in entry ? entry.message : undefined;
    if (!message || typeof message !== 'object' || !('role' in message) || message.role !== 'assistant') continue;
    const content = 'content' in message ? message.content : undefined;
    if (!Array.isArray(content)) continue;
    const text = content.filter((part) => part?.type === 'text').map((part) => part.text).join('\n');
    const paths = [...text.matchAll(/`([^`\n]+\.md)`|\[[^\]\n]+\]\(([^)\n]+\.md)\)|(?<![\w./-])((?:\.{0,2}\/|\/)?[\w./-]+\.md)(?![\w./-])/g)]
      .map((match) => resolve(cwd, match[1] ?? match[2] ?? match[3]));
    const existing = paths.filter((path) => {
      try {
        return statSync(path).isFile();
      } catch {
        return false;
      }
    });
    if (existing.length) return [...new Set(existing)];
  }
  return [];
}

function viewerArgs(value: string | undefined): string[] {
  if (!value?.trim()) return ['mdless'];

  const args: string[] = [];
  let word = '';
  let quote: "'" | '"' | null = null;
  let escaped = false;
  let started = false;
  for (const char of value) {
    if (escaped) {
      if (quote === '"' && !['\\', '"', '$', '`', '\n'].includes(char)) word += '\\';
      if (quote !== '"' || char !== '\n') word += char;
      started = true;
      escaped = false;
    } else if (char === '\\' && quote !== "'") {
      escaped = true;
    } else if (quote) {
      if (char === quote) quote = null;
      else word += char;
    } else if (char === "'" || char === '"') {
      quote = char;
      started = true;
    } else if (/\s/.test(char)) {
      if (started) args.push(word);
      word = '';
      started = false;
    } else {
      word += char;
      started = true;
    }
  }
  if (escaped || quote) throw new Error('Invalid OMP_MD_VIEWER: unmatched quote or escape.');
  if (started) args.push(word);
  if (!args[0]) throw new Error('OMP_MD_VIEWER must begin with an executable.');
  if (args.some((arg) => arg.includes(';'))) {
    throw new Error('Invalid OMP_MD_VIEWER: tmux command separator is not allowed.');
  }
  return args;
}

export default function reviewMarkdownExtension(omp: ExtensionAPI) {
  const openReview = async (ctx: ExtensionContext) => {
    if (!process.env.TMUX) {
      ctx.ui.notify('Open omp inside tmux to use /md.', 'warning');
      return;
    }
    const paths = findPresentedMarkdownPaths(ctx.sessionManager.getBranch(), ctx.cwd);
    if (!paths.length) {
      ctx.ui.notify('No presented Markdown document found.', 'warning');
      return;
    }
    const selected = paths.length === 1
      ? relative(ctx.cwd, paths[0])
      : await ctx.ui.select('Review Markdown', paths.map((path) => relative(ctx.cwd, path)));
    const path = paths.find((candidate) => relative(ctx.cwd, candidate) === selected);
    if (!path) return;
    try {
      const result = await omp.exec('tmux', [
        'new-window', '-c', ctx.cwd, ...viewerArgs(process.env.OMP_MD_VIEWER), '--', path,
      ]);
      if (result.code !== 0) ctx.ui.notify(result.stderr || 'Could not open tmux window.', 'error');
    } catch (error) {
      ctx.ui.notify(error instanceof Error ? error.message : String(error), 'error');
    }
  };

  omp.registerCommand('md', {
    description: 'Review the latest presented Markdown document in a viewer',
    handler: async (_args, ctx) => openReview(ctx),
  });
}
