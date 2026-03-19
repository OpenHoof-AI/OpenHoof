import type { OpenHoofConfig } from "../../config/types.js";

export type DirectoryConfigParams = {
  cfg: OpenHoofConfig;
  accountId?: string | null;
  query?: string | null;
  limit?: number | null;
};
