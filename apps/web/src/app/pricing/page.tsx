import { PageHero, Checklist, ButtonLink, Callout } from "@/components/ui";
import { site } from "@/lib/config";
import { metadata as meta } from "@/lib/metadata";
export const metadata = meta(
  "Pricing",
  "One family subscription. Themis Family pricing is coming soon.",
  "/pricing",
);
export default function Page() {
  const ready = site.pricing.monthly !== null && site.pricing.annual !== null;
  return (
    <>
      <PageHero
        label="Pricing"
        title="One family. A clearer routine."
        intro="Thoughtful tools for the agreements you make every day. We’re still finalising the details."
      />
      <section
        className="container section editorial-split"
        style={{ paddingTop: 0, alignItems: "start" }}
      >
        <div className="pricing-card">
          <p className="eyebrow">Themis Family</p>
          <h2>
            {ready
              ? new Intl.NumberFormat("en-GB", {
                  style: "currency",
                  currency: site.pricing.currency,
                }).format(site.pricing.monthly!) + "/month"
              : "Pricing coming soon"}
          </h2>
          <p>One family subscription.</p>
          {ready && (
            <p>
              {new Intl.NumberFormat("en-GB", {
                style: "currency",
                currency: site.pricing.currency,
              }).format(site.pricing.annual!)}{" "}
              annually
            </p>
          )}
          <Checklist
            items={[
              "Clear rules and visible agreements",
              "Parent approvals and requests",
              "Child and Teen experiences",
              "School and essential access",
              "Honest protection status",
            ]}
          />
          <ButtonLink>Get notified</ButtonLink>
        </div>
        <div>
          <h2>
            No guesswork.
            <br />
            No invented small print.
          </h2>
          <p className="lede">
            Monthly and annual options will be shown here once confirmed. Child
            and device limits will be explained before you subscribe.
          </p>
          <Callout>
            Joining the waitlist is not a purchase. We won’t ask for payment
            details.
          </Callout>
        </div>
      </section>
    </>
  );
}
