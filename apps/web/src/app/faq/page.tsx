import { PageHero, CTA } from "@/components/ui";
import { faqGroups } from "@/lib/content";
import { JsonLd } from "@/components/json-ld";
import { metadata as meta } from "@/lib/metadata";
export const metadata = meta(
  "Themis Family FAQ: Parental Controls, Privacy & Devices",
  "Answers about Themis Family parental controls, iPhone and iPad support, screen-time rules, privacy, requests, school access and family agreements.",
  "/faq",
);
export default function Page() {
  return (
    <>
      <PageHero
        label="FAQ"
        title="Good questions. Clear answers."
        intro="What Themis is designed to do, what it won’t do and what’s still being confirmed."
      />
      <div className="container page-body">
        {faqGroups.map((group) => (
          <section className="faq-group" key={group.title}>
            <h2>{group.title}</h2>
            {group.items.map(([q, a]) => (
              <details className="faq-item" key={q}>
                <summary data-event="faq_interaction">{q}</summary>
                <p>{a}</p>
              </details>
            ))}
          </section>
        ))}
      </div>
      <CTA />
      <JsonLd
        data={{
          "@context": "https://schema.org",
          "@type": "FAQPage",
          mainEntity: faqGroups.flatMap((g) =>
            g.items.map(([q, a]) => ({
              "@type": "Question",
              name: q,
              acceptedAnswer: { "@type": "Answer", text: a },
            })),
          ),
        }}
      />
    </>
  );
}
