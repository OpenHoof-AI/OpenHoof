import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { formatSolBalance, getSolanaBalance, getSolanaWalletSummary } from "./solana-wallet.js";

describe("solana-wallet", () => {
  const mockFetch = vi.fn();

  beforeEach(() => {
    vi.stubGlobal("fetch", mockFetch);
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe("getSolanaBalance", () => {
    it("converts lamports to SOL rounded to 6 decimal places", async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ jsonrpc: "2.0", id: 1, result: { value: 284133744 } }),
      });

      const balance = await getSolanaBalance("F48hCCW1abcdef");
      expect(balance).toBeCloseTo(0.284134, 6);
      expect(mockFetch).toHaveBeenCalledOnce();
    });

    it("throws on non-ok response", async () => {
      mockFetch.mockResolvedValueOnce({ ok: false, status: 429, statusText: "Too Many Requests" });

      await expect(getSolanaBalance("F48hCCW1abcdef")).rejects.toThrow("Solana RPC error: 429");
    });
  });

  describe("formatSolBalance", () => {
    it("formats balance with SOL suffix", () => {
      expect(formatSolBalance(0.284)).toBe("0.284 SOL");
      expect(formatSolBalance(1.5)).toBe("1.5 SOL");
      expect(formatSolBalance(0)).toBe("0 SOL");
    });
  });

  describe("getSolanaWalletSummary", () => {
    it("returns summary with truncated address", async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ jsonrpc: "2.0", id: 1, result: { value: 284000000 } }),
      });

      const summary = await getSolanaWalletSummary("F48hCCW1LongAddressHere");
      expect(summary).toBe("Balance: 0.284 SOL | Address: F48hCCW1...");
    });
  });
});
