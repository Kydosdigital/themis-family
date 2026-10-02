import Link from "next/link";
import { PageHero, Callout, Card } from "@/components/ui";
import { JsonLd } from "@/components/json-ld";
import { metadata as meta } from "@/lib/metadata";
import { publicOrigin } from "@/lib/site-origin";

export const metadata = meta(
  "How Themis researches digital parenting",
  "How Themis Family researches, checks and updates guidance about children, technology, AI, screen time, social media, gaming and online safety.",
  "/insights/how-we-research",
);

const evidence = [
  {
    title: "Research synthesis",
    body:
      "Systematic reviews, meta-analyses and strong peer-reviewed studies are our preferred sources for claims about effects, associations and interventions.",
  },
  {
    title: "Public authorities",
    body:
      "Regulators, governments and international bodies help us understand population behaviour, policy, media use and child-rights frameworks.",
  },
  {
    title: "Safeguarding specialists",
    body:
      "Organisations such as the NSPCC, IWF and national child-safety services inform practical safeguarding and reporting guidance.",
  },
  {
    title: "Current platform documentation",
    body:
      "Apple, Google, Meta, TikTok, Roblox, Discord and other first-party sources are checked for current settings, age rules and product behaviour.",
  },
];

export default function Page() {
  const origin = publicOrigin();

  return (
    <>
      <PageHero
        label="Research & editorial standards"
        title="We show our work."
        intro="Themis Community turns research, safeguarding guidance, platform information and real parent questions into practical digital-parenting guidance."
        breadcrumbs={[
          { label: "Home", href: "/" },
          { label: "Themis Community", href: "/insights" },
          { label: "How we research" },
        ]}
      />

      <div className="container page-body">
        <section className="content-section">
          <div className="section-heading">
            <p className="eyebrow">
              <span aria-hidden="true" />
              Our standard
            </p>
            <h2>Useful first. Evidence underneath it.</h2>
            <p className="lede">
              A parent should not have to read an academic paper before they can
              decide what to do tonight. But our recommendation should still be
              traceable to evidence strong enough to support it.
            </p>
          </div>

          <div className="two-grid">
            {evidence.map((item) => (
              <Card key={item.title} title={item.title}>
                <p>{item.body}</p>
              </Card>
            ))}
          </div>
        </section>

        <section className="content-section">
          <div className="section-heading">
            <p className="eyebrow">
              <span aria-hidden="true" />
              How a guide is built
            </p>
            <h2>We research before we recommend.</h2>
          </div>
          <ol className="research-steps">
            <li>
              <strong>Start with the parent's real question.</strong>
              <span>
                We define the situation first, including what the parent knows,
                what they may be assuming and which safety questions matter.
              </span>
            </li>
            <li>
              <strong>Build the evidence picture.</strong>
              <span>
                We look for recent, relevant sources and keep the age group,
                geography, study design and limitations attached to the claim.
              </span>
            </li>
            <li>
              <strong>Separate evidence from interpretation.</strong>
              <span>
                If a study shows an association, we do not rewrite it as
                causation. If evidence is mixed, the guide says it is mixed.
              </span>
            </li>
            <li>
              <strong>Translate it into a family decision.</strong>
              <span>
                Research becomes useful only when a parent can understand what
                it changes about the next conversation, boundary or safety step.
              </span>
            </li>
            <li>
              <strong>Review fast-moving information.</strong>
              <span>
                AI products, platform settings, age rules, law and reporting
                routes are rechecked more frequently than stable background
                research.
              </span>
            </li>
          </ol>
        </section>

        <Callout title="Reddit, Mumsnet and parent communities have a role, but not this one.">
          We use community discussions to understand the language parents use,
          the questions they are asking and emerging problems worth
          investigating. A forum post does not prove that something is common,
          harmful or caused by a particular factor. Those claims require
          stronger evidence.
        </Callout>

        <section className="content-section">
          <div className="section-heading">
            <p className="eyebrow">
              <span aria-hidden="true" />
              What we will not do
            </p>
            <h2>Certainty is not something we manufacture.</h2>
          </div>
          <div className="two-grid">
            <Card title="No invented expertise">
              <p>
                Articles are published by the Themis Family Editorial Team. We
                do not create a fictional doctor, psychologist or parent and
                present that identity as real.
              </p>
            </Card>
            <Card title="No convenient study shopping">
              <p>
                We do not start with the conclusion we want and search until one
                paper appears to support it. Contradictory findings belong in
                the evidence picture.
              </p>
            </Card>
            <Card title="No diagnosis from a search query">
              <p>
                Words such as addiction, grooming and depression have meanings
                that cannot responsibly be assigned to a child from one parent
                description.
              </p>
            </Card>
            <Card title="No product-shaped answer">
              <p>
                Sometimes the useful next step is a conversation, a school, a
                platform setting or specialist help. Themis Family is mentioned
                where its actual features fit the problem.
              </p>
            </Card>
          </div>
        </section>

        <section className="content-section">
          <div className="section-heading">
            <p className="eyebrow">
              <span aria-hidden="true" />
              Sources we return to
            </p>
            <h2>Primary and specialist sources first.</h2>
            <p className="lede">
              Every article has its own source list. Our recurring source bank
              includes organisations such as Ofcom, peer-reviewed research
              indexed by PubMed, UNICEF, the NSPCC, IWF, Pew Research Center,
              Common Sense Media and current first-party platform guidance.
            </p>
          </div>
          <p>
            You can inspect the evidence directly in each guide. Start with the{" "}
            <Link href="/insights">Themis Community library</Link>.
          </p>
        </section>
      </div>

      {origin && (
        <>
          <JsonLd
            data={{
              "@context": "https://schema.org",
              "@type": "WebPage",
              name: "How Themis researches digital parenting",
              description:
                "The research and editorial standards used by Themis Community.",
              url: origin + "/insights/how-we-research",
              isPartOf: { "@id": origin + "/#website" },
              about: { "@id": origin + "/#organization" },
              inLanguage: "en-GB",
            }}
          />        </>
      )}
    </>
  );
}
