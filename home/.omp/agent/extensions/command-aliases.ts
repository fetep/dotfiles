import type { ExtensionAPI } from '@oh-my-pi/pi-coding-agent';

export default function commandAliases(pi: ExtensionAPI) {
  pi.on('input', (event) => {
    if (/^\/name(?=$|[\s:])/.test(event.text)) {
      return { text: event.text.replace(/^\/name/, '/rename') };
    }
    if (/^\/thinking(?=$|[\s:])/.test(event.text)) {
      return { text: event.text.replace(/^\/thinking/, '/effort') };
    }
  });
}
