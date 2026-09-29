import { PageHero, CTA, Callout } from "@/components/ui";
import { ArticleCards } from "@/components/articles";
import { categories } from "@/lib/articles";
import { metadata as meta } from "@/lib/metadata";
export const metadata = meta(
  "Insights",
  "Thoughtful reading about digital boundaries, privacy and family technology.",
  "/insights",
);
export default function Page() {
  return (
    <>
      <PageHero
        label="Insights"
        title="A little perspective. A clearer conversation."
        intro="Ideas for talking about technology at home — without turning every conversation into a debate."
      />
      <div className="container page-body">
        <div className="category-list" aria-label="Planned editorial topics">
          {categories.map((c) => (
            <span key={c}>{c}</span>
          ))}
        </div>
        <Callout>
          Our editorial library is taking shape. These three example articles
          demonstrate the topics and format; they have not been published as
          reviewed guidance.
        </Callout>
        <ArticleCards />
      </div>
      <CTA />
    </>
  );
}
