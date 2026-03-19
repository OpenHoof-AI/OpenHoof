import type { OpenHoofConfig } from "./config.js";

export function ensurePluginAllowlisted(cfg: OpenHoofConfig, pluginId: string): OpenHoofConfig {
  const allow = cfg.plugins?.allow;
  if (!Array.isArray(allow) || allow.includes(pluginId)) {
    return cfg;
  }
  return {
    ...cfg,
    plugins: {
      ...cfg.plugins,
      allow: [...allow, pluginId],
    },
  };
}
