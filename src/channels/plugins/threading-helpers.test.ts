import { describe, expect, it } from "vitest";
import type { OpenHoofConfig } from "../../config/config.js";
import {
  createScopedAccountReplyToModeResolver,
  createStaticReplyToModeResolver,
  createTopLevelChannelReplyToModeResolver,
} from "./threading-helpers.js";

describe("createStaticReplyToModeResolver", () => {
  it("always returns the configured mode", () => {
    expect(createStaticReplyToModeResolver("off")({ cfg: {} as OpenHoofConfig })).toBe("off");
    expect(createStaticReplyToModeResolver("all")({ cfg: {} as OpenHoofConfig })).toBe("all");
  });
});

describe("createTopLevelChannelReplyToModeResolver", () => {
  it("reads the top-level channel config", () => {
    const resolver = createTopLevelChannelReplyToModeResolver("discord");
    expect(
      resolver({
        cfg: { channels: { discord: { replyToMode: "first" } } } as OpenHoofConfig,
      }),
    ).toBe("first");
  });

  it("falls back to off", () => {
    const resolver = createTopLevelChannelReplyToModeResolver("discord");
    expect(resolver({ cfg: {} as OpenHoofConfig })).toBe("off");
  });
});

describe("createScopedAccountReplyToModeResolver", () => {
  it("reads the scoped account reply mode", () => {
    const resolver = createScopedAccountReplyToModeResolver({
      resolveAccount: (cfg, accountId) =>
        ((
          cfg.channels as {
            matrix?: { accounts?: Record<string, { replyToMode?: "off" | "first" | "all" }> };
          }
        ).matrix?.accounts?.[accountId?.toLowerCase() ?? "default"] ?? {}) as {
          replyToMode?: "off" | "first" | "all";
        },
      resolveReplyToMode: (account) => account.replyToMode,
    });

    const cfg = {
      channels: {
        matrix: {
          accounts: {
            assistant: { replyToMode: "all" },
          },
        },
      },
    } as OpenHoofConfig;

    expect(resolver({ cfg, accountId: "assistant" })).toBe("all");
    expect(resolver({ cfg, accountId: "default" })).toBe("off");
  });

  it("passes chatType through", () => {
    const seen: Array<string | null | undefined> = [];
    const resolver = createScopedAccountReplyToModeResolver({
      resolveAccount: () => ({ replyToMode: "first" as const }),
      resolveReplyToMode: (account, chatType) => {
        seen.push(chatType);
        return account.replyToMode;
      },
    });

    expect(resolver({ cfg: {} as OpenHoofConfig, chatType: "group" })).toBe("first");
    expect(seen).toEqual(["group"]);
  });
});
