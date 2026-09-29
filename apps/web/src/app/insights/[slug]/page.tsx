import { notFound } from "next/navigation";
import { articles, articleContent } from "@/lib/articles";
import { ArticleCards } from "@/components/articles";
import { PageHero, Callout, CTA } from "@/components/ui";
import { JsonLd } from "@/components/json-ld";
import { site } from "@/lib/config";
import { metadata as meta } from "@/lib/metadata";
export const dynamicParams = false;
export function generateStaticParams() {
  return articles.map((a) => ({ slug: a.slug }));
}
export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const a = articles.find((a) => a.slug === slug);
  return a ? meta(a.title, a.summary, "/insights/" + slug, a.draft) : {};
}
export default async function Page({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const a = articles.find((a) => a.slug === slug);
  if (!a) notFound();
  const { default: Content } = await articleContent(slug);
  return (
    <>
      <PageHero label={a.category} title={a.title} intro={a.summary} />
      <div className="container">
        <article className="article-prose">
          <p className="small">
            Example draft: <time dateTime={a.date}>29 September 2026</time> ·
            Updated <time dateTime={a.updated}>29 September 2026</time> ·{" "}
            {a.minutes} min read
          </p>
          <Callout>
            Example article — not yet published or editorially reviewed. This is
            an illustration of our future Insights library.
          </Callout>
          <Content />
        </article>
        <section className="section">
          <h2 style={{ marginBottom: 35 }}>
            Another thought to take with you.
          </h2>
          <ArticleCards exclude={slug} />
        </section>
      </div>
      <CTA />
      {!a.draft && site.origin && (
        <JsonLd
          data={{
            "@context": "https://schema.org",
            "@type": "Article",
            headline: a.title,
            description: a.summary,
            datePublished: a.date,
            dateModified: a.updated,
            author: { "@type": "Organization", name: "Themis Family" },
            mainEntityOfPage: site.origin + "/insights/" + slug,
          }}
        />
      )}
    </>
  );
}
