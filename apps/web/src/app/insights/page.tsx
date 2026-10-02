import { PageHero, CTA, Callout } from "@/components/ui";
import { ArticleCards } from "@/components/articles";
import { categories } from "@/lib/articles";
import { metadata as meta } from "@/lib/metadata";

export const metadata = meta(
  "Themis Community",
  "Research-backed, practical guidance for raising children with technology, from AI and screen time to social media, gaming, explicit content and digital independence.",
  "/insights",
);

export default function Page() {
  return (
    <>
      <PageHero
        label="Themis Community"
        title="Understand their digital world before you decide what to do about it."
        intro="Practical, research-backed guidance for the moments that make parents stop and think: What do I do now?"
      />
      <div className="container page-body">
        <div className="community-intro">
          <p>
            Themis is not here to tell families that technology is the enemy.
            We look at what children are actually doing online, what the
            evidence can and cannot tell us, and what parents can do next.
          </p>
          <p>
            Our approach is simple: protect when protection is needed, guide
            while children are learning, help them build with technology, and
            gradually prepare them to make good decisions without us.
          </p>
        </div>

        <div className="category-list" aria-label="Themis Community topics">
          {categories.map((c) => (
            <span key={c}>{c}</span>
          ))}
        </div>

        <Callout title="How we write">
          Important claims are linked to the research or guidance behind them.
          Community conversations help us understand what parents are asking,
          but they do not replace evidence. When research is mixed, we say so.
        </Callout>

        <ArticleCards />
      </div>
      <CTA />
    </>
  );
}
