import Link from "next/link";
import { articles } from "@/lib/articles";
export function ArticleCards({ exclude }: { exclude?: string }) {
  return (
    <div className="three-grid">
      {articles
        .filter((a) => a.slug !== exclude)
        .map((a) => (
          <Link
            className="article-card"
            key={a.slug}
            href={"/insights/" + a.slug}
          >
            <div className="article-art" aria-hidden="true">
              {a.art}
            </div>
            <div className="article-card-content">
              <p className="small">
                {a.category} · {a.minutes} min read
              </p>
              <h3>{a.title}</h3>
              <p>{a.summary}</p>
              <p className="small" style={{ marginTop: 20 }}>
                Example article · Not yet published ↗
              </p>
            </div>
          </Link>
        ))}
    </div>
  );
}
