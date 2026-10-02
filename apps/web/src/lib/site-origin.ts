import { site } from "./config";

export function publicOrigin() {
  const vercelProductionHost = process.env.VERCEL_PROJECT_PRODUCTION_URL || "";
  const seoOrigin = process.env.SEO_SITE_URL || "";
  const origin =
    seoOrigin ||
    site.origin ||
    (vercelProductionHost ? "https://" + vercelProductionHost : "");

  return /^https:\/\//.test(origin) ? origin.replace(/\/$/, "") : "";
}
