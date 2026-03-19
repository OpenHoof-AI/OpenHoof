import type { Command } from "commander";
import { defaultRuntime } from "../../runtime.js";
import { runCommandWithRuntime } from "../cli-utils.js";

export function registerWalletCommand(program: Command) {
  program
    .command("wallet")
    .description("Show Solana wallet balance and link to Solscan")
    .argument("[address]", "Solana wallet address (defaults to OPENHOOF_SOLANA_WALLET)")
    .action(async (address: string | undefined) => {
      await runCommandWithRuntime(defaultRuntime, async () => {
        const mod = await import("../../commands/wallet/index.js");
        await mod.walletCommand({ address }, defaultRuntime);
      });
    });
}
