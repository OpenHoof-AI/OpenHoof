import { definePluginEntry } from "openhoof/plugin-sdk/core";
import { buildMicrosoftSpeechProvider } from "openhoof/plugin-sdk/speech";

export default definePluginEntry({
  id: "microsoft",
  name: "Microsoft Speech",
  description: "Bundled Microsoft speech provider",
  register(api) {
    api.registerSpeechProvider(buildMicrosoftSpeechProvider());
  },
});
