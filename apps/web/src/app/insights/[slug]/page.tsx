import Image from "next/image";
import { notFound } from "next/navigation";
import { articles, articleContent } from "@/lib/articles";
import { ArticleCards } from "@/components/articles";
import { PageHero, CTA } from "@/components/ui";
import { JsonLd } from "@/components/json-ld";
import { publicOrigin } from "@/lib/site-origin";
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

function formatDate(value: string) {
  return new Intl.DateTimeFormat("en-GB", {
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "UTC",
  }).format(new Date(value + "T00:00:00Z"));
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
  const origin = publicOrigin();

  return (
    <>
      <PageHero label={a.category} title={a.title} intro={a.summary} />

      <div className="container article-hero-wrap">
        <figure className="article-hero-media">
          <Image
            src={a.image}
            width={1600}
            height={980}
            priority
            sizes="(max-width: 850px) 100vw, 1040px"
            alt={a.imageAlt}
          />
          <figcaption>
            Illustrative stock photography. Models are not Themis customers and
            are not depicted in the situation described. Photo:{" "}
            <a href={a.imageSource} rel="noreferrer">
              {a.imageCredit}
            </a>
            .
          </figcaption>
        </figure>
      </div>

      <div className="container article-layout">
        <article className="article-prose">
          <div className="article-byline">
            <p>
              <strong>Themis Family Editorial Team</strong>
            </p>
            <p className="small">
              Published <time dateTime={a.date}>{formatDate(a.date)}</time> ·
              Updated <time dateTime={a.updated}>{formatDate(a.updated)}</time>{" "}
              · {a.minutes} min read
            </p>
            <p className="small">
              Evidence checked against the sources linked in this guide.
            </p>
          </div>

          <section className="article-tldr" aria-labelledby="article-tldr-title">
            <p className="article-tldr-label">TL;DR</p>
            <h2 id="article-tldr-title">The short version.</h2>
            <ul>
              {a.tldr.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </section>

          <Content />

          <section className="article-faqs" aria-labelledby="article-faq-title">
            <p className="article-tldr-label">Quick answers</p>
            <h2 id="article-faq-title">Frequently asked questions.</h2>
            <div className="article-faq-list">
              {a.faqs.map((faq) => (
                <details key={faq.question}>
                  <summary>{faq.question}</summary>
                  <p>{faq.answer}</p>
                </details>
              ))}
            </div>
          </section>
        </article>

        <aside className="article-principle" aria-label="Themis editorial principle">
          <span>THEMIS PRINCIPLE</span>
          <p>
            A boundary can protect a child today. The longer-term job is to
            build the judgement they will need when the boundary is no longer
            there.
          </p>
        </aside>
      </div>

      <div className="container">
        <section className="section">
          <h2 style={{ marginBottom: 35 }}>Keep reading.</h2>
          <ArticleCards exclude={slug} />
        </section>
      </div>

      <CTA />

      {!a.draft && origin && (
        <JsonLd
          data={{
            "@context": "https://schema.org",
            "@type": "Article",
            headline: a.title,
            description: a.summary,
            image: a.image,
            datePublished: a.date,
            dateModified: a.updated,
            author: { "@type": "Organization", name: "Themis Family" },
            publisher: { "@type": "Organization", name: "Themis Family" },
            mainEntityOfPage: origin + "/insights/" + slug,
          }}
        />
      )}

      {!a.draft && (
        <JsonLd
          data={{
            "@context": "https://schema.org",
            "@type": "FAQPage",
            mainEntity: a.faqs.map((faq) => ({
              "@type": "Question",
              name: faq.question,
              acceptedAnswer: {
                "@type": "Answer",
                text: faq.answer,
              },
            })),
          }}
        />
      )}
    </>
  );
}
