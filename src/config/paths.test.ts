import fs from "node:fs/promises";
import path from "node:path";
import { describe, expect, it } from "vitest";
import { withTempDir } from "../test-helpers/temp-dir.js";
import {
  resolveDefaultConfigCandidates,
  resolveConfigPathCandidate,
  resolveConfigPath,
  resolveOAuthDir,
  resolveOAuthPath,
  resolveStateDir,
} from "./paths.js";

describe("oauth paths", () => {
  it("prefers OPENHOOF_OAUTH_DIR over OPENHOOF_STATE_DIR", () => {
    const env = {
      OPENHOOF_OAUTH_DIR: "/custom/oauth",
      OPENHOOF_STATE_DIR: "/custom/state",
    } as NodeJS.ProcessEnv;

    expect(resolveOAuthDir(env, "/custom/state")).toBe(path.resolve("/custom/oauth"));
    expect(resolveOAuthPath(env, "/custom/state")).toBe(
      path.join(path.resolve("/custom/oauth"), "oauth.json"),
    );
  });

  it("derives oauth path from OPENHOOF_STATE_DIR when unset", () => {
    const env = {
      OPENHOOF_STATE_DIR: "/custom/state",
    } as NodeJS.ProcessEnv;

    expect(resolveOAuthDir(env, "/custom/state")).toBe(path.join("/custom/state", "credentials"));
    expect(resolveOAuthPath(env, "/custom/state")).toBe(
      path.join("/custom/state", "credentials", "oauth.json"),
    );
  });
});

describe("state + config path candidates", () => {
  function expectOpenHoofHomeDefaults(env: NodeJS.ProcessEnv): void {
    const configuredHome = env.OPENHOOF_HOME;
    if (!configuredHome) {
      throw new Error("OPENHOOF_HOME must be set for this assertion helper");
    }
    const resolvedHome = path.resolve(configuredHome);
    expect(resolveStateDir(env)).toBe(path.join(resolvedHome, ".openhoof"));

    const candidates = resolveDefaultConfigCandidates(env);
    expect(candidates[0]).toBe(path.join(resolvedHome, ".openhoof", "openhoof.json"));
  }

  it("uses OPENHOOF_STATE_DIR when set", () => {
    const env = {
      OPENHOOF_STATE_DIR: "/new/state",
    } as NodeJS.ProcessEnv;

    expect(resolveStateDir(env, () => "/home/test")).toBe(path.resolve("/new/state"));
  });

  it("uses OPENHOOF_HOME for default state/config locations", () => {
    const env = {
      OPENHOOF_HOME: "/srv/openhoof-home",
    } as NodeJS.ProcessEnv;
    expectOpenHoofHomeDefaults(env);
  });

  it("prefers OPENHOOF_HOME over HOME for default state/config locations", () => {
    const env = {
      OPENHOOF_HOME: "/srv/openhoof-home",
      HOME: "/home/other",
    } as NodeJS.ProcessEnv;
    expectOpenHoofHomeDefaults(env);
  });

  it("orders default config candidates in a stable order", () => {
    const home = "/home/test";
    const resolvedHome = path.resolve(home);
    const candidates = resolveDefaultConfigCandidates({} as NodeJS.ProcessEnv, () => home);
    const expected = [
      path.join(resolvedHome, ".openhoof", "openhoof.json"),
      path.join(resolvedHome, ".openhoof", "hoofbot.json"),
      path.join(resolvedHome, ".openhoof", "moldbot.json"),
      path.join(resolvedHome, ".openhoof", "moltbot.json"),
      path.join(resolvedHome, ".hoofbot", "openhoof.json"),
      path.join(resolvedHome, ".hoofbot", "hoofbot.json"),
      path.join(resolvedHome, ".hoofbot", "moldbot.json"),
      path.join(resolvedHome, ".hoofbot", "moltbot.json"),
      path.join(resolvedHome, ".moldbot", "openhoof.json"),
      path.join(resolvedHome, ".moldbot", "hoofbot.json"),
      path.join(resolvedHome, ".moldbot", "moldbot.json"),
      path.join(resolvedHome, ".moldbot", "moltbot.json"),
      path.join(resolvedHome, ".moltbot", "openhoof.json"),
      path.join(resolvedHome, ".moltbot", "hoofbot.json"),
      path.join(resolvedHome, ".moltbot", "moldbot.json"),
      path.join(resolvedHome, ".moltbot", "moltbot.json"),
    ];
    expect(candidates).toEqual(expected);
  });

  it("prefers ~/.openhoof when it exists and legacy dir is missing", async () => {
    await withTempDir({ prefix: "openhoof-state-" }, async (root) => {
      const newDir = path.join(root, ".openhoof");
      await fs.mkdir(newDir, { recursive: true });
      const resolved = resolveStateDir({} as NodeJS.ProcessEnv, () => root);
      expect(resolved).toBe(newDir);
    });
  });

  it("falls back to existing legacy state dir when ~/.openhoof is missing", async () => {
    await withTempDir({ prefix: "openhoof-state-legacy-" }, async (root) => {
      const legacyDir = path.join(root, ".hoofbot");
      await fs.mkdir(legacyDir, { recursive: true });
      const resolved = resolveStateDir({} as NodeJS.ProcessEnv, () => root);
      expect(resolved).toBe(legacyDir);
    });
  });

  it("CONFIG_PATH prefers existing config when present", async () => {
    await withTempDir({ prefix: "openhoof-config-" }, async (root) => {
      const legacyDir = path.join(root, ".openhoof");
      await fs.mkdir(legacyDir, { recursive: true });
      const legacyPath = path.join(legacyDir, "openhoof.json");
      await fs.writeFile(legacyPath, "{}", "utf-8");

      const resolved = resolveConfigPathCandidate({} as NodeJS.ProcessEnv, () => root);
      expect(resolved).toBe(legacyPath);
    });
  });

  it("respects state dir overrides when config is missing", async () => {
    await withTempDir({ prefix: "openhoof-config-override-" }, async (root) => {
      const legacyDir = path.join(root, ".openhoof");
      await fs.mkdir(legacyDir, { recursive: true });
      const legacyConfig = path.join(legacyDir, "openhoof.json");
      await fs.writeFile(legacyConfig, "{}", "utf-8");

      const overrideDir = path.join(root, "override");
      const env = { OPENHOOF_STATE_DIR: overrideDir } as NodeJS.ProcessEnv;
      const resolved = resolveConfigPath(env, overrideDir, () => root);
      expect(resolved).toBe(path.join(overrideDir, "openhoof.json"));
    });
  });
});
