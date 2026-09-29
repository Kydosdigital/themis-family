"use client";
import { useEffect, useState } from "react";
type EventName =
  | "hero_cta"
  | "waitlist_cta"
  | "waitlist_submit"
  | "pricing_navigation"
  | "faq_interaction"
  | "download_cta"
  | "section_engagement"
  | "support_submit";
declare global {
  interface Window {
    dataLayer?: Record<string, unknown>[];
    gtag?: (...args: unknown[]) => void;
  }
}
const ga = process.env.NEXT_PUBLIC_GA4_ID || "";
const gtm = process.env.NEXT_PUBLIC_GTM_ID || "";
export const analyticsEnabled =
  /^G-[A-Z0-9]+$/.test(ga) || /^GTM-[A-Z0-9]+$/.test(gtm);
let accepted = false;
export function track(
  name: EventName,
  data: { section?: string; outcome?: string } = {},
) {
  if (analyticsEnabled && accepted) {
    if (window.gtag) window.gtag("event", name, data);
    else window.dataLayer?.push({ event: name, ...data });
  }
}
export function Analytics() {
  const [consent, setConsent] = useState<string | null>("pending");
  useEffect(() => {
    const timer = setTimeout(() => {
      if (analyticsEnabled) {
        try {
          setConsent(localStorage.getItem("themis-analytics"));
        } catch {
          setConsent(null);
        }
      }
    }, 0);
    return () => clearTimeout(timer);
  }, []);
  useEffect(() => {
    accepted = consent === "accepted";
    if (!accepted || !analyticsEnabled) return;
    window.dataLayer = window.dataLayer || [];
    const script = document.createElement("script");
    script.async = true;
    script.id = "themis-analytics-script";
    if (/^GTM-[A-Z0-9]+$/.test(gtm)) {
      window.dataLayer.push({ "gtm.start": Date.now(), event: "gtm.js" });
      script.src = "https://www.googletagmanager.com/gtm.js?id=" + gtm;
    } else {
      window.gtag = (...args: unknown[]) => {
        window.dataLayer?.push(args as unknown as Record<string, unknown>);
      };
      window.gtag("js", new Date());
      window.gtag("config", ga, {
        send_page_view: false,
        allow_google_signals: false,
        allow_ad_personalization_signals: false,
      });
      script.src = "https://www.googletagmanager.com/gtag/js?id=" + ga;
    }
    document.head.appendChild(script);
    return () => {
      accepted = false;
      script.remove();
    };
  }, [consent]);
  useEffect(() => {
    function click(e: MouseEvent) {
      const el = (e.target as Element).closest<HTMLElement>("[data-event]");
      if (el) track(el.dataset.event as EventName);
    }
    document.addEventListener("click", click);
    const observer = new IntersectionObserver(
      (entries) =>
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            track("section_engagement", {
              section: (entry.target as HTMLElement).dataset.engagement,
            });
            observer.unobserve(entry.target);
          }
        }),
      { threshold: 0.3 },
    );
    document
      .querySelectorAll("[data-engagement]")
      .forEach((el) => observer.observe(el));
    return () => {
      document.removeEventListener("click", click);
      observer.disconnect();
    };
  }, [consent]);
  function choose(value: string) {
    try {
      localStorage.setItem("themis-analytics", value);
    } catch {}
    setConsent(value);
  }
  if (!analyticsEnabled) return null;
  return (
    <>
      {consent === null && (
        <aside className="cookie-banner" aria-label="Optional analytics">
          <h2 style={{ fontSize: 20, marginBottom: 10 }}>
            Help us understand what’s useful?
          </h2>
          <p>
            Optional analytics measure visits and interactions. We don’t send
            your form answers. You can use the website without accepting.
          </p>
          <div className="button-row">
            <button
              className="button button-secondary"
              onClick={() => choose("rejected")}
            >
              Reject analytics
            </button>
            <button className="button" onClick={() => choose("accepted")}>
              Accept analytics
            </button>
          </div>
        </aside>
      )}
      <button
        className="cookie-settings"
        onClick={() => {
          if (consent === "accepted") {
            try {
              localStorage.removeItem("themis-analytics");
            } catch {}
            window.location.reload();
          } else setConsent(null);
        }}
      >
        Analytics preferences
      </button>
    </>
  );
}
