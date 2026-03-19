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
  // loader.test.ts includes a test that loads real Discord extension files through
  // jiti (pulling in discord.js transitive deps). That single test has an explicit
  // 60 s timeout, which exceeds the 30 s --testTimeout used in CI's low profile.
  // Exclude the whole file from the low-profile lane so it doesn't flap or bail CI.
  "src/plugins/loader.test.ts",
  // deliver.test.ts contains tests that take 22+ seconds each (real network/IO
  // paths). They consistently blow the 30 s --testTimeout in CI's low profile and
  // cause bail-3 to trigger. Exclude from the low-profile fast lane.
  "src/infra/outbound/deliver.test.ts",
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
