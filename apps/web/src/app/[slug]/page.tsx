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
import { JsonLd } from "@/components/json-ld";
import { site } from "@/lib/config";
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
  return p ? metadata(p.label, p.intro, "/" + slug) : {};
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
      {site.origin && (
        <JsonLd
          data={{
            "@context": "https://schema.org",
            "@type": "BreadcrumbList",
            itemListElement: [
              {
                "@type": "ListItem",
                position: 1,
                name: "Home",
                item: site.origin,
              },
              {
                "@type": "ListItem",
                position: 2,
                name: p.label,
                item: site.origin + "/" + slug,
              },
            ],
          }}
        />
      )}
    </>
  );
}
