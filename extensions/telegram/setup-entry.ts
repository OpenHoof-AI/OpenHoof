import { defineSetupPluginEntry } from "openhoof/plugin-sdk/core";
import { telegramSetupPlugin } from "./src/channel.setup.js";

export { telegramSetupPlugin } from "./src/channel.setup.js";

export default defineSetupPluginEntry(telegramSetupPlugin);
