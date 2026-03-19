import {
  listSlackDirectoryGroupsLive as listSlackDirectoryGroupsLiveImpl,
  listSlackDirectoryPeersLive as listSlackDirectoryPeersLiveImpl,
} from "openhoof/plugin-sdk/slack";
import { monitorSlackProvider as monitorSlackProviderImpl } from "openhoof/plugin-sdk/slack";
import { probeSlack as probeSlackImpl } from "openhoof/plugin-sdk/slack";
import { resolveSlackChannelAllowlist as resolveSlackChannelAllowlistImpl } from "openhoof/plugin-sdk/slack";
import { resolveSlackUserAllowlist as resolveSlackUserAllowlistImpl } from "openhoof/plugin-sdk/slack";
import { sendMessageSlack as sendMessageSlackImpl } from "openhoof/plugin-sdk/slack";
import { handleSlackAction as handleSlackActionImpl } from "openhoof/plugin-sdk/slack";
import type { PluginRuntimeChannel } from "./types-channel.js";

type RuntimeSlackOps = Pick<
  PluginRuntimeChannel["slack"],
  | "listDirectoryGroupsLive"
  | "listDirectoryPeersLive"
  | "probeSlack"
  | "resolveChannelAllowlist"
  | "resolveUserAllowlist"
  | "sendMessageSlack"
  | "monitorSlackProvider"
  | "handleSlackAction"
>;

export const runtimeSlackOps = {
  listDirectoryGroupsLive: listSlackDirectoryGroupsLiveImpl,
  listDirectoryPeersLive: listSlackDirectoryPeersLiveImpl,
  probeSlack: probeSlackImpl,
  resolveChannelAllowlist: resolveSlackChannelAllowlistImpl,
  resolveUserAllowlist: resolveSlackUserAllowlistImpl,
  sendMessageSlack: sendMessageSlackImpl,
  monitorSlackProvider: monitorSlackProviderImpl,
  handleSlackAction: handleSlackActionImpl,
} satisfies RuntimeSlackOps;
