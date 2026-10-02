import Link from "next/link";
import {
  ArrowRight,
  Check,
  Eye,
  MessageCircle,
  GraduationCap,
  Smartphone,
  Heart,
  LockKeyhole,
} from "lucide-react";
import { Boundary } from "@/components/boundary";
import {
  ButtonLink,
  CTA,
  Card,
  Eyebrow,
  PhonePreview,
  Photography,
  SectionHeading,
  Checklist,
} from "@/components/ui";
import {
  AgreementStory,
  PrivacyPanel,
  ProtectionStates,
} from "@/components/product";
import { RuleDemo } from "@/components/rule-demo";
import { Reveal } from "@/components/reveal";\nimport { ArticleCards } from "@/components/articles";
import { metadata as makeMetadata } from "@/lib/metadata";
export const metadata = makeMetadata(
  "Clear digital boundaries",
  "Set clear digital rules once, and let the phone enforce them. Meet Themis Family, coming first to iPhone and iPad.",
  "/",
);
export default function Home() {
  return (
    <>
      <section className="hero container">
        <div className="hero-grid">
          <div>
            <Eyebrow>Less negotiating. More living.</Eyebrow>
            <h1>
              Clear digital boundaries. <em>Without the daily arguments.</em>
            </h1>
            <p className="lede">
              Set clear digital rules once, and let the phone enforce them.
            </p>
            <div className="button-row" data-event="hero_cta">
              <ButtonLink />
              <ButtonLink href="/how-it-works" secondary>
                See how it works
              </ButtonLink>
            </div>
            <p className="hero-note">
              <Smartphone size={14} /> iPhone and iPad first. Coming soon.
            </p>
          </div>
          <Boundary />
        </div>
        <div className="hero-bottom">
          <span>
            <Eye />
            Visible family agreements
          </span>
          <span>
            <MessageCircle />
            Room for requests
          </span>
          <span>
            <GraduationCap />
            School access, considered
          </span>
          <span>
            <LockKeyhole />
            Privacy by principle
          </span>
        </div>
      </section>
      <section className="section section-soft">
        <div className="container editorial-split">
          <Reveal>
            <Eyebrow>A familiar evening?</Eyebrow>
            <h2>
              The argument isn’t
              <br />
              really about the phone.
            </h2>
            <p className="lede">
              It’s about the homework that needs finishing. The bedtime that
              keeps slipping. The “five more minutes” that starts the same
              conversation, again.
            </p>
            <p className="lede">
              You agreed the rule. Now you’re stuck enforcing it.
            </p>
            <div className="quote-block" style={{ marginTop: 30 }}>
              What if the agreement
              <br />
              did the enforcing?
            </div>
          </Reveal>
          <Reveal>
            <AgreementStory />
          </Reveal>
        </div>
      </section>
      <section className="section container">
        <SectionHeading
          label="A simpler rhythm"
          title="Agree it once. Make it clear."
        >
          The family agrees the boundary. The phone applies it consistently.
        </SectionHeading>
        <div className="three-grid">
          {[
            [
              "Agree the boundary",
              "Homework by 6 PM. Talk about what’s expected before the deadline arrives.",
            ],
            [
              "Choose what changes",
              "Roblox and Minecraft pause if the work hasn’t been completed and approved.",
            ],
            [
              "Let Themis handle the routine",
              "Your child sees why, what to do next and how to request an exception.",
            ],
          ].map(([title, body], i) => (
            <Reveal key={title}>
              <Card
                title={title}
                number={"0" + (i + 1)}
                tone={["blue", "mint", "peach"][i]}
              >
                <p>{body}</p>
              </Card>
            </Reveal>
          ))}
        </div>
        <Link className="text-link" href="/how-it-works">
          Take a closer look <ArrowRight size={17} />
        </Link>
      </section>
      <section className="container" style={{ paddingBottom: 80 }}>
        <div className="trust-strip">
          <span>
            <Eye size={20} />
            Visible rules
          </span>
          <span>
            <MessageCircle size={20} />
            Requests, not stand-offs
          </span>
          <span>
            <Check size={20} />
            Parent approvals
          </span>
          <span>
            <Heart size={20} />
            Respect built in
          </span>
        </div>
      </section>
      <section className="section container" style={{ paddingTop: 0 }}>
        <SectionHeading
          label="Their age. Their experience."
          title="Growing up changes the conversation."
        >
          Themis gives children and teens the same clarity, in a way that feels
          right for them.
        </SectionHeading>
        <div className="two-grid">
          <div className="experience-card" data-engagement="child">
            <div>
              <Eyebrow>For children</Eyebrow>
              <h3>
                A little guidance.
                <br />A clear next step.
              </h3>
              <p>
                Simple language. Larger controls. A reassuring plan for the day.
              </p>
              <Link href="/for-children" className="text-link">
                Their side of the story <ArrowRight size={15} />
              </Link>
            </div>
            <PhonePreview />
          </div>
          <div className="experience-card teen" data-engagement="teen">
            <div>
              <Eyebrow>For teens</Eyebrow>
              <h3>
                More independence.
                <br />
                The same respect.
              </h3>
              <p>Visible agreements. Room to explain. Privacy that matters.</p>
              <Link href="/for-teens" className="text-link">
                Built with teens in mind <ArrowRight size={15} />
              </Link>
            </div>
            <PhonePreview teen />
          </div>
        </div>
      </section>
      <section className="section section-soft">
        <div className="container editorial-split">
          <Photography />
          <div data-engagement="parent">
            <Eyebrow>Room for real life</Eyebrow>
            <h2>School still works.</h2>
            <p className="lede">
              Games can wait. A teacher’s assignment shouldn’t have to.
            </p>
            <Checklist
              items={[
                "Keep configured school apps and sites available.",
                "Ask for temporary access when something unexpected comes up.",
                "Keep essential access part of the plan.",
              ]}
            />
            <p className="small">
              A teacher’s YouTube video? Request access to YouTube for a set
              time. Themis does not identify educational content inside the app.
            </p>
            <Link href="/school-access" className="text-link">
              School & essential access <ArrowRight size={17} />
            </Link>
          </div>
        </div>
      </section>
      <section className="section container">
        <PrivacyPanel />
      </section>
      <section className="section container" style={{ paddingTop: 0 }}>
        <SectionHeading
          label="Everyday agreements"
          title="Parent control. Without constant policing."
        >
          Bedtime. Homework. One more round. Start with the moments your family
          knows.
        </SectionHeading>
        <RuleDemo />
      </section>
      <section className="section section-soft">
        <div
          className="container editorial-split"
          style={{ alignItems: "start" }}
        >
          <div>
            <Eyebrow>Clarity includes the difficult bits</Eyebrow>
            <h2>
              No false
              <br />
              reassurance.
            </h2>
            <p className="lede">
              Know when protection is confirmed, when a change is syncing and
              when a device needs attention.
            </p>
            <p className="lede">
              Approved doesn’t always mean applied yet. Themis should tell you
              the difference.
            </p>
            <Link href="/safety" className="text-link">
              How we think about trust <ArrowRight size={17} />
            </Link>
          </div>
          <ProtectionStates />
        </div>
      </section>
      <CTA />
    </>
  );
}
