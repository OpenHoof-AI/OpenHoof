import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { formatSol, getSolBalance, shortenAddress } from "./solana.js";

describe("solana utils", () => {
  describe("getSolBalance", () => {
    beforeEach(() => {
      vi.stubGlobal(
        "fetch",
        vi.fn().mockResolvedValue({
          ok: true,
          json: async () => ({
            jsonrpc: "2.0",
            id: 1,
            result: { value: 284133744 },
          }),
        }),
      );
    });

    afterEach(() => {
      vi.restoreAllMocks();
    });

    it("converts lamports to SOL rounded to 6 decimals", async () => {
      const balance = await getSolBalance("SomeAddress123");
      expect(balance).toBe(0.284134);
    });

    it("calls the Solana RPC with getBalance", async () => {
      await getSolBalance("SomeAddress123");
      expect(fetch).toHaveBeenCalledWith("https://api.mainnet-beta.solana.com", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          jsonrpc: "2.0",
          id: 1,
          method: "getBalance",
          params: ["SomeAddress123"],
        }),
      });
    });
  });

  describe("formatSol", () => {
    it("formats lamports as SOL string", () => {
      expect(formatSol(284_000_000)).toBe("0.284 SOL");
    });

    it("formats whole SOL amounts", () => {
      expect(formatSol(1_000_000_000)).toBe("1 SOL");
    });

    it("formats zero", () => {
      expect(formatSol(0)).toBe("0 SOL");
    });

    it("formats large amounts", () => {
      expect(formatSol(15_500_000_000)).toBe("15.5 SOL");
    });
  });

  describe("shortenAddress", () => {
    it("shortens a long address", () => {
      const addr = "F48hCCW9VixruN2EqTTHFJBgJKYNQ";
      // first 8 + "..." + last 4
      expect(shortenAddress(addr)).toBe("F48hCCW9...KYNQ");
    });

    it("returns short addresses unchanged", () => {
      expect(shortenAddress("abc123")).toBe("abc123");
    });
  });
});
