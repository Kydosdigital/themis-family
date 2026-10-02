import { PageHero, CTA, Callout, Card } from "@/components/ui";
import { Boundary } from "@/components/boundary";
import { RuleDemo } from "@/components/rule-demo";
import { metadata as meta } from "@/lib/metadata";
export const metadata = meta(
  "How Themis Family Parental Controls Work",
  "See how Themis Family turns screen-time, homework, bedtime and gaming boundaries into visible family agreements on iPhone and iPad.",
  "/how-it-works",
);
const steps = [
  [
    "Create your family",
    "A parent or carer creates the household. The Owner can invite a Guardian to help with ordinary family decisions.",
  ],
  [
    "Add your child or teen",
    "Choose the experience that fits: simpler and more reassuring for children, more mature for teens.",
  ],
  [
    "Connect their iPhone or iPad",
    "Use the authorised pairing and Apple permission flow. Each child needs their own supported device and Child Apple Account; shared devices are not assumed to separate siblings’ rules.",
  ],
  [
    "Choose a family agreement",
    "Start with a familiar routine — a homework deadline, bedtime schedule or a supported Earn First activity.",
  ],
  [
    "Choose apps and sites",
    "Select what the agreement applies to. Explain what will pause and why.",
  ],
  [
    "Set the schedule or deadline",
    "Choose clear times together. Everyone sees the expectation before the boundary starts.",
  ],
  [
    "Confirm school and essential access",
    "Review Always Allowed items and school tools. Phone, Messages and Maps are recommended where technically supported.",
  ],
  [
    "Test protection",
    "Check that setup is complete and understand the protection status. This preview does not prove real-device enforcement.",
  ],
  [
    "Let the agreement guide the routine",
    "Themis is designed to apply the plan. Children can see explanations, submit work for approval and ask for exceptions.",
  ],
];
export default function Page() {
  return (
    <>
      <PageHero
        label="How it works"
        title="One conversation. A clearer everyday."
        intro="Agree what matters together. Then give that agreement a place to live."
      />
      <div className="container">
        <div className="walkthrough">
          <div className="walkthrough-visual">
            <Boundary walkthrough />
            <p className="small" style={{ marginTop: 30 }}>
              Product walkthrough. Apple capabilities and real-device
              enforcement remain under verification.
            </p>
          </div>
          <div>
            {steps.map(([title, body], i) => (
              <section className="walkthrough-step" key={title}>
                <span className="card-number">{"0" + (i + 1)}</span>
                <h2>{title}</h2>
                <p>{body}</p>
              </section>
            ))}
          </div>
        </div>
        <section className="section">
          <h2 style={{ marginBottom: 35 }}>
            Different routines. The same clarity.
          </h2>
          <RuleDemo />
          <div className="two-grid" style={{ marginTop: 30 }}>
            <Card title="Parent Approval">
              <p>
                Homework and chores require an adult’s judgement. Your child
                says they’ve finished; a parent checks and approves.
              </p>
            </Card>
            <Card title="Automatic Verification">
              <p>
                Only supported in-app sessions can provide automatic completion
                evidence. Finishing a timer is not proof of real-world homework.
              </p>
            </Card>
          </div>
          <Callout title="Approved → applied on device">
            The adult’s decision and the device’s update are different steps.
            Connectivity and Apple-controlled behaviour can affect timing. We do
            not promise instant remote unlock.
          </Callout>
        </section>
      </div>
      <CTA />
    </>
  );
}
