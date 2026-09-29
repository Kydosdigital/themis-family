import Link from "next/link";
import { footerGroups, site } from "@/lib/config";
export function Footer() {
  return (
    <footer className="site-footer">
      <div className="container">
        <div className="footer-intro">
          <Link href="/" className="wordmark">
            themis<span>family</span>
          </Link>
          <p>
            Clear boundaries.
            <br />
            More room to be a family.
          </p>
          <span className="small">Designed around trust.</span>
        </div>
        <nav className="footer-grid" aria-label="Footer navigation">
          {footerGroups.map((g) => (
            <div key={g.title}>
              <h2>{g.title}</h2>
              {g.links.map(([label, href]) => (
                <Link href={href} key={href}>
                  {label}
                </Link>
              ))}
            </div>
          ))}
        </nav>
        <div className="footer-bottom">
          <span>© {new Date().getFullYear()} Themis Family</span>
          <span>iPhone and iPad first · Coming soon</span>
          <span>
            {site.socials.length
              ? site.socials.map((s) => (
                  <a key={s.href} href={s.href}>
                    {s.label}
                  </a>
                ))
              : "Social channels coming soon"}
          </span>
        </div>
      </div>
    </footer>
  );
}
