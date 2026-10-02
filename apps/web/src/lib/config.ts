export const site = {
  name: "Themis Family",
  prelaunch: process.env.NEXT_PUBLIC_LAUNCH_STATE !== "launched",
  origin: process.env.NEXT_PUBLIC_SITE_URL || "",
  appStoreUrl: process.env.NEXT_PUBLIC_APP_STORE_URL || "",
  supportEmail: process.env.NEXT_PUBLIC_SUPPORT_EMAIL || "",
  mediaEmail: process.env.NEXT_PUBLIC_MEDIA_EMAIL || "",
  pricing: {
    monthly: null as number | null,
    annual: null as number | null,
    currency: "GBP",
    childLimit: null as number | null,
    deviceLimit: null as number | null,
  },
  socials: [] as { label: string; href: string }[],
};
export const launch =
  !site.prelaunch && /^https:\/\/apps\.apple\.com\//.test(site.appStoreUrl);
export const primaryCta = {
  label: launch ? "Get Themis" : "Join the waitlist",
  href: launch ? "/download" : "/waitlist",
};
export const navGroups = [
  {
    title: "Product",
    links: [
      ["How it works", "/how-it-works"],
      ["Features", "/features"],
      ["Rules & agreements", "/rules"],
      ["School access", "/school-access"],
    ],
  },
  {
    title: "Families",
    links: [
      ["For parents", "/for-parents"],
      ["For children", "/for-children"],
      ["For teens", "/for-teens"],
    ],
  },
  {
    title: "Trust",
    links: [
      ["Privacy", "/privacy"],
      ["Safety & trust", "/safety"],
      ["FAQ", "/faq"],
    ],
  },
];
export const footerGroups = [
  {
    title: "Product",
    links: [
      ["How it works", "/how-it-works"],
      ["Features", "/features"],
      ["Rules", "/rules"],
      ["Pricing", "/pricing"],
      ["Get the app", "/download"],
    ],
  },
  {
    title: "Families",
    links: [
      ["For parents", "/for-parents"],
      ["For children", "/for-children"],
      ["For teens", "/for-teens"],
      ["School access", "/school-access"],
    ],
  },
  {
    title: "Trust",
    links: [
      ["Privacy", "/privacy"],
      ["Safety", "/safety"],
      ["FAQ", "/faq"],
      ["Support", "/support"],
    ],
  },
  {
    title: "Company",
    links: [
      ["About", "/about"],
      ["Community", "/insights"],
      ["Press", "/press"],
    ],
  },
  {
    title: "Legal",
    links: [
      ["Privacy policy", "/legal/privacy-policy"],
      ["Terms", "/legal/terms"],
      ["Cookies", "/legal/cookies"],
    ],
  },
];
export const publicPaths = [
  "/",
  "/how-it-works",
  "/features",
  "/rules",
  "/school-access",
  "/for-parents",
  "/for-children",
  "/for-teens",
  "/privacy",
  "/safety",
  "/faq",
  "/support",
  "/pricing",
  "/download",
  "/waitlist",
  "/about",
  "/insights",
  "/insights/how-we-research",
  "/press",
];
