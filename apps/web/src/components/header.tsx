"use client";
import Link from "next/link";
import { useEffect, useRef, useState } from "react";
import { usePathname } from "next/navigation";
import { Menu, X, ChevronDown, ArrowUpRight } from "lucide-react";
import { navGroups, primaryCta } from "@/lib/config";
export function Header() {
  const [open, setOpen] = useState(false);
  const dialog = useRef<HTMLDialogElement>(null);
  const trigger = useRef<HTMLButtonElement>(null);
  const pathname = usePathname();
  useEffect(() => {
    if (open) {
      dialog.current?.showModal();
      document.body.style.overflow = "hidden";
    } else {
      dialog.current?.close();
      document.body.style.overflow = "";
    }
    return () => {
      document.body.style.overflow = "";
    };
  }, [open]);
  useEffect(() => {
    document
      .querySelectorAll<HTMLDetailsElement>(".desktop-nav details[open]")
      .forEach((d) => (d.open = false));
  }, [pathname]);
  function close() {
    // Safari cannot focus the trigger while the modal keeps the page inert.
    dialog.current?.close();
    setOpen(false);
    trigger.current?.focus();
  }
  return (
    <header className="site-header">
      <div className="container header-inner">
        <Link href="/" className="wordmark" aria-label="Themis Family home">
          themis<span>family</span>
        </Link>
        <nav className="desktop-nav" aria-label="Main navigation">
          {navGroups.map((group) => (
            <details
              key={group.title}
              onKeyDown={(e) => {
                if (e.key === "Escape") {
                  e.currentTarget.open = false;
                  e.currentTarget.querySelector("summary")?.focus();
                }
              }}
              onToggle={(e) => {
                if (e.currentTarget.open) {
                  const current = e.currentTarget;
                  document
                    .querySelectorAll<HTMLDetailsElement>(
                      ".desktop-nav details",
                    )
                    .forEach((d) => {
                      if (d !== current) d.open = false;
                    });
                }
              }}
            >
              <summary>
                {group.title}
                <ChevronDown size={13} />
              </summary>
              <div className="nav-dropdown">
                {group.links.map(([label, href]) => (
                  <Link key={href} href={href}>
                    {label}
                    <ArrowUpRight size={14} />
                  </Link>
                ))}
              </div>
            </details>
          ))}
          <Link href="/insights">Insights</Link>
          <Link href="/pricing" data-event="pricing_navigation">
            Pricing
          </Link>
        </nav>
        <Link
          href={primaryCta.href}
          className="header-cta"
          data-event="waitlist_cta"
        >
          {primaryCta.label}
          <ArrowUpRight size={16} />
        </Link>
        <button
          ref={trigger}
          className="menu-trigger"
          aria-label="Open navigation"
          aria-expanded={open}
          aria-controls="mobile-navigation"
          onClick={() => setOpen(true)}
        >
          <Menu />
        </button>
      </div>
      <dialog
        id="mobile-navigation"
        ref={dialog}
        className="mobile-nav"
        aria-label="Site navigation"
        onCancel={close}
        onClick={(e) => {
          if (e.target === e.currentTarget) close();
        }}
      >
        <div className="mobile-nav-content">
          <div className="row mobile-nav-heading">
            <span className="wordmark">
              themis<span>family</span>
            </span>
            <button onClick={close} aria-label="Close navigation">
              <X />
            </button>
          </div>
          <nav aria-label="Mobile navigation">
            {navGroups.map((group) => (
              <div key={group.title}>
                <p className="eyebrow">{group.title}</p>
                {group.links.map(([label, href]) => (
                  <Link href={href} key={href} onClick={close}>
                    {label}
                    <ArrowUpRight size={16} />
                  </Link>
                ))}
              </div>
            ))}
            <Link href="/insights" onClick={close}>
              Insights
            </Link>
            <Link href="/pricing" onClick={close}>
              Pricing
            </Link>
            <Link href={primaryCta.href} className="button" onClick={close}>
              {primaryCta.label}
              <ArrowUpRight size={16} />
            </Link>
          </nav>
        </div>
      </dialog>
    </header>
  );
}
