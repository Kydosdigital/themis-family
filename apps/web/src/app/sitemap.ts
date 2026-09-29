import type { MetadataRoute } from "next";
import { site, publicPaths } from "@/lib/config";
export default function sitemap(): MetadataRoute.Sitemap {
  if (!site.origin || process.env.VERCEL_ENV === "preview") return [];
  return publicPaths.map((path) => ({ url: new URL(path, site.origin).href }));
}
