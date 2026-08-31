import { basename } from 'node:path';
import type {
  ExtensionAPI,
  ExtensionContext,
  SessionEntry,
} from '@earendil-works/pi-coding-agent';

function normalizePrompt(prompt: string): string {
  const normalized = prompt.trim().replace(/\s+/g, ' ');
  return normalized.length > 50 ? `${normalized.slice(0, 49)}…` : normalized;
}

export function findFirstUserPrompt(entries: readonly SessionEntry[]): string | undefined {
  for (const entry of entries) {
    if (entry.type !== 'message' || entry.message.role !== 'user') continue;
    if (typeof entry.message.content === 'string') {
      const prompt = entry.message.content.trim();
      if (prompt) return prompt;
      continue;
    }

    const prompt = entry.message.content
      .filter((content) => content.type === 'text')
      .map((content) => content.text)
      .join('\n')
      .trim();
    if (prompt) return prompt;
  }

  return undefined;
}

export function buildTerminalTitle(
  project: string,
  sessionName: string | undefined,
  firstPrompt: string | undefined,
): string {
  const summary = sessionName ?? (firstPrompt ? normalizePrompt(firstPrompt) : undefined);
  return summary ? `${project} — ${summary}` : project;
}

export default function terminalTitleExtension(pi: ExtensionAPI) {
  let firstPrompt: string | undefined;
  let startupTitleTimer: ReturnType<typeof setTimeout> | undefined;

  const updateTitle = (ctx: ExtensionContext, sessionName = pi.getSessionName()) => {
    ctx.ui.setTitle(buildTerminalTitle(
      basename(ctx.cwd),
      sessionName,
      firstPrompt,
    ));
  };

  pi.on('session_start', (_event, ctx) => {
    firstPrompt = findFirstUserPrompt(ctx.sessionManager.getBranch());
    updateTitle(ctx);

    clearTimeout(startupTitleTimer);
    startupTitleTimer = setTimeout(() => {
      startupTitleTimer = undefined;
      updateTitle(ctx);
    }, 0);
  });

  pi.on('session_info_changed', (event, ctx) => {
    updateTitle(ctx, event.name);
  });

  pi.on('before_agent_start', (event, ctx) => {
    firstPrompt ??= event.prompt;
    updateTitle(ctx);
  });

  pi.on('session_shutdown', () => {
    clearTimeout(startupTitleTimer);
    startupTitleTimer = undefined;
  });
}
