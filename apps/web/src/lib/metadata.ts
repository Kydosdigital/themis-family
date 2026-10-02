import type { Metadata } from "next";
import { site } from "./config";
import { publicOrigin } from "./site-origin";

function absoluteImage(image: string | undefined, origin: string) {
  if (!image) return undefined;
  if (/^https:\/\//.test(image)) return image;
  return origin ? new URL(image, origin).href : image;
}

export function metadata(
  title: string,
  description: string,
  path: string,
  draft = false,
  image?: string,
): Metadata {
  const origin = publicOrigin();
  const publicSite = Boolean(origin) && process.env.VERCEL_ENV !== "preview";
  const imageUrl = absoluteImage(image, origin);

  return {
    title: path === "/" ? { absolute: title + " | Themis Family" } : title,
    description,
    alternates: publicSite
      ? { canonical: new URL(path, origin).href }
      : undefined,
    robots: {
      index: publicSite && !draft,
      follow: !draft,
      googleBot: {
        index: publicSite && !draft,
        follow: !draft,
        "max-image-preview": "large",
        "max-snippet": -1,
        "max-video-preview": -1,
      },
    },
    openGraph: {
      title: title + " | Themis Family",
      description,
      type: "website",
      locale: "en_GB",
      siteName: site.name,
      ...(publicSite ? { url: new URL(path, origin).href } : {}),
      ...(imageUrl ? { images: [{ url: imageUrl, alt: title }] } : {}),
    },
    twitter: {
      card: "summary_large_image",
      title: title + " | Themis Family",
      description,
      ...(imageUrl ? { images: [imageUrl] } : {}),
    },
  };
}

export function articleMetadata({
  title,
  description,
  path,
  draft = false,
  image,
  datePublished,
  dateModified,
  section,
}: {
  title: string;
  description: string;
  path: string;
  draft?: boolean;
  image: string;
  datePublished: string;
  dateModified: string;
  section: string;
}): Metadata {
  const base = metadata(title, description, path, draft, image);
  const origin = publicOrigin();
  const publicSite = Boolean(origin) && process.env.VERCEL_ENV !== "preview";
  const articleUrl = publicSite ? new URL(path, origin).href : undefined;

  return {
    ...base,
    authors: [
      {
        name: "Themis Family Editorial Team",
        ...(publicSite
          ? { url: new URL("/insights/how-we-research", origin).href }
          : {}),
      },
    ],
    creator: "Themis Family Editorial Team",
    publisher: site.name,
    openGraph: {
      ...base.openGraph,
      type: "article",
      publishedTime: datePublished,
      modifiedTime: dateModified,
      section,
      authors: articleUrl
        ? [new URL("/insights/how-we-research", origin).href]
        : ["Themis Family Editorial Team"],
    },
  };
}
