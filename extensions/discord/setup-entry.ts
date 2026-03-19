import { defineSetupPluginEntry } from "openhoof/plugin-sdk/core";
import { discordSetupPlugin } from "./src/channel.setup.js";

export { discordSetupPlugin } from "./src/channel.setup.js";

export default defineSetupPluginEntry(discordSetupPlugin);
