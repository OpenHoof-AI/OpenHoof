import { vi } from "vitest";
import { installChromeUserDataDirHooks } from "./chrome-user-data-dir.test-harness.js";

const chromeUserDataDir = { dir: "/tmp/openhoof" };
installChromeUserDataDirHooks(chromeUserDataDir);

vi.mock("./chrome.js", () => ({
  isChromeCdpReady: vi.fn(async () => true),
  isChromeReachable: vi.fn(async () => true),
  launchOpenHoofChrome: vi.fn(async () => {
    throw new Error("unexpected launch");
  }),
  resolveOpenHoofUserDataDir: vi.fn(() => chromeUserDataDir.dir),
  stopOpenHoofChrome: vi.fn(async () => {}),
}));
