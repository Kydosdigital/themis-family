import type { MetadataRoute } from "next";
import { site, publicPaths } from "@/lib/config";
import { articles } from "@/lib/articles";

export default function sitemap(): MetadataRoute.Sitemap {
  if (!site.origin || process.env.VERCEL_ENV === "preview") return [];

  const staticPages = publicPaths.map((path) => ({
    url: new URL(path, site.origin).href,
  }));

  const editorialPages = articles
    .filter((article) => !article.draft)
    .map((article) => ({
      url: new URL("/insights/" + article.slug, site.origin).href,
      lastModified: new Date(article.updated + "T00:00:00Z"),
    }));

  return [...staticPages, ...editorialPages];
}
