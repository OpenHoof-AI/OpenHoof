import { existsSync } from "node:fs";
import path from "node:path";
import type { OpenHoofConfig } from "../../../config/config.js";

export function resolveConfiguredAcpBackendId(cfg: OpenHoofConfig): string {
  return cfg.acp?.backend?.trim() || "acpx";
}

export function resolveAcpInstallCommandHint(cfg: OpenHoofConfig): string {
  const configured = cfg.acp?.runtime?.installCommand?.trim();
  if (configured) {
    return configured;
  }
  const backendId = resolveConfiguredAcpBackendId(cfg).toLowerCase();
  if (backendId === "acpx") {
    const localPath = path.resolve(process.cwd(), "extensions/acpx");
    if (existsSync(localPath)) {
      return `openhoof plugins install ${localPath}`;
    }
    return "openhoof plugins install acpx";
  }
  return `Install and enable the plugin that provides ACP backend "${backendId}".`;
}
