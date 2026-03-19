export const OPENHOOF_CLI_ENV_VAR = "OPENHOOF_CLI";
export const OPENHOOF_CLI_ENV_VALUE = "1";

export function markOpenHoofExecEnv<T extends Record<string, string | undefined>>(env: T): T {
  return {
    ...env,
    [OPENHOOF_CLI_ENV_VAR]: OPENHOOF_CLI_ENV_VALUE,
  };
}

export function ensureOpenHoofExecMarkerOnProcess(
  env: NodeJS.ProcessEnv = process.env,
): NodeJS.ProcessEnv {
  env[OPENHOOF_CLI_ENV_VAR] = OPENHOOF_CLI_ENV_VALUE;
  return env;
}
