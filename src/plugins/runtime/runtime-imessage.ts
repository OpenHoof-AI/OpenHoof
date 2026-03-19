import {
  monitorIMessageProvider,
  probeIMessage,
  sendMessageIMessage,
} from "openhoof/plugin-sdk/imessage";
import type { PluginRuntimeChannel } from "./types-channel.js";

export function createRuntimeIMessage(): PluginRuntimeChannel["imessage"] {
  return {
    monitorIMessageProvider,
    probeIMessage,
    sendMessageIMessage,
  };
}
