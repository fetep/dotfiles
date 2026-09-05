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
  pi.registerShortcut('shift+tab', {
    description: 'Cycle medium, high, and xhigh thinking levels',
    handler: () => {
      pi.setThinkingLevel(nextThinkingLevel(pi.getThinkingLevel()));
    },
  });
}
