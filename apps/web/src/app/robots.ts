import type { MetadataRoute } from "next";
import { site } from "@/lib/config";
export default function robots(): MetadataRoute.Robots {
  return !site.origin || process.env.VERCEL_ENV === "preview"
    ? { rules: { userAgent: "*", disallow: "/" } }
    : {
        rules: {
          userAgent: "*",
          allow: "/",
          disallow: [
            "/api/",
            "/legal/privacy-policy",
            "/legal/terms",
            "/insights/a-clearer-homework-agreement",
            "/insights/room-for-an-exception",
            "/insights/privacy-is-part-of-the-conversation",
          ],
        },
        sitemap: new URL("/sitemap.xml", site.origin).href,
      };
}
