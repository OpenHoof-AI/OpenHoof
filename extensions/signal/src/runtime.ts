import type { PluginRuntime } from "openhoof/plugin-sdk/core";
import { createPluginRuntimeStore } from "openhoof/plugin-sdk/runtime-store";

const { setRuntime: setSignalRuntime, getRuntime: getSignalRuntime } =
  createPluginRuntimeStore<PluginRuntime>("Signal runtime not initialized");
export { getSignalRuntime, setSignalRuntime };
