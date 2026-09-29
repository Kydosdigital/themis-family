import { PageHero, Checklist, Callout } from "@/components/ui";
import { ContactForm } from "@/components/forms";
import { submissionsEnabled } from "@/lib/services";
import { metadata as meta } from "@/lib/metadata";
export const metadata = meta(
  "Join the waitlist",
  "Be first to hear when Themis Family is ready. iPhone and iPad first.",
  "/waitlist",
);
export default function Page() {
  return (
    <>
      <PageHero
        label="Join the waitlist"
        title="A little less “five more minutes”."
        intro="Themis Family is on its way. Get thoughtful launch updates, straight to your inbox."
      />
      <section
        className="container editorial-split section"
        style={{ paddingTop: 0, alignItems: "start" }}
      >
        <div>
          <h2>
            Clearer agreements.
            <br />
            More room for family.
          </h2>
          <Checklist
            items={[
              "Visible rules around homework, bedtime and games.",
              "A respectful experience for children and teens.",
              "Room for requests and real-life exceptions.",
              "Privacy at the heart of the product.",
            ]}
          />
          <Callout>
            iPhone and iPad first. Pricing and launch timing will be confirmed
            before availability. There’s no payment or commitment to subscribe.
          </Callout>
        </div>
        <ContactForm demo={submissionsEnabled()} />
      </section>
    </>
  );
}
