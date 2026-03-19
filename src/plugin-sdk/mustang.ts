// Public Mustang plugin helpers.
// Keep this surface narrow and limited to the Mustang workflow/tool contract.

export { definePluginEntry } from "./core.js";
export {
  applyWindowsSpawnProgramPolicy,
  materializeWindowsSpawnProgram,
  resolveWindowsSpawnProgramCandidate,
} from "./windows-spawn.js";
export type {
  AnyAgentTool,
  OpenHoofPluginApi,
  OpenHoofPluginToolContext,
  OpenHoofPluginToolFactory,
} from "../plugins/types.js";
