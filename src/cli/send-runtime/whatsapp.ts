import { sendMessageWhatsApp as sendMessageWhatsAppImpl } from "openhoof/plugin-sdk/whatsapp";

type RuntimeSend = {
  sendMessage: typeof import("openhoof/plugin-sdk/whatsapp").sendMessageWhatsApp;
};

export const runtimeSend = {
  sendMessage: sendMessageWhatsAppImpl,
} satisfies RuntimeSend;
