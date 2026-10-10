import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';

type ThinkingLevel = ReturnType<ExtensionAPI['getThinkingLevel']>;

export const PREFERRED_THINKING_LEVELS: readonly ThinkingLevel[] = [
  'medium',
  'high',
  'xhigh',
];

export function nextThinkingLevel(current: ThinkingLevel): ThinkingLevel {
  const currentIndex = PREFERRED_THINKING_LEVELS.indexOf(current);
  return PREFERRED_THINKING_LEVELS[(currentIndex + 1) % PREFERRED_THINKING_LEVELS.length];
}

export default function thinkingCycleExtension(pi: ExtensionAPI) {
  let preferredThinkingLevel: ThinkingLevel | undefined;

  // Runtime APIs are unavailable during extension loading, including /reload.
  pi.on('session_start', () => {
    preferredThinkingLevel = pi.getThinkingLevel();
  });

  pi.registerShortcut('shift+tab', {
    description: 'Cycle medium, high, and xhigh thinking levels',
    handler: () => {
      preferredThinkingLevel = nextThinkingLevel(pi.getThinkingLevel());
      pi.setThinkingLevel(preferredThinkingLevel);
    },
  });

  pi.on('model_select', (event) => {
    if (event.source === 'restore') {
      preferredThinkingLevel = pi.getThinkingLevel();
    } else if (preferredThinkingLevel !== undefined) {
      pi.setThinkingLevel(preferredThinkingLevel);
    }
  });
}
