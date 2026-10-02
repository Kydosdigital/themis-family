import Image from "next/image";
import Link from "next/link";
import { articles } from "@/lib/articles";

export function ArticleCards({
  exclude,
  limit,
}: {
  exclude?: string;
  limit?: number;
}) {
  const visible = articles
    .filter((a) => a.slug !== exclude)
    .slice(0, limit ?? articles.length);

  return (
    <div className="three-grid">
      {visible.map((a) => (
        <Link
          className="article-card"
          key={a.slug}
          href={"/insights/" + a.slug}
        >
          <div className="article-art">
            <Image
              src={a.image}
              width={1200}
              height={760}
              sizes="(max-width: 850px) 100vw, 33vw"
              alt=""
            />
          </div>
          <div className="article-card-content">
            <p className="small">
              {a.category} · {a.minutes} min read
            </p>
            <h3>{a.title}</h3>
            <p>{a.summary}</p>
            <p className="small article-read-link">Read guide ↗</p>
          </div>
        </Link>
      ))}
    </div>
  );
}
