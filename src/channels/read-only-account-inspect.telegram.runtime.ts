import { inspectTelegramAccount as inspectTelegramAccountImpl } from "openhoof/plugin-sdk/telegram";

export type { InspectedTelegramAccount } from "openhoof/plugin-sdk/telegram";

type InspectTelegramAccount = typeof import("openhoof/plugin-sdk/telegram").inspectTelegramAccount;

export function inspectTelegramAccount(
  ...args: Parameters<InspectTelegramAccount>
): ReturnType<InspectTelegramAccount> {
  return inspectTelegramAccountImpl(...args);
}
