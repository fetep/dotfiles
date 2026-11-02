import { ThinkingLevel } from '@oh-my-pi/pi-agent-core';
import type { ExtensionAPI } from '@oh-my-pi/pi-coding-agent';
import { matchesKey } from '@oh-my-pi/pi-tui';

export default function thinkingCycle(pi: ExtensionAPI) {
  let unsubscribe: (() => void) | undefined;

  pi.on('session_start', (_event, ctx) => {
    unsubscribe?.();
    if (!ctx.hasUI) return;

    unsubscribe = ctx.ui.onTerminalInput((data) => {
      if (!matchesKey(data, 'shift+tab')) return;

      pi.setThinkingLevel(
        pi.getThinkingLevel() === ThinkingLevel.Medium ? ThinkingLevel.High : ThinkingLevel.Medium,
      );
      return { consume: true };
    });
  });

  pi.on('session_shutdown', () => unsubscribe?.());
}
