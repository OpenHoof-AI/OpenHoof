// Barrel exports for the web channel pieces. Splitting the original 900+ line
// module keeps responsibilities small and testable.
export {
  DEFAULT_WEB_MEDIA_BYTES,
  HEARTBEAT_PROMPT,
  HEARTBEAT_TOKEN,
  monitorWebChannel,
  resolveHeartbeatRecipients,
  runWebHeartbeatOnce,
} from "openhoof/plugin-sdk/whatsapp";
export {
  extractMediaPlaceholder,
  extractText,
  monitorWebInbox,
} from "openhoof/plugin-sdk/whatsapp";
export { loginWeb } from "openhoof/plugin-sdk/whatsapp";
export { loadWebMedia, optimizeImageToJpeg } from "./media/web-media.js";
export { sendMessageWhatsApp } from "openhoof/plugin-sdk/whatsapp";
export {
  createWaSocket,
  formatError,
  getStatusCode,
  logoutWeb,
  logWebSelfId,
  pickWebChannel,
  WA_WEB_AUTH_DIR,
  waitForWaConnection,
  webAuthExists,
} from "openhoof/plugin-sdk/whatsapp";
