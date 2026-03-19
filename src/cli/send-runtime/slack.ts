import { sendMessageSlack as sendMessageSlackImpl } from "openhoof/plugin-sdk/slack";

type RuntimeSend = {
  sendMessage: typeof import("openhoof/plugin-sdk/slack").sendMessageSlack;
};

export const runtimeSend = {
  sendMessage: sendMessageSlackImpl,
} satisfies RuntimeSend;
