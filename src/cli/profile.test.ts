import path from "node:path";
import { describe, expect, it } from "vitest";
import { formatCliCommand } from "./command-format.js";
import { applyCliProfileEnv, parseCliProfileArgs } from "./profile.js";

describe("parseCliProfileArgs", () => {
  it("leaves gateway --dev for subcommands", () => {
    const res = parseCliProfileArgs([
      "node",
      "openhoof",
      "gateway",
      "--dev",
      "--allow-unconfigured",
    ]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBeNull();
    expect(res.argv).toEqual(["node", "openhoof", "gateway", "--dev", "--allow-unconfigured"]);
  });

  it("still accepts global --dev before subcommand", () => {
    const res = parseCliProfileArgs(["node", "openhoof", "--dev", "gateway"]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBe("dev");
    expect(res.argv).toEqual(["node", "openhoof", "gateway"]);
  });

  it("parses --profile value and strips it", () => {
    const res = parseCliProfileArgs(["node", "openhoof", "--profile", "work", "status"]);
    if (!res.ok) {
      throw new Error(res.error);
    }
    expect(res.profile).toBe("work");
    expect(res.argv).toEqual(["node", "openhoof", "status"]);
  });

  it("rejects missing profile value", () => {
    const res = parseCliProfileArgs(["node", "openhoof", "--profile"]);
    expect(res.ok).toBe(false);
  });

  it.each([
    ["--dev first", ["node", "openhoof", "--dev", "--profile", "work", "status"]],
    ["--profile first", ["node", "openhoof", "--profile", "work", "--dev", "status"]],
  ])("rejects combining --dev with --profile (%s)", (_name, argv) => {
    const res = parseCliProfileArgs(argv);
    expect(res.ok).toBe(false);
  });
});

describe("applyCliProfileEnv", () => {
  it("fills env defaults for dev profile", () => {
    const env: Record<string, string | undefined> = {};
    applyCliProfileEnv({
      profile: "dev",
      env,
      homedir: () => "/home/peter",
    });
    const expectedStateDir = path.join(path.resolve("/home/peter"), ".openhoof-dev");
    expect(env.OPENHOOF_PROFILE).toBe("dev");
    expect(env.OPENHOOF_STATE_DIR).toBe(expectedStateDir);
    expect(env.OPENHOOF_CONFIG_PATH).toBe(path.join(expectedStateDir, "openhoof.json"));
    expect(env.OPENHOOF_GATEWAY_PORT).toBe("19001");
  });

  it("does not override explicit env values", () => {
    const env: Record<string, string | undefined> = {
      OPENHOOF_STATE_DIR: "/custom",
      OPENHOOF_GATEWAY_PORT: "19099",
    };
    applyCliProfileEnv({
      profile: "dev",
      env,
      homedir: () => "/home/peter",
    });
    expect(env.OPENHOOF_STATE_DIR).toBe("/custom");
    expect(env.OPENHOOF_GATEWAY_PORT).toBe("19099");
    expect(env.OPENHOOF_CONFIG_PATH).toBe(path.join("/custom", "openhoof.json"));
  });

  it("uses OPENHOOF_HOME when deriving profile state dir", () => {
    const env: Record<string, string | undefined> = {
      OPENHOOF_HOME: "/srv/openhoof-home",
      HOME: "/home/other",
    };
    applyCliProfileEnv({
      profile: "work",
      env,
      homedir: () => "/home/fallback",
    });

    const resolvedHome = path.resolve("/srv/openhoof-home");
    expect(env.OPENHOOF_STATE_DIR).toBe(path.join(resolvedHome, ".openhoof-work"));
    expect(env.OPENHOOF_CONFIG_PATH).toBe(
      path.join(resolvedHome, ".openhoof-work", "openhoof.json"),
    );
  });
});

describe("formatCliCommand", () => {
  it.each([
    {
      name: "no profile is set",
      cmd: "openhoof doctor --fix",
      env: {},
      expected: "openhoof doctor --fix",
    },
    {
      name: "profile is default",
      cmd: "openhoof doctor --fix",
      env: { OPENHOOF_PROFILE: "default" },
      expected: "openhoof doctor --fix",
    },
    {
      name: "profile is Default (case-insensitive)",
      cmd: "openhoof doctor --fix",
      env: { OPENHOOF_PROFILE: "Default" },
      expected: "openhoof doctor --fix",
    },
    {
      name: "profile is invalid",
      cmd: "openhoof doctor --fix",
      env: { OPENHOOF_PROFILE: "bad profile" },
      expected: "openhoof doctor --fix",
    },
    {
      name: "--profile is already present",
      cmd: "openhoof --profile work doctor --fix",
      env: { OPENHOOF_PROFILE: "work" },
      expected: "openhoof --profile work doctor --fix",
    },
    {
      name: "--dev is already present",
      cmd: "openhoof --dev doctor",
      env: { OPENHOOF_PROFILE: "dev" },
      expected: "openhoof --dev doctor",
    },
  ])("returns command unchanged when $name", ({ cmd, env, expected }) => {
    expect(formatCliCommand(cmd, env)).toBe(expected);
  });

  it("inserts --profile flag when profile is set", () => {
    expect(formatCliCommand("openhoof doctor --fix", { OPENHOOF_PROFILE: "work" })).toBe(
      "openhoof --profile work doctor --fix",
    );
  });

  it("trims whitespace from profile", () => {
    expect(formatCliCommand("openhoof doctor --fix", { OPENHOOF_PROFILE: "  jbopenhoof  " })).toBe(
      "openhoof --profile jbopenhoof doctor --fix",
    );
  });

  it("handles command with no args after openhoof", () => {
    expect(formatCliCommand("openhoof", { OPENHOOF_PROFILE: "test" })).toBe(
      "openhoof --profile test",
    );
  });

  it("handles pnpm wrapper", () => {
    expect(formatCliCommand("pnpm openhoof doctor", { OPENHOOF_PROFILE: "work" })).toBe(
      "pnpm openhoof --profile work doctor",
    );
  });
});
