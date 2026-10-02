import type { Metadata } from "next";
import { site } from "./config";
import { publicOrigin } from "./site-origin";

export function metadata(
  title: string,
  description: string,
  path: string,
  draft = false,
): Metadata {
  const origin = publicOrigin();
  const publicSite = Boolean(origin) && process.env.VERCEL_ENV !== "preview";

  return {
    title,
    description,
    alternates: publicSite
      ? { canonical: new URL(path, origin).href }
      : undefined,
    robots: { index: publicSite && !draft, follow: !draft },
    openGraph: {
      title: title + " | Themis Family",
      description,
      type: "website",
      locale: "en_GB",
      siteName: site.name,
      ...(publicSite ? { url: new URL(path, origin).href } : {}),
    },
    twitter: { card: "summary_large_image", title, description },
  };
}
