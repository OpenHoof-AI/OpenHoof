import type { Command } from "commander";
import { formatDocsLink } from "../terminal/links.js";
import { theme } from "../terminal/theme.js";
import { registerQrCli } from "./qr-cli.js";

export function registerHoofbotCli(program: Command) {
  const hoofbot = program
    .command("hoofbot")
    .description("Legacy hoofbot command aliases")
    .addHelpText(
      "after",
      () =>
        `\n${theme.muted("Docs:")} ${formatDocsLink("/cli/hoofbot", "docs.openhoof.ai/cli/hoofbot")}\n`,
    );
  registerQrCli(hoofbot);
}
