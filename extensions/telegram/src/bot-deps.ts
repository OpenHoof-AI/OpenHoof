import { loadConfig, resolveStorePath } from "openhoof/plugin-sdk/config-runtime";
import { readChannelAllowFromStore } from "openhoof/plugin-sdk/conversation-runtime";
import { enqueueSystemEvent } from "openhoof/plugin-sdk/infra-runtime";
import {
  dispatchReplyWithBufferedBlockDispatcher,
  listSkillCommandsForAgents,
} from "openhoof/plugin-sdk/reply-runtime";
import { wasSentByBot } from "./sent-message-cache.js";

export type TelegramBotDeps = {
  loadConfig: typeof loadConfig;
  resolveStorePath: typeof resolveStorePath;
  readChannelAllowFromStore: typeof readChannelAllowFromStore;
  enqueueSystemEvent: typeof enqueueSystemEvent;
  dispatchReplyWithBufferedBlockDispatcher: typeof dispatchReplyWithBufferedBlockDispatcher;
  listSkillCommandsForAgents: typeof listSkillCommandsForAgents;
  wasSentByBot: typeof wasSentByBot;
};

export const defaultTelegramBotDeps: TelegramBotDeps = {
  loadConfig,
  resolveStorePath,
  readChannelAllowFromStore,
  enqueueSystemEvent,
  dispatchReplyWithBufferedBlockDispatcher,
  listSkillCommandsForAgents,
  wasSentByBot,
};
