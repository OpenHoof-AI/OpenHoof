import { afterEach, describe, expect, it, vi } from "vitest";

type LoggerModule = typeof import("./logger.js");

const originalGetBuiltinModule = (
  process as NodeJS.Process & { getBuiltinModule?: (id: string) => unknown }
).getBuiltinModule;

async function importBrowserSafeLogger(params?: {
  resolvePreferredOpenHoofTmpDir?: ReturnType<typeof vi.fn>;
}): Promise<{
  module: LoggerModule;
  resolvePreferredOpenHoofTmpDir: ReturnType<typeof vi.fn>;
}> {
  vi.resetModules();
  const resolvePreferredOpenHoofTmpDir =
    params?.resolvePreferredOpenHoofTmpDir ??
    vi.fn(() => {
      throw new Error("resolvePreferredOpenHoofTmpDir should not run during browser-safe import");
    });

  vi.doMock("../infra/tmp-openhoof-dir.js", async () => {
    const actual = await vi.importActual<typeof import("../infra/tmp-openhoof-dir.js")>(
      "../infra/tmp-openhoof-dir.js",
    );
    return {
      ...actual,
      resolvePreferredOpenHoofTmpDir,
    };
  });

  Object.defineProperty(process, "getBuiltinModule", {
    configurable: true,
    value: undefined,
  });

  const module = await import("./logger.js");
  return { module, resolvePreferredOpenHoofTmpDir };
}

describe("logging/logger browser-safe import", () => {
  afterEach(() => {
    vi.resetModules();
    vi.doUnmock("../infra/tmp-openhoof-dir.js");
    Object.defineProperty(process, "getBuiltinModule", {
      configurable: true,
      value: originalGetBuiltinModule,
    });
  });

  it("does not resolve the preferred temp dir at import time when node fs is unavailable", async () => {
    const { module, resolvePreferredOpenHoofTmpDir } = await importBrowserSafeLogger();

    expect(resolvePreferredOpenHoofTmpDir).not.toHaveBeenCalled();
    expect(module.DEFAULT_LOG_DIR).toBe("/tmp/openhoof");
    expect(module.DEFAULT_LOG_FILE).toBe("/tmp/openhoof/openhoof.log");
  });

  it("disables file logging when imported in a browser-like environment", async () => {
    const { module, resolvePreferredOpenHoofTmpDir } = await importBrowserSafeLogger();

    expect(module.getResolvedLoggerSettings()).toMatchObject({
      level: "silent",
      file: "/tmp/openhoof/openhoof.log",
    });
    expect(module.isFileLogLevelEnabled("info")).toBe(false);
    expect(() => module.getLogger().info("browser-safe")).not.toThrow();
    expect(resolvePreferredOpenHoofTmpDir).not.toHaveBeenCalled();
  });
});
