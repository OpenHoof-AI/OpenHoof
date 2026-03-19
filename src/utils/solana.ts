const LAMPORTS_PER_SOL = 1_000_000_000;
const MAINNET_RPC = "https://api.mainnet-beta.solana.com";

type JsonRpcResponse<T> = {
  jsonrpc: string;
  id: number;
  result: T;
  error?: { code: number; message: string };
};

async function rpcCall<T>(method: string, params: unknown[]): Promise<T> {
  const res = await fetch(MAINNET_RPC, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ jsonrpc: "2.0", id: 1, method, params }),
  });
  if (!res.ok) {
    throw new Error(`Solana RPC error: ${res.status} ${res.statusText}`);
  }
  const json = (await res.json()) as JsonRpcResponse<T>;
  if (json.error) {
    throw new Error(`Solana RPC error: ${json.error.message}`);
  }
  return json.result;
}

export async function getSolBalance(address: string): Promise<number> {
  const result = await rpcCall<{ value: number }>("getBalance", [address]);
  return Math.round((result.value / LAMPORTS_PER_SOL) * 1e6) / 1e6;
}

export async function getRecentTransactions(
  address: string,
  limit = 5,
): Promise<Array<{ signature: string; slot: number }>> {
  const result = await rpcCall<Array<{ signature: string; slot: number }>>(
    "getSignaturesForAddress",
    [address, { limit }],
  );
  return result.map((tx) => ({ signature: tx.signature, slot: tx.slot }));
}

export function formatSol(lamports: number): string {
  const sol = lamports / LAMPORTS_PER_SOL;
  // Use up to 3 decimal places, trim trailing zeros
  const formatted = sol.toFixed(3).replace(/\.?0+$/, "");
  return `${formatted} SOL`;
}

export function shortenAddress(address: string): string {
  if (address.length <= 12) {
    return address;
  }
  return `${address.slice(0, 8)}...${address.slice(-4)}`;
}
