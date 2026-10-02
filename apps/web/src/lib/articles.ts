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
    minutes: 11,
    image:
      "https://images.pexels.com/photos/7114082/pexels-photo-7114082.jpeg?auto=compress&cs=tinysrgb&w=1600",
    imageAlt:
      "A father and teenage daughter talking together while looking at a smartphone.",
    imageCredit: "Monstera Production / Pexels",
    imageSource:
      "https://www.pexels.com/photo/black-father-talking-to-daughter-using-smartphone-7114082/",
    tldr: [
      "Fix the technical loophole, but do not assume the workaround tells you why your child broke the rule.",
      "Ask what they were trying to do and what feels wrong about the current boundary before deciding what needs to change.",
      "Keep consequences connected to trust and access, rather than reaching for an unrelated or indefinite punishment.",
      "The long-term goal is not a perfect lock. It is a child who can eventually manage technology without one.",
    ],
    faqs: [
      {
        question: "Why does my child keep bypassing parental controls?",
        answer:
          "There is no single reason. A child may be testing a boundary, trying to avoid missing out, responding to a rule they think no longer fits, or simply noticing a technical loophole. The workaround tells you the rule was bypassed, not why.",
      },
      {
        question: "Should I punish my child for bypassing screen-time rules?",
        answer:
          "A consequence can be appropriate, especially when a clear agreement was deliberately broken. Keep it proportionate and connected to trust or device access, then use the conversation to understand what drove the workaround.",
      },
      {
        question: "Do parental controls actually work?",
        answer:
          "They can reduce access and make family boundaries more consistent, but they cannot teach judgement on their own. Research on parental monitoring and restrictive mediation is mixed, so controls work best as one part of a wider approach that includes communication and gradually increasing responsibility.",
      },
      {
        question: "When should bypassing parental controls worry me?",
        answer:
          "Pay closer attention when it is connected with unknown contacts, sexual content or requests for images, coercion, blackmail, unsafe spending, serious bullying, repeated overnight use, or significant distress or impairment.",
      },
    ],
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
    minutes: 12,
    image:
      "https://images.pexels.com/photos/6267061/pexels-photo-6267061.jpeg?auto=compress&cs=tinysrgb&w=1600",
    imageAlt:
      "A teenager studying at a desk with a laptop, notebook and books.",
    imageCredit: "Antoni Shkraba / Pexels",
    imageSource:
      "https://www.pexels.com/photo/teenager-studying-by-desk-with-laptop-6267061/",
    tldr: [
      "Using AI is not automatically cheating. What matters is what the tool did, what the child did, and what the school allows.",
      "AI can explain, quiz, brainstorm or critique without necessarily replacing the student's thinking.",
      "A useful check is whether the child can explain the work, show how they used AI and verify important claims independently.",
      "Teach AI judgement and privacy, not just prompting. Children need to know when a confident answer may still be wrong.",
    ],
    faqs: [
      {
        question: "Is using ChatGPT for homework cheating?",
        answer:
          "It depends on the assignment, the school's rules and how the tool was used. Asking AI to explain a concept or quiz you is different from generating an answer and submitting it as your own. School or assessment rules should always come first.",
      },
      {
        question: "What are acceptable ways for a child to use AI for homework?",
        answer:
          "Where the school permits it, useful examples include asking for an explanation, generating practice questions, brainstorming ideas, testing understanding, or getting feedback on a draft. The student should still be able to explain and defend the final work.",
      },
      {
        question: "How can I tell whether AI did too much of the homework?",
        answer:
          "Ask your child to explain the task, show the prompts they used, identify what they changed, name the sources they checked and talk through the final answer without reopening the chatbot. If they cannot explain the work, too much thinking may have been outsourced.",
      },
      {
        question: "Should parents ban ChatGPT and other AI tools?",
        answer:
          "A blanket ban can remove useful learning opportunities and may be difficult to sustain. A clearer approach is to set rules about permitted uses, school requirements, verification, privacy and when a child needs to complete work independently.",
      },
    ],
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
    minutes: 13,
    image:
      "https://images.pexels.com/photos/8550835/pexels-photo-8550835.jpeg?auto=compress&cs=tinysrgb&w=1600",
    imageAlt:
      "A mother talking with her teenage son while he holds a smartphone.",
    imageCredit: "Kindel Media / Pexels",
    imageSource:
      "https://www.pexels.com/photo/a-boy-looking-at-his-smartphone-while-his-mother-is-talking-8550835/",
    tldr: [
      "Do not decide what the discovery means before you know whether the content was searched for, sent by someone else or encountered accidentally.",
      "Check for immediate safeguarding concerns first, including coercion, blackmail, unknown adults or requests for sexual images.",
      "You can strengthen device controls without making shame the teaching method. Keeping communication open matters if a more serious problem appears later.",
      "One discovery is not enough to diagnose addiction. Look at distress, loss of control and whether the behaviour is affecting everyday life.",
    ],
    faqs: [
      {
        question: "What should I do first if I find porn on my child's phone?",
        answer:
          "Work out what you actually found and check for immediate safety concerns before confronting your child. Then have a calm conversation to understand whether the content was searched for, sent by someone else or encountered accidentally.",
      },
      {
        question: "Should I take my child's phone away if I find pornography?",
        answer:
          "That depends on the child's age, the circumstances and the level of risk. Temporary restrictions or stronger controls may be appropriate, but an immediate punishment should not make it harder for your child to tell you if coercion, pressure or unsafe contact is involved.",
      },
      {
        question: "Does viewing pornography mean my child is addicted?",
        answer:
          "No. A single discovery, or even repeated viewing, is not enough to diagnose a compulsive problem. Look at whether your child feels unable to stop, is distressed by the behaviour, or is experiencing significant effects on sleep, school, relationships or daily responsibilities.",
      },
      {
        question: "What if someone sent sexual content to my child?",
        answer:
          "Ask who sent it and whether there have been requests, threats, secrecy or pressure. If an adult is sexualising contact with a child, someone is blackmailing them, or intimate images of a minor are being distributed, treat it as a safeguarding issue and seek appropriate local help.",
      },
    ],
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
