import Link from "next/link";
import { PageHero, Card, Callout } from "@/components/ui";
import { ContactForm } from "@/components/forms";
import { submissionsEnabled } from "@/lib/services";
import { site } from "@/lib/config";
import { metadata as meta } from "@/lib/metadata";
export const metadata = meta(
  "Support",
  "Find setup, pairing, rules, privacy and protection-status help for Themis Family.",
  "/support",
);
export default function Page() {
  return (
    <>
      <PageHero
        label="Support"
        title="Let’s make it clearer."
        intro="Start with the guide that fits. For a family decision, your parent or carer is the person to ask."
      />
      <div className="container page-body">
        <div className="three-grid">
          {[
            [
              "Setup & pairing",
              "Create your family and connect a child’s own device.",
              "/how-it-works",
            ],
            [
              "Rules, approvals & requests",
              "Understand deadlines, decisions and temporary access.",
              "/rules",
            ],
            [
              "Protection status",
              "Know what each state means and what remains unconfirmed.",
              "/safety",
            ],
            [
              "School access",
              "Review Always Allowed items and educational access.",
              "/school-access",
            ],
            [
              "Subscriptions",
              "Pricing and availability are still being finalised.",
              "/pricing",
            ],
            [
              "Privacy",
              "Understand what is visible and what isn’t.",
              "/privacy",
            ],
          ].map(([title, body, href]) => (
            <Card key={title} title={title}>
              <p>{body}</p>
              <Link href={href} className="text-link">
                Read the guide →
              </Link>
            </Card>
          ))}
        </div>
        <Callout title="Support can diagnose Themis. Support cannot parent the child.">
          Support cannot approve a task or request, grant a Free Pass, or change
          ordinary family rules as if it were a parent.
        </Callout>
        <section className="content-section" id="safeguarding">
          <h2>Safeguarding is separate.</h2>
          <p className="lede">
            Concerns about a child’s safety need a different response from
            technical troubleshooting. This pre-launch website is not a
            monitored emergency or safeguarding service.
          </p>
          <p className="lede">
            A dedicated safeguarding process and contact route will be published
            after approval. Do not send urgent or sensitive safeguarding
            information through the demonstration form below.
          </p>
        </section>
        <section
          className="content-section editorial-split"
          style={{ alignItems: "start" }}
        >
          <div>
            <h2>Contact support</h2>
            <p className="lede">
              The live support channel will open with the service. This form is
              ready for that connection.
            </p>
            {site.supportEmail && (
              <a className="text-link" href={"mailto:" + site.supportEmail}>
                {site.supportEmail}
              </a>
            )}
            <Link href="/faq" className="text-link">
              Browse frequently asked questions →
            </Link>
          </div>
          <ContactForm kind="support" demo={submissionsEnabled()} />
        </section>
      </div>
    </>
  );
}
