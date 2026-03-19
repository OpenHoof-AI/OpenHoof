// Narrow plugin-sdk surface for the bundled diffs plugin.
// Keep this list additive and scoped to symbols used under extensions/diffs.

export type { OpenHoofConfig } from "../config/config.js";
export { resolvePreferredOpenHoofTmpDir } from "../infra/tmp-openhoof-dir.js";
export type {
  AnyAgentTool,
  OpenHoofPluginApi,
  OpenHoofPluginConfigSchema,
  PluginLogger,
} from "../plugins/types.js";
