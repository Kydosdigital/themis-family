import Link from "next/link";
import Image from "next/image";
import {
  ArrowUpRight,
  ArrowRight,
  Check,
  BookOpen,
  Moon,
  Gamepad2,
  MessageCircle,
  Clock,
  ShieldCheck,
} from "lucide-react";
import { primaryCta } from "@/lib/config";
import type { ReactNode } from "react";
export function ButtonLink({
  href = primaryCta.href,
  children = primaryCta.label,
  secondary = false,
  className = "",
}: {
  href?: string;
  children?: ReactNode;
  secondary?: boolean;
  className?: string;
}) {
  return (
    <Link
      href={href}
      className={`button ${secondary ? "button-secondary" : ""} ${className}`}
      data-event={
        href === "/waitlist"
          ? "waitlist_cta"
          : href === "/pricing"
            ? "pricing_navigation"
            : href === "/download"
              ? "download_cta"
              : undefined
      }
    >
      {children}
      <ArrowUpRight size={18} aria-hidden="true" />
    </Link>
  );
}
export function Eyebrow({ children }: { children: ReactNode }) {
  return (
    <p className="eyebrow">
      <span aria-hidden="true" />
      {children}
    </p>
  );
}
export function SectionHeading({
  label,
  title,
  children,
}: {
  label: string;
  title: string;
  children?: ReactNode;
}) {
  return (
    <div className="section-heading">
      <Eyebrow>{label}</Eyebrow>
      <h2>{title}</h2>
      {children && <p className="lede">{children}</p>}
    </div>
  );
}
export function PageHero({
  label,
  title,
  intro,
  children,
  breadcrumbs,
}: {
  label: string;
  title: string;
  intro: string;
  children?: ReactNode;
  breadcrumbs?: { label: string; href?: string }[];
}) {
  const crumbs =
    breadcrumbs ??
    [
      { label: "Home", href: "/" },
      { label },
    ];

  return (
    <section className="page-hero container">
      <nav aria-label="Breadcrumb" className="breadcrumb">
        {crumbs.map((crumb, index) => (
          <span className="breadcrumb-part" key={crumb.label}>
            {index > 0 && <span aria-hidden="true">/</span>}
            {crumb.href ? <Link href={crumb.href}>{crumb.label}</Link> : <span>{crumb.label}</span>}
          </span>
        ))}
      </nav>
      <Eyebrow>{label}</Eyebrow>
      <h1>{title}</h1>
      <p className="lede">{intro}</p>
      {children}
    </section>
  );
}
export function Callout({
  children,
  title,
}: {
  children: ReactNode;
  title?: string;
}) {
  return (
    <aside className="callout">
      {title && <h3>{title}</h3>}
      {children}
    </aside>
  );
}
export function Card({
  title,
  children,
  number,
  tone = "",
}: {
  title: string;
  children: ReactNode;
  number?: string;
  tone?: string;
}) {
  return (
    <article className={`card ${tone}`}>
      {number && <span className="card-number">{number}</span>}
      <h3>{title}</h3>
      <div>{children}</div>
    </article>
  );
}
export function CTA() {
  return (
    <section className="container cta-section">
      <div className="cta-line" aria-hidden="true" />
      <Eyebrow>A little more clarity. A little less conflict.</Eyebrow>
      <h2>
        Make room for
        <br />
        life beyond the screen.
      </h2>
      <p>
        Be first to hear when Themis Family is ready.
        <br />
        iPhone and iPad first.
      </p>
      <ButtonLink />
      <span className="small">Thoughtful updates. No daily noise.</span>
    </section>
  );
}
export function Photography({
  kind = "family",
  caption = true,
}: {
  kind?: "family" | "teen";
  caption?: boolean;
}) {
  const teen = kind === "teen";
  return (
    <figure className="photography">
      <Image
        src={teen ? "/images/teen.jpg" : "/images/family.jpg"}
        width={1200}
        height={900}
        sizes="(max-width: 700px) 100vw, 50vw"
        alt={
          teen
            ? "A teenager relaxing at home with her phone."
            : "A parent and child learning together at their home computer."
        }
      />
      {caption && (
        <figcaption>
          Everyday family life. Illustrative stock photography; models are not
          Themis customers. Photo:{" "}
          {teen ? "cottonbro studio" : "Julia M Cameron"} / Pexels.
        </figcaption>
      )}
    </figure>
  );
}
export function PhonePreview({ teen = false }: { teen?: boolean }) {
  return (
    <div className={`phone ${teen ? "phone-teen" : ""}`}>
      <div className="phone-top">
        <span>9:41</span>
        <span className="phone-island" />
        <span>•••</span>
      </div>
      <div className="phone-content">
        <div className="phone-brand">
          themis <span>family</span>
        </div>
        <p className="small">
          <span className="status-dot" /> Themis is active · Product preview
        </p>
        <h3>{teen ? "Your day. Your plan." : "Hi Alex. You’ve got this."}</h3>
        <p>{teen ? "Here’s what we agreed." : "One thing at a time."}</p>
        <div className="phone-task">
          <div className="row">
            <BookOpen size={20} />
            <span>Today’s agreement</span>
          </div>
          <h4>Homework first.</h4>
          <p>
            Due by <strong>6:00 PM</strong>
          </p>
          <div className="mini-line">
            <span />
          </div>
          <p className="small">
            Games pause at 6 PM if your work hasn’t been approved.
          </p>
          <span className="preview-button">
            I’ve finished <Check size={16} />
          </span>
        </div>
        <div className="phone-row">
          <span>
            <Clock size={16} /> Need a little longer?
          </span>
          <ArrowRight size={16} />
        </div>
        <div className="phone-row">
          <span>
            <BookOpen size={16} /> School access stays available
          </span>
          <Check size={16} />
        </div>
        <p className="small phone-note">
          You can see what your parent can see.
        </p>
      </div>
      <div className="phone-home" />
    </div>
  );
}
export const ruleIcons = [
  BookOpen,
  Moon,
  Gamepad2,
  MessageCircle,
  Clock,
  ShieldCheck,
];
export function Checklist({ items }: { items: string[] }) {
  return (
    <ul className="checklist">
      {items.map((item) => (
        <li key={item}>
          <Check size={18} aria-hidden="true" />
          <span>{item}</span>
        </li>
      ))}
    </ul>
  );
}
