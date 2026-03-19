import { definePluginEntry } from "openhoof/plugin-sdk/core";
import { createProviderApiKeyAuthMethod } from "openhoof/plugin-sdk/provider-auth-api-key";
import { buildSingleProviderApiKeyCatalog } from "openhoof/plugin-sdk/provider-catalog";
import { applyFreedomgptConfig, FREEDOMGPT_DEFAULT_MODEL_REF } from "./onboard.js";
import { buildFreedomgptProvider } from "./provider-catalog.js";

const PROVIDER_ID = "freedomgpt";

export default definePluginEntry({
  id: PROVIDER_ID,
  name: "FreedomGPT Provider",
  description: "Bundled FreedomGPT provider plugin",
  register(api) {
    api.registerProvider({
      id: PROVIDER_ID,
      label: "FreedomGPT",
      docsPath: "/providers/freedomgpt",
      envVars: ["FREEDOMGPT_API_KEY"],
      auth: [
        createProviderApiKeyAuthMethod({
          providerId: PROVIDER_ID,
          methodId: "api-key",
          label: "FreedomGPT API key",
          hint: "Uncensored AI models",
          optionKey: "freedomgptApiKey",
          flagName: "--freedomgpt-api-key",
          envVar: "FREEDOMGPT_API_KEY",
          promptMessage: "Enter FreedomGPT API key",
          defaultModel: FREEDOMGPT_DEFAULT_MODEL_REF,
          expectedProviders: ["freedomgpt"],
          applyConfig: (cfg) => applyFreedomgptConfig(cfg),
          noteMessage: [
            "FreedomGPT provides uncensored AI models.",
            "Get your API key at: https://chat.freedomgpt.com/?open=api-key",
          ].join("\n"),
          noteTitle: "FreedomGPT",
          wizard: {
            choiceId: "freedomgpt-api-key",
            choiceLabel: "FreedomGPT API key",
            groupId: "freedomgpt",
            groupLabel: "FreedomGPT (Uncensored)",
            groupHint: "Uncensored AI models",
          },
        }),
      ],
      catalog: {
        order: "simple",
        run: (ctx) =>
          buildSingleProviderApiKeyCatalog({
            ctx,
            providerId: PROVIDER_ID,
            buildProvider: buildFreedomgptProvider,
          }),
      },
    });
  },
});
