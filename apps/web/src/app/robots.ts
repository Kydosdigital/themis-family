import type { MetadataRoute } from "next";
import { publicOrigin } from "@/lib/site-origin";

export default function robots(): MetadataRoute.Robots {
  const origin = publicOrigin();

  return !origin || process.env.VERCEL_ENV === "preview"
    ? { rules: { userAgent: "*", disallow: "/" } }
    : {
        rules: {
          userAgent: "*",
          allow: "/",
          disallow: ["/api/", "/legal/privacy-policy", "/legal/terms"],
        },
        sitemap: new URL("/sitemap.xml", origin).href,
      };
}
