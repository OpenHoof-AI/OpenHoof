import chalk, { Chalk } from "chalk";
import { MUSTANG_PALETTE } from "./palette.js";

const hasForceColor =
  typeof process.env.FORCE_COLOR === "string" &&
  process.env.FORCE_COLOR.trim().length > 0 &&
  process.env.FORCE_COLOR.trim() !== "0";

const baseChalk = process.env.NO_COLOR && !hasForceColor ? new Chalk({ level: 0 }) : chalk;

const hex = (value: string) => baseChalk.hex(value);

export const theme = {
  accent: hex(MUSTANG_PALETTE.accent),
  accentBright: hex(MUSTANG_PALETTE.accentBright),
  accentDim: hex(MUSTANG_PALETTE.accentDim),
  info: hex(MUSTANG_PALETTE.info),
  success: hex(MUSTANG_PALETTE.success),
  warn: hex(MUSTANG_PALETTE.warn),
  error: hex(MUSTANG_PALETTE.error),
  muted: hex(MUSTANG_PALETTE.muted),
  heading: baseChalk.bold.hex(MUSTANG_PALETTE.accent),
  command: hex(MUSTANG_PALETTE.accentBright),
  option: hex(MUSTANG_PALETTE.warn),
} as const;

export const isRich = () => Boolean(baseChalk.level > 0);

export const colorize = (rich: boolean, color: (value: string) => string, value: string) =>
  rich ? color(value) : value;
