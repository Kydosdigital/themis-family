import { site } from "./config";

export function publicOrigin() {
  const vercelProductionHost = process.env.VERCEL_PROJECT_PRODUCTION_URL || "";
  const origin =
    site.origin || (vercelProductionHost ? "https://" + vercelProductionHost : "");

  return /^https:\/\//.test(origin) ? origin.replace(/\/$/, "") : "";
}
