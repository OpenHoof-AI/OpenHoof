import {
  createTopLevelChannelDmPolicySetter,
  normalizeAccountId,
  patchScopedAccountConfig,
  prepareScopedSetupConfig,
  type ChannelSetupAdapter,
  type DmPolicy,
  type OpenHoofConfig,
} from "openhoof/plugin-sdk/setup";
import { applyBlueBubblesConnectionConfig } from "./config-apply.js";

const channel = "bluebubbles" as const;
const setBlueBubblesTopLevelDmPolicy = createTopLevelChannelDmPolicySetter({
  channel,
});

export function setBlueBubblesDmPolicy(cfg: OpenHoofConfig, dmPolicy: DmPolicy): OpenHoofConfig {
  return setBlueBubblesTopLevelDmPolicy(cfg, dmPolicy);
}

export function setBlueBubblesAllowFrom(
  cfg: OpenHoofConfig,
  accountId: string,
  allowFrom: string[],
): OpenHoofConfig {
  return patchScopedAccountConfig({
    cfg,
    channelKey: channel,
    accountId,
    patch: { allowFrom },
    ensureChannelEnabled: false,
    ensureAccountEnabled: false,
  });
}

export const blueBubblesSetupAdapter: ChannelSetupAdapter = {
  resolveAccountId: ({ accountId }) => normalizeAccountId(accountId),
  applyAccountName: ({ cfg, accountId, name }) =>
    prepareScopedSetupConfig({
      cfg,
      channelKey: channel,
      accountId,
      name,
    }),
  validateInput: ({ input }) => {
    if (!input.httpUrl && !input.password) {
      return "BlueBubbles requires --http-url and --password.";
    }
    if (!input.httpUrl) {
      return "BlueBubbles requires --http-url.";
    }
    if (!input.password) {
      return "BlueBubbles requires --password.";
    }
    return null;
  },
  applyAccountConfig: ({ cfg, accountId, input }) => {
    const next = prepareScopedSetupConfig({
      cfg,
      channelKey: channel,
      accountId,
      name: input.name,
      migrateBaseName: true,
    });
    return applyBlueBubblesConnectionConfig({
      cfg: next,
      accountId,
      patch: {
        serverUrl: input.httpUrl,
        password: input.password,
        webhookPath: input.webhookPath,
      },
      onlyDefinedFields: true,
    });
  },
};
