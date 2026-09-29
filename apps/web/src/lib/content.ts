export type ContentSection = {
  title: string;
  body?: string;
  items?: { title: string; body: string }[];
  note?: string;
};
export type ContentPage = {
  label: string;
  title: string;
  intro: string;
  visual?: "family" | "teen" | "child" | "privacy" | "status";
  sections: ContentSection[];
};
export const pages: Record<string, ContentPage> = {
  "for-parents": {
    label: "For parents & carers",
    title: "Be their parent. Not the phone police.",
    intro:
      "You’ve already had the conversation. Themis is designed to help the agreement hold — without you having to repeat it every evening.",
    visual: "family",
    sections: [
      {
        title: "A clear plan beats another negotiation.",
        body: "Homework, games, bedtime. Agree what happens and when, then give everyone the same picture of the day.",
        items: [
          {
            title: "Agree it together",
            body: "Make expectations visible before a deadline arrives. Your child can see the rule, the time and the consequence.",
          },
          {
            title: "Keep the routine consistent",
            body: "Scheduled rules and homework deadlines are designed to apply the agreement you chose.",
          },
          {
            title: "Stay flexible",
            body: "Approve a request, offer part of the time asked for, or give a time-limited Free Pass.",
          },
        ],
      },
      {
        title: "You make the decisions. They know where they stand.",
        body: "A child can say they’ve finished and ask for approval. You can approve, ask for one clarification, or explain what still needs doing. Themis does not decide whether real-world homework is good enough.",
      },
      {
        title: "One family. Different needs.",
        items: [
          {
            title: "More than one child",
            body: "Set agreements for each child’s routine and experience. Subscription limits will be confirmed before launch.",
          },
          {
            title: "Another trusted adult",
            body: "Guardian access lets an invited parent or carer help manage ordinary family decisions.",
          },
          {
            title: "Useful summaries",
            body: "See agreement outcomes, tasks, requests and supported session records. These are not a diary of private conversations.",
          },
        ],
      },
      {
        title: "Know when something needs you.",
        body: "Protection status distinguishes a confirmed state from a pending sync or offline device. Approval and application on a child’s device are separate steps; remote changes are not guaranteed to happen instantly.",
        note: "School and essential access can remain available. Themis is designed around visible agreements, not message reading or covert surveillance.",
      },
    ],
  },
  "for-children": {
    label: "For children",
    title: "Know the plan. Have your say.",
    intro:
      "With Themis, you can see what you’ve agreed, what happens next and how to ask for help. No guessing why a game is paused.",
    visual: "child",
    sections: [
      {
        title: "Here’s the agreement.",
        items: [
          {
            title: "What do I need to do?",
            body: "Your task tells you what’s expected. For example: finish your homework and ask your parent or carer to check it.",
          },
          {
            title: "When is it due?",
            body: "You can see the time before it arrives. Homework by 6 PM means you know what to plan for.",
          },
          {
            title: "What happens next?",
            body: "If your work hasn’t been approved by the deadline, the selected games pause. You can see why.",
          },
        ],
      },
      {
        title: "Finished? Say so.",
        body: "Tap “I’ve finished” to ask your parent or carer to check. Saying you’ve finished isn’t the same as approval. Your screen explains whether you’re waiting for a decision or for your device to update.",
      },
      {
        title: "Need a little longer?",
        body: "You can ask for more time or explain why you need an app. Your parent or carer might say yes, offer a different amount of time, ask a question or say no. If nobody replies, the request does not automatically give you more time.",
      },
      {
        title: "Some things can still work.",
        body: "Your family can keep school apps and important access available. If an app you need is paused, you can ask for temporary access.",
      },
      {
        title: "It’s your phone. You should know what’s visible.",
        body: "Themis shows that controls are active. You can see what information your parent can see: agreements, tasks, requests and supported session outcomes. Themis isn’t designed to show them your private messages, conversations or a full browsing diary.",
      },
    ],
  },
  "for-teens": {
    label: "For teens",
    title: "Boundaries shouldn’t mean being watched all day.",
    intro:
      "You deserve to know what’s agreed, why something is paused and what information is visible. Themis starts with that.",
    visual: "teen",
    sections: [
      {
        title: "An agreement you can actually see.",
        items: [
          {
            title: "No secret rules",
            body: "The schedule, deadline and selected restrictions are visible. You can plan around the same information your parent or carer has.",
          },
          {
            title: "Room to explain",
            body: "Ask for more time, request access for something specific, or explain an exception. Your request has a clear outcome.",
          },
          {
            title: "A mature experience",
            body: "Clear language, straightforward controls and useful explanations. No childish reward charts or guilt-driven prompts.",
          },
        ],
      },
      {
        title: "Private conversations stay private.",
        body: "Themis is not designed to provide message contents, private conversations, a full browsing or search-history diary, continuous location tracking or a minute-by-minute surveillance feed.",
      },
      {
        title: "What your parent can see.",
        body: "Family agreements, task and request outcomes, temporary access and supported session records help your family understand the plan. That is different from seeing everything you do on your phone.",
        note: "Themis shows when its controls are active and explains the kinds of information available to parents. Apple-controlled information is described separately.",
      },
      {
        title: "An exception isn’t an argument.",
        body: "Need YouTube for a teacher’s video? Ask for temporary access and explain why. A parent can grant a specific amount of time. The app does not distinguish an educational video from other content inside YouTube.",
      },
    ],
  },
  "school-access": {
    label: "School & essential access",
    title: "School still works. Even when games can wait.",
    intro:
      "Digital boundaries should leave room for the things that matter. Choose school and essential access alongside your family’s entertainment rules.",
    sections: [
      {
        title: "Keep the important things available.",
        items: [
          {
            title: "Always Allowed",
            body: "Apps and sites your family marks Always Allowed are excluded from ordinary restrictions. Review this list together during setup.",
          },
          {
            title: "Your school’s tools",
            body: "Choose the apps and sites your child actually uses. School access is a family-configured list, not a promise to support every school platform by name.",
          },
          {
            title: "Essential communication",
            body: "Phone, Messages and Maps are recommended as Always Allowed where technically supported. Specific Apple system-app behaviour is still being verified.",
          },
        ],
        note: "Themis never deliberately prevents emergency calling or OS-level emergency functionality.",
      },
      {
        title: "“But my teacher set a YouTube video.”",
        items: [
          {
            title: "01 · Ask",
            body: "YouTube is paused during study time. Your child requests temporary access and explains the schoolwork.",
          },
          {
            title: "02 · Approve",
            body: "A parent grants 20 minutes of access to YouTube. Approval still needs to reach and apply on the child’s device.",
          },
          {
            title: "03 · Return to the plan",
            body: "Temporary access is designed to expire automatically so the underlying agreement resumes.",
          },
        ],
        note: "Themis cannot tell educational content from entertainment within the same app or website. Temporary access applies to the selected app/site.",
      },
      {
        title: "Set it up for their own device.",
        body: "The initial product assumes each child has their own supported device signed into their own Child Apple Account. Shared iPads do not provide separate, reliably attributed rules for different siblings. Check the school list and test protection during setup.",
      },
    ],
  },
  privacy: {
    label: "Privacy",
    title: "Know what Themis can see. And what it can’t.",
    intro:
      "A family agreement needs trust. Themis is designed to make its controls and reporting visible, with only the information needed to support the agreed routine.",
    visual: "privacy",
    sections: [
      {
        title: "What parents can see.",
        items: [
          {
            title: "The family’s agreements",
            body: "Rules, schedules, task status, approval decisions and temporary access.",
          },
          {
            title: "Requests and outcomes",
            body: "A child’s request, any bounded clarification, the decision and supported session outcomes.",
          },
          {
            title: "Protection health",
            body: "Device authorisation and sync status help parents understand whether protection needs attention.",
          },
        ],
      },
      {
        title: "What Themis does not provide.",
        body: "Message contents. Private conversation contents. A full browsing or search-history feed. Continuous location tracking. A minute-by-minute surveillance feed. Themis does not offer a covert mode.",
      },
      {
        title: "What remains on the device or with Apple.",
        body: "Apple controls permission and selection mechanisms for app restrictions. Themis uses privacy-preserving selections rather than turning them into a server-side list of browsing activity. Any Apple-controlled usage reporting needs separate capability verification before being presented as available.",
      },
      {
        title: "Children deserve an explanation, too.",
        body: "A child or teen should be able to understand that controls are active, what is controlled, why something is paused and what information parents can see. That information belongs in their experience, not just this page.",
      },
      {
        title: "Collect less. Explain more.",
        items: [
          {
            title: "Data minimisation",
            body: "The product requirements limit collection to information needed for family administration and supported features. The waitlist asks for a parent’s contact details, not a child’s date of birth.",
          },
          {
            title: "No ad profiling",
            body: "Themis’s product policy prohibits using children’s behaviour for advertising profiles or selling personal data.",
          },
          {
            title: "UK-first privacy review",
            body: "Legal review, a Data Protection Impact Assessment and clear information about each processing purpose are required before launch. We do not claim those reviews are already complete.",
          },
        ],
        note: "This page explains the product direction. It is not a replacement for the formal Privacy Policy, which remains a draft for legal review.",
      },
    ],
  },
  safety: {
    label: "Safety & trust",
    title: "Trust starts with an honest picture.",
    intro:
      "A reassuring colour isn’t enough. Families need to know when protection is confirmed, when a change is still travelling and when something needs attention.",
    visual: "status",
    sections: [
      {
        title: "An agreement should never hide important access.",
        body: "Themis never deliberately interferes with emergency calling or OS-level emergency functionality. School access and recommended Always Allowed apps are considered during setup, not after a restriction surprises someone.",
      },
      {
        title: "The right people. The right role.",
        items: [
          {
            title: "Secure device pairing",
            body: "Pairing is designed to bind a managed device to one household, with scoped and revocable access. Re-pairing requires the authorised process.",
          },
          {
            title: "Owner and Guardian",
            body: "A household Owner administers the family. Invited Guardians can help with ordinary rules, approvals and requests.",
          },
          {
            title: "Visible to the child",
            body: "Children and teens can see that Themis is active, what the agreement means and how to request an exception.",
          },
        ],
      },
      {
        title: "Approved is not the same as applied.",
        body: "An adult’s decision and its application on the child’s device are separate states. Connectivity, device status and Apple-controlled behaviour can affect when a change takes effect. Themis must not display stale information as Protected.",
      },
      {
        title: "Support can diagnose Themis. It cannot parent a child.",
        body: "Support may help with setup, account recovery and technical problems. It cannot approve tasks, grant Free Passes, change ordinary family rules or impersonate a parent.",
        note: "Safeguarding concerns require a separate process. The operational safeguarding service and contact details must be approved before launch; this preview is not a monitored emergency service.",
      },
    ],
  },
  features: {
    label: "Features",
    title: "A family agreement. With the details thought through.",
    intro:
      "From homework deadlines to one-off exceptions, Themis is designed for the parts of family life that don’t fit a simple on/off switch.",
    sections: [
      {
        title: "Rules for real routines.",
        items: [
          {
            title: "Homework Deadline",
            body: "Set a due time and choose what pauses if a task has not been approved.",
          },
          {
            title: "Bedtime schedules",
            body: "Agree when selected apps pause and when they become available again.",
          },
          {
            title: "Gaming & social apps",
            body: "Choose the targets and times that fit your family’s routine.",
          },
        ],
      },
      {
        title: "Room for a conversation.",
        items: [
          {
            title: "Parent Approval",
            body: "An adult checks real-world completion; Themis does not judge the homework.",
          },
          {
            title: "Requests & partial approvals",
            body: "A child asks for extra time or temporary access. A parent can approve a different duration.",
          },
          {
            title: "Clarification & Free Pass",
            body: "One clarification prompt and reply keeps the request focused. A Free Pass has an explicit scope and expiry.",
          },
        ],
      },
      {
        title: "Time with a purpose.",
        items: [
          {
            title: "Focus Sessions",
            body: "Plan time away from configured distractions. Completion relates to the supported session, not proof of external work.",
          },
          {
            title: "Active Engagement Sessions",
            body: "Supported in-app engagement sessions can provide their own completion evidence.",
          },
          {
            title: "Earn First",
            body: "Link access to an approved task or genuinely verifiable supported activity.",
          },
        ],
      },
      {
        title: "Important access, kept in view.",
        items: [
          {
            title: "Always Allowed & School Access",
            body: "Keep configured school tools available and request time-limited educational access when needed.",
          },
          {
            title: "Protection Status",
            body: "Understand the difference between Protected, Sync Pending, Device Offline, Needs Attention and Protection Unavailable.",
          },
          {
            title: "Activity summaries",
            body: "Review agreement and request outcomes without a surveillance feed.",
          },
        ],
      },
      {
        title: "Built around the whole family.",
        items: [
          {
            title: "Child experience",
            body: "Simpler language, larger controls and a clear explanation of what happens next.",
          },
          {
            title: "Teen experience",
            body: "A mature interface with visible agreements, requests and privacy information.",
          },
          {
            title: "Guardian access",
            body: "Let another invited parent or carer help manage the family.",
          },
        ],
        note: "Offline-aware enforcement is part of the approved architecture. Apple enforcement and real-device behaviour remain under verification; these are pre-launch product previews.",
      },
    ],
  },
  about: {
    label: "About Themis Family",
    title: "More family. Less friction.",
    intro:
      "The phone is part of everyday life. It’s a classroom, a playground and a place to talk to friends. Setting boundaries shouldn’t mean treating all of that as the enemy.",
    visual: "family",
    sections: [
      {
        title: "The agreement should do more of the work.",
        body: "Themis starts with a familiar moment: the rule has been agreed, but the same conversation happens again tonight. We’re building a way to make that agreement visible and consistent, with room for requests and exceptions.",
      },
      {
        title: "Clear does not have to mean harsh.",
        items: [
          {
            title: "Dignity",
            body: "Children and teens should know what is happening and why. An unexplained lock is not an explanation.",
          },
          {
            title: "Digital independence",
            body: "Visible plans help young people understand their responsibilities and ask for what they need.",
          },
          {
            title: "Relationships first",
            body: "Technology should support family decisions. It should not replace listening, judgement or a conversation.",
          },
        ],
      },
      {
        title: "Thoughtful technology has limits.",
        body: "We’d rather explain a limitation than offer false reassurance. Themis is not a surveillance product, a substitute for parenting or a guarantee of a conflict-free home. It is a tool being built around clearer family agreements.",
      },
    ],
  },
  press: {
    label: "Press & media",
    title: "Themis Family, at a glance.",
    intro:
      "A UK-first family technology product built around visible digital agreements, respectful child and teen experiences, and privacy.",
    sections: [
      {
        title: "Product summary",
        body: "Themis Family is an iPhone/iPad-first product in development. Families agree boundaries around homework, bedtime, gaming and social apps. Themis is designed to apply those agreements consistently, with requests, parent approvals and school/essential access.",
      },
      {
        title: "The line we build around.",
        body: "“The family agrees the boundary. The phone applies it consistently.”",
      },
      {
        title: "Media resources",
        items: [
          {
            title: "Brand assets",
            body: "The current wordmark is temporary. Approved logo files and a brand kit will be added after final brand approval.",
          },
          {
            title: "Screenshots",
            body: "The website shows labelled interface concepts. Approved app screenshots will be made available closer to launch.",
          },
          {
            title: "Media contact",
            body: "A dedicated media contact will be published here when confirmed. There is no active press inbox listed yet.",
          },
        ],
        note: "No launch date, pricing, founder biography or press coverage has been announced on this website.",
      },
    ],
  },
};
export const faqGroups = [
  {
    title: "Getting started",
    items: [
      [
        "Who is Themis for?",
        "Parents and carers exploring clear digital agreements with children roughly 8–12 and teens roughly 13–15. The initial product is for iPhone and iPad.",
      ],
      [
        "Can I download it now?",
        "Themis is in development. Join the waitlist when live sign-ups open to hear about availability. No launch date has been announced.",
      ],
    ],
  },
  {
    title: "Rules",
    items: [
      [
        "Does Themis know if homework is finished?",
        "No. A parent or carer approves real-world homework and chores. Automatic verification applies only to supported in-app sessions Themis can genuinely verify.",
      ],
      [
        "What’s the difference between a schedule and a deadline?",
        "A schedule pauses selected apps during an agreed window. A Deadline Lock pauses selected apps if the linked task has not been approved by its due time.",
      ],
    ],
  },
  {
    title: "Children & teens",
    items: [
      [
        "What’s different about the Teen experience?",
        "The Teen experience uses more mature language and presentation, while keeping agreements, requests and privacy information visible.",
      ],
      [
        "Can a child see what parents can see?",
        "Yes, the planned experience explains what reporting is visible to parents and shows that Themis controls are active.",
      ],
    ],
  },
  {
    title: "School access",
    items: [
      [
        "Can school apps stay available?",
        "Families can configure Always Allowed school apps and sites. Temporary educational access can be requested for an app that is otherwise paused.",
      ],
      [
        "Can Themis recognise educational YouTube videos?",
        "No. Themis does not distinguish educational content from entertainment inside the same app. A temporary grant applies to the selected app or site.",
      ],
    ],
  },
  {
    title: "Privacy",
    items: [
      [
        "Does Themis read my child’s messages?",
        "Themis is not designed to read or provide private message or conversation contents.",
      ],
      [
        "Does Themis track my child’s location?",
        "Continuous location tracking is not part of Themis’s product offering. Nor is a full browsing diary or minute-by-minute surveillance feed.",
      ],
    ],
  },
  {
    title: "Devices",
    items: [
      [
        "Does Themis still work if the internet goes down?",
        "The approved architecture is designed to continue an existing on-device plan while offline. New approvals and changes need connectivity to arrive. Actual Apple enforcement behaviour is still being verified on real devices.",
      ],
      [
        "Can children share one iPad?",
        "The initial product assumes each child has their own supported device and Child Apple Account. Do not assume separate per-child rules work on a shared iPad.",
      ],
      [
        "Is there an Android app?",
        "iPhone and iPad first. Android availability has not been announced.",
      ],
    ],
  },
  {
    title: "Requests",
    items: [
      [
        "Can my child ask for more time?",
        "Yes. Requests can ask for extra time, a deadline extension, temporary access or a specific exception. Parents can approve, partially approve, decline or ask for one clarification.",
      ],
      [
        "What happens if a parent doesn’t respond?",
        "The existing agreement remains in effect. A request does not approve itself. It expires when its context ends, or at the maximum pending lifetime, and the child can make a new relevant request.",
      ],
      [
        "Will approval unlock an app instantly?",
        "No instant-unlock promise is made. Approved and Applied on device are distinct states; the child’s device needs to receive and apply the change.",
      ],
    ],
  },
  {
    title: "Subscriptions",
    items: [
      [
        "How much will Themis cost?",
        "Pricing is coming soon. The direction is one family subscription; monthly and annual prices and child/device limits have not been finalised.",
      ],
      [
        "Can another parent or carer help?",
        "An invited Guardian can help manage ordinary family rules, approvals and requests within the household’s role permissions.",
      ],
    ],
  },
  {
    title: "Troubleshooting",
    items: [
      [
        "What happens if protection stops working?",
        "The status should explain whether a device is offline, a change is syncing, attention is needed or protection is unavailable. Stale information must never be presented as Protected.",
      ],
      [
        "Can support approve a task or override a rule?",
        "No. Support can diagnose Themis and guide parents. It cannot approve tasks, grant Free Passes or make ordinary family decisions.",
      ],
    ],
  },
];
export const protectionStates = [
  {
    label: "Protected",
    tone: "positive",
    description:
      "A confirmed protection state in this example. Real status must be based on current device evidence.",
  },
  {
    label: "Sync Pending",
    tone: "",
    description:
      "A change has been approved or saved, but application on the device is not yet confirmed.",
  },
  {
    label: "Device Offline",
    tone: "attention",
    description:
      "The device cannot currently be reached. The existing on-device plan is designed to continue; new changes may wait.",
  },
  {
    label: "Needs Attention",
    tone: "attention",
    description:
      "Something needs the family’s attention. The app should explain the relevant next step.",
  },
  {
    label: "Protection Unavailable",
    tone: "attention",
    description:
      "Themis cannot confirm protection is available. Do not rely on an old Protected label.",
  },
];
export const rules = [
  {
    title: "Homework Deadline",
    kind: "Deadline Lock",
    description: "Homework due at 6? Games can wait until it’s approved.",
    detail:
      "Choose the task, the deadline and the games that pause if approval hasn’t arrived. Real-world work needs a parent’s judgement.",
    time: "6:00 PM",
    state: "Awaiting parent approval",
    outcome: "Selected games pause · School access stays available",
  },
  {
    title: "Bedtime",
    kind: "Scheduled Rule",
    description: "Agree a finish time before the evening starts.",
    detail:
      "A schedule pauses selected social apps from 10 PM until 7 AM. Everyone can see when the boundary starts and ends.",
    time: "10:00 PM – 7:00 AM",
    state: "Scheduled pause",
    outcome: "Social apps paused · Always Allowed stays available",
  },
  {
    title: "Earn First",
    kind: "Completion before access",
    description: "Do the agreed activity. Then make space for games.",
    detail:
      "Link access to parent-approved work or a supported in-app activity that Themis can genuinely verify. Not automatic proof of homework.",
    time: "Activity → approval → access",
    state: "Completion required",
    outcome: "Access follows the agreed completion condition",
  },
  {
    title: "Focus Session",
    kind: "Time for one thing",
    description: "Thirty minutes with fewer configured distractions.",
    detail:
      "A supported focus session keeps the plan clear. Finishing the session does not prove that real-world homework or chores were completed.",
    time: "30 minutes",
    state: "Focus in progress",
    outcome: "Configured distractions pause during the session",
  },
  {
    title: "Ask for more time",
    kind: "Requests",
    description: "“Can I have another fifteen minutes?”",
    detail:
      "Send a reason with a specific request. A parent can agree, offer a different duration, decline or ask for one clarification.",
    time: "+15 minutes requested",
    state: "Waiting for a decision",
    outcome: "The existing agreement stays in place while waiting",
  },
  {
    title: "Free Pass",
    kind: "Temporary access",
    description: "Life changes. The plan can make room.",
    detail:
      "A parent chooses which apps or sites and how long. The preview explains which rule the pass temporarily overrides. Normal rules resume at expiry.",
    time: "20 minutes · YouTube",
    state: "Temporary school access",
    outcome: "Overrides the selected YouTube restriction for the agreed time",
  },
];
