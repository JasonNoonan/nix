import type { Plugin } from "@opencode-ai/plugin"

export const NotificationPlugin: Plugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type) === "session.idle") {
        await $`osascript -e 'display notification "Session completed!" with title "opencode"'`
      }
    }
  }
}
