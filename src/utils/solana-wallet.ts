const SOLANA_RPC_URL = "https://api.mainnet-beta.solana.com";
const LAMPORTS_PER_SOL = 1_000_000_000;

interface JsonRpcResponse {
  jsonrpc: string;
  id: number;
  result: { value: number };
}

/** Fetches the SOL balance for a Solana wallet address via mainnet-beta JSON-RPC. */
export async function getSolanaBalance(address: string): Promise<number> {
  const response = await fetch(SOLANA_RPC_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      jsonrpc: "2.0",
      id: 1,
      method: "getBalance",
      params: [address],
    }),
  });

  if (!response.ok) {
    throw new Error(`Solana RPC error: ${response.status} ${response.statusText}`);
  }

  const data = (await response.json()) as JsonRpcResponse;
  const lamports = data.result.value;
  return Math.round((lamports / LAMPORTS_PER_SOL) * 1e6) / 1e6;
}

/** Formats a SOL amount as a human-readable string (e.g. "0.284 SOL"). */
export function formatSolBalance(sol: number): string {
  return `${sol} SOL`;
}

/** Returns a summary string with balance and truncated address. */
export async function getSolanaWalletSummary(address: string): Promise<string> {
  const balance = await getSolanaBalance(address);
  const truncated = `${address.slice(0, 8)}...`;
  return `Balance: ${formatSolBalance(balance)} | Address: ${truncated}`;
}
