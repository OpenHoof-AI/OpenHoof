import type { PluginRuntime } from "openhoof/plugin-sdk/core";
import { createPluginRuntimeStore } from "openhoof/plugin-sdk/runtime-store";

const { setRuntime: setSlackRuntime, getRuntime: getSlackRuntime } =
  createPluginRuntimeStore<PluginRuntime>("Slack runtime not initialized");
export { getSlackRuntime, setSlackRuntime };
