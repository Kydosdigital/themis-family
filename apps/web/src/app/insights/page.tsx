import Link from "next/link";
import { PageHero, CTA, Callout } from "@/components/ui";
import { ArticleCards } from "@/components/articles";
import { articles, categories, topicClusters } from "@/lib/articles";
import { metadata as meta } from "@/lib/metadata";
import { JsonLd } from "@/components/json-ld";
import { publicOrigin } from "@/lib/site-origin";

export const metadata = meta(
  "Digital Parenting Guides & Research",
  "Research-backed digital parenting guides on AI, screen time, social media, gaming, online safety, privacy and digital independence from Themis Community.",
  "/insights",
);

export default function Page() {
  const origin = publicOrigin();

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
          but they do not replace evidence. When research is mixed, we say so.{" "}
          <Link href="/insights/how-we-research">
            Read our research and editorial standards.
          </Link>
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

      {origin && (
        <>
          <JsonLd
            data={{
              "@context": "https://schema.org",
              "@type": "CollectionPage",
              name: "Themis Community",
              description:
                "Research-backed digital parenting guides from Themis Family.",
              url: origin + "/insights",
              isPartOf: { "@id": origin + "/#website" },
              about: { "@id": origin + "/#organization" },
              inLanguage: "en-GB",
              mainEntity: {
                "@type": "ItemList",
                itemListElement: articles
                  .filter((article) => !article.draft)
                  .map((article, index) => ({
                    "@type": "ListItem",
                    position: index + 1,
                    name: article.title,
                    url: origin + "/insights/" + article.slug,
                  })),
              },
            }}
          />        </>
      )}
    </>
  );
}
