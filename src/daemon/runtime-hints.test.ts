import { describe, expect, it } from "vitest";
import { buildPlatformRuntimeLogHints, buildPlatformServiceStartHints } from "./runtime-hints.js";

describe("buildPlatformRuntimeLogHints", () => {
  it("renders launchd log hints on darwin", () => {
    expect(
      buildPlatformRuntimeLogHints({
        platform: "darwin",
        env: {
          OPENHOOF_STATE_DIR: "/tmp/openhoof-state",
          OPENHOOF_LOG_PREFIX: "gateway",
        },
        systemdServiceName: "openhoof-gateway",
        windowsTaskName: "OpenHoof Gateway",
      }),
    ).toEqual([
      "Launchd stdout (if installed): /tmp/openhoof-state/logs/gateway.log",
      "Launchd stderr (if installed): /tmp/openhoof-state/logs/gateway.err.log",
    ]);
  });

  it("renders systemd and windows hints by platform", () => {
    expect(
      buildPlatformRuntimeLogHints({
        platform: "linux",
        systemdServiceName: "openhoof-gateway",
        windowsTaskName: "OpenHoof Gateway",
      }),
    ).toEqual(["Logs: journalctl --user -u openhoof-gateway.service -n 200 --no-pager"]);
    expect(
      buildPlatformRuntimeLogHints({
        platform: "win32",
        systemdServiceName: "openhoof-gateway",
        windowsTaskName: "OpenHoof Gateway",
      }),
    ).toEqual(['Logs: schtasks /Query /TN "OpenHoof Gateway" /V /FO LIST']);
  });
});

describe("buildPlatformServiceStartHints", () => {
  it("builds platform-specific service start hints", () => {
    expect(
      buildPlatformServiceStartHints({
        platform: "darwin",
        installCommand: "openhoof gateway install",
        startCommand: "openhoof gateway",
        launchAgentPlistPath: "~/Library/LaunchAgents/com.openhoof.gateway.plist",
        systemdServiceName: "openhoof-gateway",
        windowsTaskName: "OpenHoof Gateway",
      }),
    ).toEqual([
      "openhoof gateway install",
      "openhoof gateway",
      "launchctl bootstrap gui/$UID ~/Library/LaunchAgents/com.openhoof.gateway.plist",
    ]);
    expect(
      buildPlatformServiceStartHints({
        platform: "linux",
        installCommand: "openhoof gateway install",
        startCommand: "openhoof gateway",
        launchAgentPlistPath: "~/Library/LaunchAgents/com.openhoof.gateway.plist",
        systemdServiceName: "openhoof-gateway",
        windowsTaskName: "OpenHoof Gateway",
      }),
    ).toEqual([
      "openhoof gateway install",
      "openhoof gateway",
      "systemctl --user start openhoof-gateway.service",
    ]);
  });
});
