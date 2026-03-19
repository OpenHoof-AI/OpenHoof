import { sendMessageDiscord as sendMessageDiscordImpl } from "openhoof/plugin-sdk/discord";

type RuntimeSend = {
  sendMessage: typeof import("openhoof/plugin-sdk/discord").sendMessageDiscord;
};

export const runtimeSend = {
  sendMessage: sendMessageDiscordImpl,
} satisfies RuntimeSend;
