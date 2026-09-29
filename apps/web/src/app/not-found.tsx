import { PageHero, ButtonLink } from "@/components/ui";
export default function NotFound() {
  return (
    <>
      <PageHero
        label="404"
        title="This page isn’t part of the plan."
        intro="The link may have changed. Let’s get you somewhere useful."
      />
      <div className="container section" style={{ paddingTop: 0 }}>
        <ButtonLink href="/">Back to Themis Family</ButtonLink>
      </div>
    </>
  );
}
