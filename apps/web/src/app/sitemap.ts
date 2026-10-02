import type { MetadataRoute } from "next";
import { publicPaths } from "@/lib/config";
import { articles } from "@/lib/articles";
import { publicOrigin } from "@/lib/site-origin";

export default function sitemap(): MetadataRoute.Sitemap {
  const origin = publicOrigin();
  if (!origin || process.env.VERCEL_ENV === "preview") return [];

  const staticPages = publicPaths.map((path) => ({
    url: new URL(path, origin).href,
  }));

  const editorialPages = articles
    .filter((article) => !article.draft)
    .map((article) => ({
      url: new URL("/insights/" + article.slug, origin).href,
      lastModified: new Date(article.updated + "T00:00:00Z"),
    }));

  return [...staticPages, ...editorialPages];
}
