import { describe, expect, it } from "vitest";
import { shortenText } from "./text-format.js";

describe("shortenText", () => {
  it("returns original text when it fits", () => {
    expect(shortenText("openhoof", 16)).toBe("openhoof");
  });

  it("truncates and appends ellipsis when over limit", () => {
    expect(shortenText("openhoof-status-output", 10)).toBe("openhoof-…");
  });

  it("counts multi-byte characters correctly", () => {
    expect(shortenText("hello🙂world", 7)).toBe("hello🙂…");
  });
});
