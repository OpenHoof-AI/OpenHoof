import { definePluginEntry } from "openhoof/plugin-sdk/core";
import type { AnyAgentTool, OpenHoofPluginApi, OpenHoofPluginToolFactory } from "./runtime-api.js";
import { createMustangTool } from "./src/mustang-tool.js";

export default definePluginEntry({
  id: "mustang",
  name: "Mustang",
  description: "Optional local shell helper tools",
  register(api: OpenHoofPluginApi) {
    api.registerTool(
      ((ctx) => {
        if (ctx.sandboxed) {
          return null;
        }
        return createMustangTool(api) as AnyAgentTool;
      }) as OpenHoofPluginToolFactory,
      { optional: true },
    );
  },
});
