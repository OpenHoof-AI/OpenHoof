import { definePluginEntry } from "openhoof/plugin-sdk/core";
import { buildElevenLabsSpeechProvider } from "openhoof/plugin-sdk/speech";

export default definePluginEntry({
  id: "elevenlabs",
  name: "ElevenLabs Speech",
  description: "Bundled ElevenLabs speech provider",
  register(api) {
    api.registerSpeechProvider(buildElevenLabsSpeechProvider());
  },
});
