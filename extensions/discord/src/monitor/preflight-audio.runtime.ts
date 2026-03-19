import { transcribeFirstAudio as transcribeFirstAudioImpl } from "openhoof/plugin-sdk/media-runtime";

type TranscribeFirstAudio = typeof import("openhoof/plugin-sdk/media-runtime").transcribeFirstAudio;

export async function transcribeFirstAudio(
  ...args: Parameters<TranscribeFirstAudio>
): ReturnType<TranscribeFirstAudio> {
  return await transcribeFirstAudioImpl(...args);
}
