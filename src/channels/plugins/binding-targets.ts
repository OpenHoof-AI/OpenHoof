import type { OpenHoofConfig } from "../../config/config.js";
import type { ConfiguredBindingResolution } from "./binding-types.js";
import { ensureStatefulTargetBuiltinsRegistered } from "./stateful-target-builtins.js";
import {
  getStatefulBindingTargetDriver,
  resolveStatefulBindingTargetBySessionKey,
} from "./stateful-target-drivers.js";

export async function ensureConfiguredBindingTargetReady(params: {
  cfg: OpenHoofConfig;
  bindingResolution: ConfiguredBindingResolution | null;
}): Promise<{ ok: true } | { ok: false; error: string }> {
  ensureStatefulTargetBuiltinsRegistered();
  if (!params.bindingResolution) {
    return { ok: true };
  }
  const driver = getStatefulBindingTargetDriver(params.bindingResolution.statefulTarget.driverId);
  if (!driver) {
    return {
      ok: false,
      error: `Configured binding target driver unavailable: ${params.bindingResolution.statefulTarget.driverId}`,
    };
  }
  return await driver.ensureReady({
    cfg: params.cfg,
    bindingResolution: params.bindingResolution,
  });
}

export async function resetConfiguredBindingTargetInPlace(params: {
  cfg: OpenHoofConfig;
  sessionKey: string;
  reason: "new" | "reset";
}): Promise<{ ok: true } | { ok: false; skipped?: boolean; error?: string }> {
  ensureStatefulTargetBuiltinsRegistered();
  const resolved = resolveStatefulBindingTargetBySessionKey({
    cfg: params.cfg,
    sessionKey: params.sessionKey,
  });
  if (!resolved?.driver.resetInPlace) {
    return {
      ok: false,
      skipped: true,
    };
  }
  return await resolved.driver.resetInPlace({
    ...params,
    bindingTarget: resolved.bindingTarget,
  });
}

export async function ensureConfiguredBindingTargetSession(params: {
  cfg: OpenHoofConfig;
  bindingResolution: ConfiguredBindingResolution;
}): Promise<{ ok: true; sessionKey: string } | { ok: false; sessionKey: string; error: string }> {
  ensureStatefulTargetBuiltinsRegistered();
  const driver = getStatefulBindingTargetDriver(params.bindingResolution.statefulTarget.driverId);
  if (!driver) {
    return {
      ok: false,
      sessionKey: params.bindingResolution.statefulTarget.sessionKey,
      error: `Configured binding target driver unavailable: ${params.bindingResolution.statefulTarget.driverId}`,
    };
  }
  return await driver.ensureSession({
    cfg: params.cfg,
    bindingResolution: params.bindingResolution,
  });
}
