import { describe, expect, it } from "vitest";
import { resolveIrcInboundTarget } from "./monitor.js";

describe("irc monitor inbound target", () => {
  it("keeps channel target for group messages", () => {
    expect(
      resolveIrcInboundTarget({
        target: "#openhoof",
        senderNick: "alice",
      }),
    ).toEqual({
      isGroup: true,
      target: "#openhoof",
      rawTarget: "#openhoof",
    });
  });

  it("maps DM target to sender nick and preserves raw target", () => {
    expect(
      resolveIrcInboundTarget({
        target: "openhoof-bot",
        senderNick: "alice",
      }),
    ).toEqual({
      isGroup: false,
      target: "alice",
      rawTarget: "openhoof-bot",
    });
  });

  it("falls back to raw target when sender nick is empty", () => {
    expect(
      resolveIrcInboundTarget({
        target: "openhoof-bot",
        senderNick: " ",
      }),
    ).toEqual({
      isGroup: false,
      target: "openhoof-bot",
      rawTarget: "openhoof-bot",
    });
  });
});
