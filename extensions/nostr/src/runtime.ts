import { createPluginRuntimeStore } from "openhoof/plugin-sdk/runtime-store";
import type { PluginRuntime } from "../api.js";

const { setRuntime: setNostrRuntime, getRuntime: getNostrRuntime } =
  createPluginRuntimeStore<PluginRuntime>("Nostr runtime not initialized");
export { getNostrRuntime, setNostrRuntime };
