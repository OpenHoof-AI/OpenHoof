import type { RuntimeEnv } from "../../runtime.js";
import { defaultRuntime } from "../../runtime.js";
import { getSolBalance, shortenAddress } from "../../utils/solana.js";

export type WalletCommandOptions = {
  address?: string;
};

export async function walletCommand(
  opts: WalletCommandOptions,
  runtime: RuntimeEnv = defaultRuntime,
): Promise<void> {
  const address = opts.address || process.env.OPENHOOF_SOLANA_WALLET;
  if (!address) {
    runtime.log(
      "No wallet address provided.\n" +
        "Pass an address as an argument or set OPENHOOF_SOLANA_WALLET in your environment.\n" +
        "  Example: openhoof wallet <address>",
    );
    return;
  }

  const balance = await getSolBalance(address);
  const short = shortenAddress(address);
  const solscanUrl = `https://solscan.io/account/${address}`;

  runtime.log(`Wallet: ${short}`);
  runtime.log(`Balance: ${balance} SOL`);
  runtime.log(`Solscan: ${solscanUrl}`);
}
