import type { ModelProviderConfig } from "openhoof/plugin-sdk/provider-models";

export const FREEDOMGPT_BASE_URL = "https://api.freedomgpt.com/v1";

const FREEDOMGPT_DEFAULT_MODEL_ID = "liberty-3";
const FREEDOMGPT_DEFAULT_CONTEXT_WINDOW = 128000;
const FREEDOMGPT_DEFAULT_MAX_TOKENS = 8192;
const FREEDOMGPT_DEFAULT_COST = {
  input: 0,
  output: 0,
  cacheRead: 0,
  cacheWrite: 0,
};

export function buildFreedomgptProvider(): ModelProviderConfig {
  return {
    baseUrl: FREEDOMGPT_BASE_URL,
    api: "openai-completions",
    models: [
      {
        id: FREEDOMGPT_DEFAULT_MODEL_ID,
        name: "Liberty 3",
        reasoning: false,
        input: ["text"],
        cost: FREEDOMGPT_DEFAULT_COST,
        contextWindow: FREEDOMGPT_DEFAULT_CONTEXT_WINDOW,
        maxTokens: FREEDOMGPT_DEFAULT_MAX_TOKENS,
      },
    ],
  };
}
