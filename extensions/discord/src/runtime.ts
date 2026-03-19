import type { PluginRuntime } from "openhoof/plugin-sdk/core";
import { createPluginRuntimeStore } from "openhoof/plugin-sdk/runtime-store";

const { setRuntime: setDiscordRuntime, getRuntime: getDiscordRuntime } =
  createPluginRuntimeStore<PluginRuntime>("Discord runtime not initialized");
export { getDiscordRuntime, setDiscordRuntime };
