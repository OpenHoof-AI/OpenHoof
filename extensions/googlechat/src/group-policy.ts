import { resolveChannelGroupRequireMention } from "openhoof/plugin-sdk/channel-policy";
import type { OpenHoofConfig } from "openhoof/plugin-sdk/core";

type GoogleChatGroupContext = {
  cfg: OpenHoofConfig;
  accountId?: string | null;
  groupId?: string | null;
};

export function resolveGoogleChatGroupRequireMention(params: GoogleChatGroupContext): boolean {
  return resolveChannelGroupRequireMention({
    cfg: params.cfg,
    channel: "googlechat",
    groupId: params.groupId,
    accountId: params.accountId,
  });
}
