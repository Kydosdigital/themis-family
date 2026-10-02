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
  {
    slug: "how-much-screen-time-is-too-much",
    title: "How much screen time is too much for my child?",
    summary:
      "There is no single number that works for every older child. A better screen-time decision starts with sleep, school, movement, relationships and what the screen is actually being used for.",
    category: "Screen time & sleep",
    date: "2026-10-02",
    updated: "2026-10-02",
    minutes: 11,
    image:
      "https://images.pexels.com/photos/9785012/pexels-photo-9785012.jpeg?auto=compress&cs=tinysrgb&w=1600",
    imageAlt:
      "Two children sitting back-to-back while using smartphones.",
    imageCredit: "Ron Lach / Pexels",
    imageSource:
      "https://www.pexels.com/photo/children-holding-their-smartphones-9785012/",
    tldr: [
      "For school-age children and teens, there is no evidence-based universal daily screen-time number that fits every child and every kind of use.",
      "Look first at what screen use is displacing: sleep, schoolwork, movement, meals, responsibilities, relationships and offline interests.",
      "Separate necessary and constructive use from entertainment rather than treating every minute on a screen as identical.",
      "A family limit should be clear enough to enforce, flexible enough to fit real life, and reviewed as the child grows.",
    ],
    faqs: [
      {
        question: "How many hours of screen time should a 12-year-old have?",
        answer:
          "There is no single research-backed number that is right for every 12-year-old. A useful plan protects sleep, school, movement, family time and other important activities, then sets entertainment limits around what remains.",
      },
      {
        question: "Does homework count as screen time?",
        answer:
          "It is still screen use, but it serves a different purpose from scrolling or gaming. For family rules, it is often more useful to separate school and creative use from recreational screen time while still protecting breaks, movement and sleep.",
      },
      {
        question: "How do I know if my child's screen time is too much?",
        answer:
          "Pay attention when screen use regularly pushes out sleep, schoolwork, exercise, relationships, meals, responsibilities or activities your child previously enjoyed, or when stopping becomes a frequent source of serious conflict.",
      },
      {
        question: "Should screen-time rules be the same every day?",
        answer:
          "Not necessarily. Weekdays, weekends, holidays and unusual events can reasonably look different. What matters is that the family understands the baseline, what can change, and what still needs protecting.",
      },
    ],
    draft: false,
  },
  {
    slug: "phone-in-bedroom-at-night",
    title: "Should my child's phone stay out of the bedroom at night?",
    summary:
      "For most families, keeping the phone outside the bedroom is one of the simplest ways to protect sleep without turning bedtime into a nightly argument.",
    category: "Screen time & sleep",
    date: "2026-10-02",
    updated: "2026-10-02",
    minutes: 10,
    image:
      "https://images.pexels.com/photos/10387709/pexels-photo-10387709.jpeg?auto=compress&cs=tinysrgb&w=1600",
    imageAlt:
      "A teenage boy lying in bed using a smartphone at night.",
    imageCredit: "Ron Lach / Pexels",
    imageSource:
      "https://www.pexels.com/photo/teenage-boy-laying-in-bed-using-smart-phone-10387709/",
    tldr: [
      "Late-night phone use is associated with later bedtimes, shorter sleep and poorer sleep quality, although the size of the effect varies between studies.",
      "Keeping devices outside the bedroom removes temptation, notifications and the need to negotiate every individual app at bedtime.",
      "If the phone is used as an alarm clock, replace that function rather than making the whole phone necessary overnight.",
      "Older teens can earn more autonomy, but sleep should remain a protected family priority.",
    ],
    faqs: [
      {
        question: "Should teenagers be allowed to sleep with their phones in their room?",
        answer:
          "For many families, keeping phones outside the bedroom is the simpler sleep-protective default. Older teens may eventually manage more independence, but the decision should be based on whether overnight access is affecting sleep or leading to repeated rule-breaking.",
      },
      {
        question: "How long before bed should children stop using screens?",
        answer:
          "AAP guidance commonly recommends putting screens away about an hour before bedtime. A shorter wind-down may still be better than none, but the aim is to make sleep easier rather than chase a perfect number.",
      },
      {
        question: "What if my child uses their phone as an alarm?",
        answer:
          "A basic alarm clock can remove that reason for keeping the entire internet beside the bed. If the phone must stay in the room, use scheduled downtime, do-not-disturb settings and a charging spot away from the bed.",
      },
      {
        question: "Does night mode make a phone safe to use before sleep?",
        answer:
          "Reducing bright or blue-toned light may help with one part of the problem, but content, notifications, emotional stimulation and simply staying awake to keep using the device can still delay sleep.",
      },
    ],
    draft: false,
  },
  {
    slug: "what-age-first-phone",
    title: "What age should a child get their first phone?",
    summary:
      "There is no perfect birthday for a first phone. Readiness depends on why the child needs one, how they handle responsibility and how much of the internet you are actually handing over.",
    category: "Digital boundaries",
    date: "2026-10-02",
    updated: "2026-10-02",
    minutes: 12,
    image:
      "https://images.pexels.com/photos/7984364/pexels-photo-7984364.jpeg?auto=compress&cs=tinysrgb&w=1600",
    imageAlt:
      "A father and child looking at a smartphone together.",
    imageCredit: "George Pak / Pexels",
    imageSource:
      "https://www.pexels.com/photo/a-child-using-a-smartphone-next-to-his-father-7984364/",
    tldr: [
      "Research does not identify one perfect age for a first smartphone, and major paediatric guidance now focuses on readiness and family need.",
      "A child may need communication before they are ready for unrestricted apps, browsers, social media or purchases.",
      "Consider responsibility, honesty, handling of conflict, existing tech rules and whether the parent is ready to support the transition.",
      "A first device can start small: calls and texts first, selected apps later, and more freedom as judgement develops.",
    ],
    faqs: [
      {
        question: "What is the best age for a child to get a phone?",
        answer:
          "There is no single best age supported by research. The American Academy of Pediatrics recommends looking at the child's maturity, digital literacy, truthfulness, ability to navigate conflict and the practical reason they need a device.",
      },
      {
        question: "Is 11 too young for a smartphone?",
        answer:
          "Age alone cannot answer that. An 11-year-old may need a way to contact family without being ready for unrestricted internet access or social media. A simpler phone, watch or tightly configured smartphone can meet the communication need first.",
      },
      {
        question: "Does getting a phone mean my child should get social media too?",
        answer:
          "No. Calling, texting, maps, camera access and family communication can be introduced separately from social media. Treating each capability as its own decision makes the transition easier to manage.",
      },
      {
        question: "What rules should we agree before the first phone?",
        answer:
          "Cover downloads, purchases, privacy, contacts, bedtime, school use, inappropriate content, what happens when something feels unsafe, and how the child can ask for more freedom later.",
      },
    ],
    draft: false,
  },
  {
    slug: "is-my-child-ready-for-social-media",
    title: "Is my child ready for social media?",
    summary:
      "The platform age limit is not the same thing as developmental readiness. Look at self-control, privacy, peer pressure, conflict and whether your child can ask for help when something goes wrong.",
    category: "Social media",
    date: "2026-10-02",
    updated: "2026-10-02",
    minutes: 12,
    image:
      "https://images.pexels.com/photos/7869451/pexels-photo-7869451.jpeg?auto=compress&cs=tinysrgb&w=1600",
    imageAlt:
      "A group of teenagers sitting together and sharing a smartphone.",
    imageCredit: "Vanessa Loring / Pexels",
    imageSource:
      "https://www.pexels.com/photo/group-of-diverse-friends-using-smartphone-7869451/",
    tldr: [
      "There is no research-backed age at which every child suddenly becomes ready for social media.",
      "Readiness includes self-regulation, understanding privacy and permanence, handling peer conflict and knowing when to ask an adult for help.",
      "Early adolescents generally need more active adult coaching and review, with privacy and autonomy increasing as judgement improves.",
      "A child can be ready for a phone before they are ready for a public social-media account.",
    ],
    faqs: [
      {
        question: "What age should a child be allowed on social media?",
        answer:
          "Platform minimum ages matter, but they do not establish developmental readiness. Research guidance recommends considering maturity, self-regulation, risk understanding, privacy skills and the child's wider social context rather than relying on a single birthday.",
      },
      {
        question: "How can I tell if my child is ready for social media?",
        answer:
          "Look for whether they can follow existing rules, handle friendship conflict, protect private information, ignore or report unwanted contact, stop when they need to, and tell you when something online becomes uncomfortable.",
      },
      {
        question: "Should I monitor my young teenager's social media?",
        answer:
          "APA guidance advises ongoing adult review, discussion and coaching for most early adolescents, roughly ages 10 to 14, while balancing this with appropriate privacy. Monitoring should become less intrusive as skills and trust grow.",
      },
      {
        question: "Can social media be good for teenagers?",
        answer:
          "Yes. Social media can support friendship, community, identity exploration, learning and access to support. The effects depend on the child, the content, the platform features and the way it is used, which is why the goal is not simply maximum restriction.",
      },
    ],
    draft: false,
  },
  {
    slug: "child-angry-when-video-games-stop",
    title: "Why does my child get angry when I turn off video games?",
    summary:
      "A difficult transition away from a game does not automatically mean addiction. Start by understanding the moment, the game and what stopping is interrupting.",
    category: "Gaming",
    date: "2026-10-02",
    updated: "2026-10-02",
    minutes: 11,
    image:
      "https://images.pexels.com/photos/34625043/pexels-photo-34625043.jpeg?auto=compress&cs=tinysrgb&w=1600",
    imageAlt:
      "Two teenagers playing video games with controllers.",
    imageCredit: "Matheus Bertelli / Pexels",
    imageSource:
      "https://www.pexels.com/photo/teens-engaged-in-intense-gaming-session-34625043/",
    tldr: [
      "Anger when gaming stops can reflect an abrupt transition, frustration, social pressure inside the game or ordinary disappointment. It does not automatically mean gaming disorder.",
      "Agree the stopping point before play starts and, where possible, avoid ending in the middle of a match or team commitment.",
      "Look beyond the argument at whether gaming is regularly replacing sleep, school, movement, relationships or other interests.",
      "Seek professional help when loss of control and significant impairment persist, rather than diagnosing a child from one difficult shutdown.",
    ],
    faqs: [
      {
        question: "Why does my child rage when video games are turned off?",
        answer:
          "Games can be highly absorbing, rewarding and social, so stopping can feel abrupt, especially if a child is tired, stressed or in the middle of something with other players. Difficulty switching activities is not, by itself, proof of addiction.",
      },
      {
        question: "Should I turn the console off when my child refuses to stop?",
        answer:
          "A parent may need to enforce an agreed limit, but sudden shutdowns can intensify conflict. It is usually better to agree the stopping rule beforehand, use warnings or device timers, and distinguish deliberate refusal from being trapped in an unfinished match.",
      },
      {
        question: "How do I know if gaming has become a real problem?",
        answer:
          "Look for persistent loss of control and gaming taking priority despite significant harm to sleep, school, relationships, health or everyday responsibilities. The World Health Organization's gaming-disorder definition requires significant impairment, not simply enthusiasm for games.",
      },
      {
        question: "Do strict gaming limits prevent gaming addiction?",
        answer:
          "The evidence is not that simple. A 2025 systematic review found parental knowledge and positive parenting to be protective, while findings for restrictive mediation were inconclusive. Clear limits still matter, but family connection and understanding the child's gaming are important too.",
      },
    ],
    draft: false,
  },
  {
    slug: "should-i-read-my-childs-text-messages",
    title: "Should I read my child's text messages?",
    summary:
      "Sometimes safety justifies closer supervision. But routine secret checking can damage the very disclosure parents rely on to know when something is wrong.",
    category: "Privacy & independence",
    date: "2026-10-02",
    updated: "2026-10-02",
    minutes: 11,
    image:
      "https://images.pexels.com/photos/6957239/pexels-photo-6957239.jpeg?auto=compress&cs=tinysrgb&w=1600",
    imageAlt:
      "A mother and teenage daughter having a serious conversation at home.",
    imageCredit: "Kaboompics.com / Pexels",
    imageSource:
      "https://www.pexels.com/photo/mother-throws-daughter-s-phone-6957239/",
    tldr: [
      "There is a meaningful difference between transparent supervision and secretly searching a child's private conversations.",
      "Research suggests child disclosure and parental warmth are major sources of what parents know, while covert monitoring can be associated with privacy invasion and more secrecy.",
      "The younger the child or the greater the safety concern, the stronger the case for direct supervision.",
      "If you need to inspect messages because of a specific risk, explain why, limit the scope and define how privacy can be restored.",
    ],
    faqs: [
      {
        question: "Is it okay to read my child's text messages?",
        answer:
          "Sometimes, especially with younger children or a specific safety concern. But routine secret checking can undermine trust and disclosure. A better default is transparent supervision with clear reasons, boundaries and a plan for increasing privacy as the child becomes more capable.",
      },
      {
        question: "At what age should a child have privacy on their phone?",
        answer:
          "There is no single age. Privacy should grow with maturity, risk awareness, honesty and the child's ability to manage problems. A young child may need hands-on oversight, while a responsible older teenager should usually have substantially more private space.",
      },
      {
        question: "What if I think my child is hiding something dangerous?",
        answer:
          "Safety can justify more direct checking when there are concrete concerns such as grooming, threats, self-harm, coercion or exploitation. Tell your child what you are worried about where doing so is safe, focus the search on the risk, and seek appropriate professional or safeguarding help when necessary.",
      },
      {
        question: "Can checking my child's phone make them more secretive?",
        answer:
          "Some studies have found covert monitoring and perceived privacy invasion are associated with lower disclosure or greater secrecy. This does not mean parents should never supervise; it means the method and the relationship around supervision matter.",
      },
    ],
    draft: false,
  },
  {
    slug: "child-talking-to-strangers-online",
    title: "My child is talking to strangers online. What should I do?",
    summary:
      "Not every unknown player or follower is dangerous. The job is to work out who the person is, what the relationship has become and whether secrecy, pressure or sexualisation is entering the conversation.",
    category: "Online friendships",
    date: "2026-10-02",
    updated: "2026-10-02",
    minutes: 13,
    image:
      "https://images.pexels.com/photos/36039252/pexels-photo-36039252.jpeg?auto=compress&cs=tinysrgb&w=1600",
    imageAlt:
      "A teenage boy using a smartphone alone indoors.",
    imageCredit: "Hashtag Melvin / Pexels",
    imageSource:
      "https://www.pexels.com/photo/teenager-using-smartphone-indoors-in-cozy-room-36039252/",
    tldr: [
      "An online contact being unknown to you is a reason to ask questions, not automatic proof that grooming is happening.",
      "Risk rises when the person pushes secrecy, moves conversations into private channels, gives gifts, lies about identity, sexualises the relationship, pressures for images or asks to meet.",
      "Stay calm enough for your child to tell you what has happened. A child who fears losing every device may hide the next contact.",
      "If there is sexual coercion, blackmail, an adult targeting a child or plans for an unsafe meeting, treat it as a safeguarding issue and use the reporting route for your country.",
    ],
    faqs: [
      {
        question: "Is it dangerous for children to talk to strangers online?",
        answer:
          "Unknown contacts create additional risk because identity and intentions can be difficult to verify, but not every interaction is harmful. Focus on the behaviour of the contact, the child's age, what information is being shared and whether secrecy, pressure or sexual content is involved.",
      },
      {
        question: "What are warning signs of online grooming?",
        answer:
          "Warning signs can include pretending to be younger, intense attention, gifts, requests for secrecy, attempts to isolate the child, moving to private or encrypted messaging, sexualising conversation, requesting images, blackmail or pushing for an in-person meeting.",
      },
      {
        question: "Should I take my child's phone away if they talked to a stranger?",
        answer:
          "Immediate safety may require restricting contact, but removing every device as punishment can make a child less willing to disclose future problems. First establish who the person is, block or report where needed, preserve relevant evidence and make a proportionate safety plan.",
      },
      {
        question: "What should I do if an adult has been messaging my child sexually?",
        answer:
          "Stop the unsafe contact, preserve relevant evidence without asking your child to continue engaging, and report the situation through the appropriate child-protection or law-enforcement route in your country. If the child is in immediate danger, contact emergency services.",
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
