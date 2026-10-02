import { notFound } from "next/navigation";
import Link from "next/link";
import { pages } from "@/lib/content";
import { metadata } from "@/lib/metadata";
import {
  PageHero,
  CTA,
  Card,
  Callout,
  Photography,
  PhonePreview,
  ButtonLink,
} from "@/components/ui";
import {
  PrivacyPanel,
  ProtectionStates,
  AgreementStory,
} from "@/components/product";
import { site } from "@/lib/config";
const seo: Record<string, { title: string; description: string }> = {
  "for-parents": {
    title: "Parental Controls for Families Without Constant Policing",
    description:
      "Themis Family helps parents create visible screen-time, homework, bedtime and gaming agreements with requests, approvals and privacy-first controls.",
  },
  "for-children": {
    title: "Child-Friendly Parental Controls & Family Screen Rules",
    description:
      "See how Themis Family explains screen-time rules, homework deadlines, requests and paused apps clearly to children without covert monitoring.",
  },
  "for-teens": {
    title: "Teen Parental Controls With Privacy & Clear Boundaries",
    description:
      "Themis Family gives teens visible digital agreements, requests and privacy-aware parental controls without message reading or a surveillance feed.",
  },
  "school-access": {
    title: "Parental Controls That Keep School Apps Available",
    description:
      "Learn how Themis Family keeps configured school and essential apps available while entertainment rules, homework deadlines and screen-time boundaries apply.",
  },
  privacy: {
    title: "Privacy-First Parental Controls for Families",
    description:
      "Understand what Themis Family parental controls can show parents, what stays private, and how the product avoids covert message reading and continuous location tracking.",
  },
  safety: {
    title: "Safe & Transparent Parental Controls for Families",
    description:
      "See how Themis Family approaches protection status, device pairing, family roles, essential access and honest reporting when a device needs attention.",
  },
  features: {
    title: "Parental Control App Features for Family Routines",
    description:
      "Explore Themis Family features for screen time, homework, bedtime, gaming, requests, temporary access, focus sessions, school access and privacy.",
  },
  about: {
    title: "About",
    description:
      "Themis Family is building privacy-first parental controls around visible family agreements, clearer digital boundaries and growing independence.",
  },
  press: {
    title: "Press & Media",
    description:
      "Press and media information about Themis Family, a family digital-boundaries product for clearer parental controls on iPhone and iPad.",
  },
};

export const dynamicParams = false;
export function generateStaticParams() {
  return Object.keys(pages).map((slug) => ({ slug }));
}
export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const p = pages[slug];
  const search = seo[slug];
  return p
    ? metadata(
        search?.title ?? p.label,
        search?.description ?? p.intro,
        "/" + slug,
      )
    : {};
}
export default async function ContentPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const p = pages[slug];
  if (!p) notFound();
  return (
    <>
      <PageHero label={p.label} title={p.title} intro={p.intro} />
      <div
        className="container page-body"
        data-engagement={
          slug === "for-parents"
            ? "parent"
            : slug === "for-teens"
              ? "teen"
              : slug === "privacy"
                ? "privacy"
                : undefined
        }
      >
        {(p.visual === "family" || p.visual === "teen") && (
          <div className="editorial-split" style={{ marginBottom: 65 }}>
            <Photography kind={p.visual} />
            {p.visual === "teen" ? <PhonePreview teen /> : <AgreementStory />}
          </div>
        )}
        {p.visual === "child" && (
          <div className="editorial-split" style={{ marginBottom: 65 }}>
            <AgreementStory />
            <PhonePreview />
          </div>
        )}
        {p.visual === "privacy" && (
          <div style={{ marginBottom: 65 }}>
            <PrivacyPanel />
          </div>
        )}
        {p.visual === "status" && (
          <div style={{ marginBottom: 65 }}>
            <ProtectionStates />
          </div>
        )}
        {p.sections.map((s, i) => (
          <section className="content-section" key={s.title}>
            <div className="section-heading">
              <p className="eyebrow">
                {"0" + (i + 1)} · {p.label}
              </p>
              <h2>{s.title}</h2>
              {s.body && <p className="lede">{s.body}</p>}
            </div>
            {s.items && (
              <div className="three-grid">
                {s.items.map((item, j) => (
                  <Card
                    key={item.title}
                    title={item.title}
                    tone={i % 2 === 0 ? ["blue", "mint", "peach"][j % 3] : ""}
                  >
                    <p>{item.body}</p>
                  </Card>
                ))}
              </div>
            )}
            {s.note && <Callout>{s.note}</Callout>}
          </section>
        ))}
        {slug === "privacy" && (
          <ButtonLink href="/legal/privacy-policy" secondary>
            Read the draft privacy policy
          </ButtonLink>
        )}
        {slug === "safety" && (
          <Link href="/support" className="text-link">
            Support & safeguarding information →
          </Link>
        )}
        {slug === "press" && site.mediaEmail && (
          <a href={"mailto:" + site.mediaEmail} className="text-link">
            Contact the media team
          </a>
        )}
      </div>
      <CTA />
    </>
  );
}
