import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { resolve } from 'node:path';
import type {
  ExtensionAPI,
  ExtensionContext,
} from '@earendil-works/pi-coding-agent';

const STATUS_KEY = 'superpowers-toggle';
const BOOTSTRAP_MARKER = 'superpowers:using-superpowers bootstrap for pi';

interface BootstrapResult {
  content: string | null;
  error: string | null;
}

function resolveAgentDir(): string {
  return process.env.PI_CODING_AGENT_DIR ?? resolve(homedir(), '.pi/agent');
}

function isEnabled(value: string | undefined): boolean {
  return value === 'true' || value === '1';
}

function loadBootstrap(agentDir: string): BootstrapResult {
  const skillsDir = resolve(agentDir, 'git/github.com/obra/superpowers/skills');
  const bootstrapPath = resolve(skillsDir, 'using-superpowers/SKILL.md');
  const piInstructionsPath = resolve(agentDir, 'AGENTS-pi.md');

  let piInstructions: string;
  try {
    piInstructions = readFileSync(piInstructionsPath, 'utf8').trim();
  } catch {
    return {
      content: null,
      error: `Unable to load Pi Superpowers instructions: ${piInstructionsPath}`,
    };
  }

  try {
    const content = readFileSync(bootstrapPath, 'utf8');
    const match = content.match(/^---\n[\s\S]*?\n---\n([\s\S]*)$/);
    const body = (match ? match[1] : content).trim();
    return {
      content: `<EXTREMELY_IMPORTANT>
${BOOTSTRAP_MARKER}

You have superpowers.

The using-superpowers skill content is included below and is already loaded for this Pi session. Follow it now. Do not try to load using-superpowers again.

${body}

${piToolMapping()}

${piInstructions}
</EXTREMELY_IMPORTANT>`,
      error: null,
    };
  } catch {
    return {
      content: null,
      error: `Unable to load Superpowers bootstrap: ${bootstrapPath}`,
    };
  }
}

function piToolMapping(): string {
  return `## Pi tool mapping

Pi has native skills but does not expose Claude Code's \`Skill\` tool. When a Superpowers instruction says to invoke a skill, use Pi's native skill system instead: load the relevant \`SKILL.md\` with \`read\` when the skill applies, or let a human invoke \`/skill:name\` explicitly.

Pi's built-in coding tools are lowercase: \`read\`, \`write\`, \`edit\`, \`bash\`, plus optional \`grep\`, \`find\`, and \`ls\`. Use those for the corresponding actions: read a file, create or edit files, run shell commands, search file contents, find files by name, and list directories.

Pi does not ship a standard subagent tool. If a subagent tool such as \`subagent\` from \`pi-subagents\` is available, use it for Superpowers subagent workflows. If no subagent tool is available, do the work in this session or explain the missing capability instead of inventing \`Task\` calls.

Pi does not ship a standard task-list tool. If an installed todo/task tool is available, use it. Otherwise track work in plan files or a repo-local \`TODO.md\` when task tracking is needed. Treat older \`TodoWrite\` references as this task-tracking action.`;
}

function containsBootstrap(message: unknown): boolean {
  const content = (message as { content?: unknown }).content;
  if (typeof content === 'string') return content.includes(BOOTSTRAP_MARKER);
  if (!Array.isArray(content)) return false;
  return content.some((part) => (
    part
    && typeof part === 'object'
    && (part as { type?: unknown }).type === 'text'
    && typeof (part as { text?: unknown }).text === 'string'
    && (part as { text: string }).text.includes(BOOTSTRAP_MARKER)
  ));
}

export default function superpowersToggleExtension(pi: ExtensionAPI) {
  const enabled = isEnabled(process.env.PI_SP_ENABLE);
  const agentDir = resolveAgentDir();
  const skillsDir = resolve(agentDir, 'git/github.com/obra/superpowers/skills');
  let injectBootstrap = enabled;
  let bootstrapInjected = false;
  let loadWarningShown = false;

  const updateStatus = (ctx: ExtensionContext) => {
    const glyph = ctx.ui.theme.fg(enabled ? 'accent' : 'dim', enabled ? '●' : '○');
    const label = ctx.ui.theme.fg('dim', ' superpowers:');
    const state = ctx.ui.theme.fg(enabled ? 'success' : 'dim', enabled ? 'on' : 'off');
    ctx.ui.setStatus(STATUS_KEY, glyph + label + state);
  };

  pi.on('session_start', (_event, ctx) => {
    injectBootstrap = enabled;
    bootstrapInjected = false;
    loadWarningShown = false;
    updateStatus(ctx);
  });

  pi.on('resources_discover', () => (
    enabled ? { skillPaths: [skillsDir] } : undefined
  ));

  pi.on('session_compact', () => {
    injectBootstrap = enabled;
    bootstrapInjected = false;
  });

  pi.on('agent_end', () => {
    if (!bootstrapInjected) return;
    injectBootstrap = false;
    bootstrapInjected = false;
  });

  pi.on('context', (event, ctx) => {
    if (!enabled || !injectBootstrap) return;
    if (event.messages.some(containsBootstrap)) {
      bootstrapInjected = true;
      return;
    }

    const bootstrap = loadBootstrap(agentDir);
    if (!bootstrap.content) {
      if (!loadWarningShown && bootstrap.error) {
        ctx.ui.notify(bootstrap.error, 'warning');
        loadWarningShown = true;
      }
      return;
    }

    bootstrapInjected = true;
    const message = {
      role: 'user' as const,
      content: [{ type: 'text' as const, text: bootstrap.content }],
      timestamp: Date.now(),
    };
    let insertAt = 0;
    while (event.messages[insertAt]?.role === 'compactionSummary') insertAt++;

    return {
      messages: [
        ...event.messages.slice(0, insertAt),
        message,
        ...event.messages.slice(insertAt),
      ],
    };
  });

  const restartMessage = enabled
    ? 'Restart Pi with: PI_SP_ENABLE=false pi'
    : 'Restart Pi with: PI_SP_ENABLE=true pi';

  for (const command of ['sp', 'superpower', 'superpowers']) {
    pi.registerCommand(command, {
      description: 'Show how to restart Pi with Superpowers toggled',
      handler: async (_args, ctx) => {
        ctx.ui.notify(restartMessage, 'info');
      },
    });
  }
}
