import path from "node:path";

export const unitTestIncludePatterns = [
  "src/**/*.test.ts",
  "test/**/*.test.ts",
  "ui/src/ui/app-chat.test.ts",
  "ui/src/ui/views/agents-utils.test.ts",
  "ui/src/ui/views/chat.test.ts",
  "ui/src/ui/views/usage-render-details.test.ts",
  "ui/src/ui/controllers/agents.test.ts",
  "ui/src/ui/controllers/chat.test.ts",
];

export const unitTestAdditionalExcludePatterns = [
  "src/gateway/**",
  "extensions/**",
  "src/browser/**",
  "src/line/**",
  "src/agents/**",
  "src/auto-reply/**",
  "src/commands/**",
  // tts/tts.test.ts runs summarizeText tests that use vi.resetModules() + dynamic
  // import per-test. Even fully mocked, each test incurs ~500-800ms of module
  // reload overhead (5 tests × ~650ms ≈ 3-4s). Exclude from the low-profile fast
  // lane to prevent it from contributing to CI timeout.
  "src/tts/tts.test.ts",
  // The following files use vi.resetModules() in beforeEach with a high test count,
  // making each test pay 500-700ms module-reload overhead. At 3 CI workers these
  // files dominate wall-clock time on the unit-fast lane. They are covered by the
  // full test run (pnpm test) and excluded only from the CI timeout-sensitive lane.
  //
  // command-secret-gateway: 23 tests × ~600ms each ≈ ~14s elapsed per worker slot.
  "src/cli/command-secret-gateway.test.ts",
  // security/windows-acl: 48 tests × ~600ms (resetModules in beforeEach) ≈ ~29s.
  "src/security/windows-acl.test.ts",
  // infra/outbound/deliver: 43 tests × ~600ms ≈ ~26s.
  "src/infra/outbound/deliver.test.ts",
  // infra/restart-stale-pids: 37 tests × ~600ms ≈ ~22s.
  "src/infra/restart-stale-pids.test.ts",
  // acp/control-plane/manager: 33 tests × ~600ms (resetModules + fake timers) ≈ ~20s.
  "src/acp/control-plane/manager.test.ts",
  // cli/memory-cli: 24 tests × ~600ms ≈ ~14s.
  "src/cli/memory-cli.test.ts",
];

const sharedBaseExcludePatterns = [
  "dist/**",
  "apps/macos/**",
  "apps/macos/.build/**",
  "**/node_modules/**",
  "**/vendor/**",
  "dist/OpenHoof.app/**",
  "**/*.live.test.ts",
  "**/*.e2e.test.ts",
];

const normalizeRepoPath = (value) => value.split(path.sep).join("/");

const matchesAny = (file, patterns) => patterns.some((pattern) => path.matchesGlob(file, pattern));

export function isUnitConfigTestFile(file) {
  const normalizedFile = normalizeRepoPath(file);
  return (
    matchesAny(normalizedFile, unitTestIncludePatterns) &&
    !matchesAny(normalizedFile, sharedBaseExcludePatterns) &&
    !matchesAny(normalizedFile, unitTestAdditionalExcludePatterns)
  );
}
