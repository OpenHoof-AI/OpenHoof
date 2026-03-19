import { sendMessageTelegram as sendMessageTelegramImpl } from "openhoof/plugin-sdk/telegram";

type RuntimeSend = {
  sendMessage: typeof import("openhoof/plugin-sdk/telegram").sendMessageTelegram;
};

export const runtimeSend = {
  sendMessage: sendMessageTelegramImpl,
} satisfies RuntimeSend;
