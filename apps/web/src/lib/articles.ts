import { promises as fs } from "node:fs";
import path from "node:path";
import { evaluate } from "@mdx-js/mdx";
import * as runtime from "react/jsx-runtime";
export const articles = [
  {
    slug: "a-clearer-homework-agreement",
    title: "Start with a clearer homework agreement.",
    summary:
      "A practical way to turn “do your homework” into something everyone understands.",
    category: "Homework",
    date: "2026-09-29",
    updated: "2026-09-29",
    minutes: 3,
    art: "6:00 PM",
    draft: true,
  },
  {
    slug: "room-for-an-exception",
    title: "Make room for an exception.",
    summary:
      "Why a request can be part of the agreement, rather than the beginning of another argument.",
    category: "Digital boundaries",
    date: "2026-09-29",
    updated: "2026-09-29",
    minutes: 3,
    art: "+15 min",
    draft: true,
  },
  {
    slug: "privacy-is-part-of-the-conversation",
    title: "Privacy is part of the conversation.",
    summary:
      "A few useful questions to ask before introducing digital boundaries with a teen.",
    category: "Teen independence",
    date: "2026-09-29",
    updated: "2026-09-29",
    minutes: 3,
    art: "Your space.",
    draft: true,
  },
];
export async function articleContent(slug: string) {
  if (!articles.some((a) => a.slug === slug))
    throw new Error("Unknown article");
  const source = await fs.readFile(
    path.join(process.cwd(), "src/content", slug + ".mdx"),
    "utf8",
  );
  return evaluate(source, { ...runtime, baseUrl: import.meta.url });
}
export const categories = [
  "Digital boundaries",
  "Homework",
  "Gaming",
  "Social media",
  "Family technology",
  "Teen independence",
  "Privacy",
];
