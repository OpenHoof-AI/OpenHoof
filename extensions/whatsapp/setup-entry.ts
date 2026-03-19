import { defineSetupPluginEntry } from "openhoof/plugin-sdk/core";
import { whatsappSetupPlugin } from "./src/channel.setup.js";

export { whatsappSetupPlugin } from "./src/channel.setup.js";

export default defineSetupPluginEntry(whatsappSetupPlugin);
