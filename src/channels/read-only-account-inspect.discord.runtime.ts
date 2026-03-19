import { inspectDiscordAccount as inspectDiscordAccountImpl } from "openhoof/plugin-sdk/discord";

export type { InspectedDiscordAccount } from "openhoof/plugin-sdk/discord";

type InspectDiscordAccount = typeof import("openhoof/plugin-sdk/discord").inspectDiscordAccount;

export function inspectDiscordAccount(
  ...args: Parameters<InspectDiscordAccount>
): ReturnType<InspectDiscordAccount> {
  return inspectDiscordAccountImpl(...args);
}
