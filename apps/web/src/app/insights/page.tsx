import Link from "next/link";
import { PageHero, CTA, Callout } from "@/components/ui";
import { ArticleCards } from "@/components/articles";
import { articles, categories, topicClusters } from "@/lib/articles";
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

        <nav className="topic-cluster-jump" aria-label="Community journeys">
          <span>Explore a journey</span>
          {topicClusters.map((cluster) => (
            <a key={cluster.id} href={"#" + cluster.id}>
              {cluster.title}
            </a>
          ))}
        </nav>

        <section
          className="community-clusters"
          aria-labelledby="community-clusters-heading"
        >
          <div className="section-heading">
            <p className="eyebrow">
              <span aria-hidden="true"></span>Follow the question
            </p>
            <h2 id="community-clusters-heading">
              Start where the problem is. Keep reading until the picture is
              clearer.
            </h2>
            <p className="lede">
              Parents rarely have one isolated technology question. These
              journeys connect the guides that naturally belong together.
            </p>
          </div>

          <div className="topic-cluster-grid">
            {topicClusters.map((cluster) => (
              <section
                className="topic-cluster-card"
                id={cluster.id}
                key={cluster.id}
              >
                <p className="article-tldr-label">Themis journey</p>
                <h3>{cluster.title}</h3>
                <p>{cluster.intro}</p>
                <ol>
                  {cluster.slugs.map((slug, index) => {
                    const article = articles.find((a) => a.slug === slug);
                    if (!article) return null;
                    return (
                      <li key={slug}>
                        <span aria-hidden="true">
                          {String(index + 1).padStart(2, "0")}
                        </span>
                        <Link href={"/insights/" + slug}>{article.title}</Link>
                      </li>
                    );
                  })}
                </ol>
              </section>
            ))}
          </div>
        </section>

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

        <section
          className="community-all-guides"
          aria-labelledby="community-all-guides-heading"
        >
          <div className="section-heading">
            <p className="eyebrow">
              <span aria-hidden="true"></span>All guides
            </p>
            <h2 id="community-all-guides-heading">
              Find the question closest to what is happening at home.
            </h2>
          </div>
          <ArticleCards />
        </section>
      </div>
      <CTA />
    </>
  );
}
