import type { PluginRuntime } from "openhoof/plugin-sdk/core";
import { createPluginRuntimeStore } from "openhoof/plugin-sdk/runtime-store";

const { setRuntime: setTelegramRuntime, getRuntime: getTelegramRuntime } =
  createPluginRuntimeStore<PluginRuntime>("Telegram runtime not initialized");
export { getTelegramRuntime, setTelegramRuntime };
