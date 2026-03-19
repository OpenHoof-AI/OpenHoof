import { sendMessageSignal as sendMessageSignalImpl } from "openhoof/plugin-sdk/signal";

type RuntimeSend = {
  sendMessage: typeof import("openhoof/plugin-sdk/signal").sendMessageSignal;
};

export const runtimeSend = {
  sendMessage: sendMessageSignalImpl,
} satisfies RuntimeSend;
