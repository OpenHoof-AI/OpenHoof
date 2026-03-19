import { describe, expect, it } from "vitest";
import {
  ensureOpenHoofExecMarkerOnProcess,
  markOpenHoofExecEnv,
  OPENHOOF_CLI_ENV_VALUE,
  OPENHOOF_CLI_ENV_VAR,
} from "./openhoof-exec-env.js";

describe("markOpenHoofExecEnv", () => {
  it("returns a cloned env object with the exec marker set", () => {
    const env = { PATH: "/usr/bin", OPENHOOF_CLI: "0" };
    const marked = markOpenHoofExecEnv(env);

    expect(marked).toEqual({
      PATH: "/usr/bin",
      OPENHOOF_CLI: OPENHOOF_CLI_ENV_VALUE,
    });
    expect(marked).not.toBe(env);
    expect(env.OPENHOOF_CLI).toBe("0");
  });
});

describe("ensureOpenHoofExecMarkerOnProcess", () => {
  it("mutates and returns the provided process env", () => {
    const env: NodeJS.ProcessEnv = { PATH: "/usr/bin" };

    expect(ensureOpenHoofExecMarkerOnProcess(env)).toBe(env);
    expect(env[OPENHOOF_CLI_ENV_VAR]).toBe(OPENHOOF_CLI_ENV_VALUE);
  });

  it("defaults to mutating process.env when no env object is provided", () => {
    const previous = process.env[OPENHOOF_CLI_ENV_VAR];
    delete process.env[OPENHOOF_CLI_ENV_VAR];

    try {
      expect(ensureOpenHoofExecMarkerOnProcess()).toBe(process.env);
      expect(process.env[OPENHOOF_CLI_ENV_VAR]).toBe(OPENHOOF_CLI_ENV_VALUE);
    } finally {
      if (previous === undefined) {
        delete process.env[OPENHOOF_CLI_ENV_VAR];
      } else {
        process.env[OPENHOOF_CLI_ENV_VAR] = previous;
      }
    }
  });
});
