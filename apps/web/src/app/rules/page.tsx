import { PageHero, CTA, Card, Callout } from "@/components/ui";
import { RuleDemo } from "@/components/rule-demo";
import { rules } from "@/lib/content";
import { metadata as meta } from "@/lib/metadata";
export const metadata = meta(
  "Screen Time Rules & Family Agreements",
  "Explore Themis Family screen-time rules, homework deadlines, bedtime schedules, gaming boundaries, requests, Focus Sessions and temporary access.",
  "/rules",
);
export default function Page() {
  return (
    <>
      <PageHero
        label="Rules & agreements"
        title="The rule is clear. The reason is, too."
        intro="Choose an agreement around the moment that matters. Make the expectation, the timing and the consequence visible."
      />
      <div className="container">
        <RuleDemo />
        <section className="section">
          <div className="two-grid">
            {rules.map((r, i) => (
              <Card title={r.title} number={"0" + (i + 1)} key={r.title}>
                <p>{r.detail}</p>
              </Card>
            ))}
          </div>
          <Callout title="An exception needs a decision.">
            A request does not approve itself. Existing rules remain while it is
            pending. A Free Pass always has an explicit scope and duration; it
            is not a permanent override.
          </Callout>
        </section>
      </div>
      <CTA />
    </>
  );
}
