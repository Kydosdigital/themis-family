import { promises as fs } from "node:fs";
import path from "node:path";
import { evaluate } from "@mdx-js/mdx";
import * as runtime from "react/jsx-runtime";

export const articles = [
  {
    slug: "child-bypassing-parental-controls",
    title: "Your child keeps bypassing parental controls. What now?",
    summary:
      "Fix the technical gap, but do not stop there. What the workaround can tell you about the rule, the reason and the next conversation.",
    category: "Digital boundaries",
    date: "2026-10-02",
    updated: "2026-10-02",
    minutes: 9,
    image:
      "https://images.pexels.com/photos/7114082/pexels-photo-7114082.jpeg?auto=compress&cs=tinysrgb&w=1600",
    imageAlt:
      "A father and teenage daughter talking together while looking at a smartphone.",
    imageCredit: "Monstera Production / Pexels",
    imageSource:
      "https://www.pexels.com/photo/black-father-talking-to-daughter-using-smartphone-7114082/",
    draft: false,
  },
  {
    slug: "is-chatgpt-for-homework-cheating",
    title: "Is using ChatGPT for homework cheating?",
    summary:
      "The useful question is not whether AI touched the homework. It is whether your child still did the thinking.",
    category: "AI & learning",
    date: "2026-10-02",
    updated: "2026-10-02",
    minutes: 10,
    image:
      "https://images.pexels.com/photos/6267061/pexels-photo-6267061.jpeg?auto=compress&cs=tinysrgb&w=1600",
    imageAlt:
      "A teenager studying at a desk with a laptop, notebook and books.",
    imageCredit: "Antoni Shkraba / Pexels",
    imageSource:
      "https://www.pexels.com/photo/teenager-studying-by-desk-with-laptop-6267061/",
    draft: false,
  },
  {
    slug: "found-porn-on-child-phone",
    title: "I found porn on my child's phone. What do I do?",
    summary:
      "Before the first confrontation, work out what you actually know, what you do not know yet, and how to keep the conversation open.",
    category: "Explicit content & safety",
    date: "2026-10-02",
    updated: "2026-10-02",
    minutes: 11,
    image:
      "https://images.pexels.com/photos/8550835/pexels-photo-8550835.jpeg?auto=compress&cs=tinysrgb&w=1600",
    imageAlt:
      "A mother talking with her teenage son while he holds a smartphone.",
    imageCredit: "Kindel Media / Pexels",
    imageSource:
      "https://www.pexels.com/photo/a-boy-looking-at-his-smartphone-while-his-mother-is-talking-8550835/",
    draft: false,
  },
] as const;

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
  "AI & learning",
  "Screen time & sleep",
  "Social media",
  "Gaming",
  "Explicit content & safety",
  "Online friendships",
  "Privacy & independence",
  "Scams & security",
  "Building with technology",
];
