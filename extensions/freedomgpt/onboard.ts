import {
  applyAgentDefaultModelPrimary,
  type OpenHoofConfig,
} from "openhoof/plugin-sdk/provider-onboard";

export const FREEDOMGPT_DEFAULT_MODEL_REF = "freedomgpt/liberty-3";

export function applyFreedomgptProviderConfig(cfg: OpenHoofConfig): OpenHoofConfig {
  const models = { ...cfg.agents?.defaults?.models };
  models[FREEDOMGPT_DEFAULT_MODEL_REF] = {
    ...models[FREEDOMGPT_DEFAULT_MODEL_REF],
    alias: models[FREEDOMGPT_DEFAULT_MODEL_REF]?.alias ?? "Liberty 3",
  };

  return {
    ...cfg,
    agents: {
      ...cfg.agents,
      defaults: {
        ...cfg.agents?.defaults,
        models,
      },
    },
  };
}

export function applyFreedomgptConfig(cfg: OpenHoofConfig): OpenHoofConfig {
  return applyAgentDefaultModelPrimary(
    applyFreedomgptProviderConfig(cfg),
    FREEDOMGPT_DEFAULT_MODEL_REF,
  );
}
