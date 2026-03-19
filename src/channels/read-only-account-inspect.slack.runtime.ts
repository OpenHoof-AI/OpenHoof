import { inspectSlackAccount as inspectSlackAccountImpl } from "openhoof/plugin-sdk/slack";

export type { InspectedSlackAccount } from "openhoof/plugin-sdk/slack";

type InspectSlackAccount = typeof import("openhoof/plugin-sdk/slack").inspectSlackAccount;

export function inspectSlackAccount(
  ...args: Parameters<InspectSlackAccount>
): ReturnType<InspectSlackAccount> {
  return inspectSlackAccountImpl(...args);
}
