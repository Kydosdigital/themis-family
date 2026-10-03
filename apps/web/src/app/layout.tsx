import type { Metadata } from "next";
import { Manrope } from "next/font/google";
import { Header } from "@/components/header";
import { Footer } from "@/components/footer";
import { Analytics } from "@/components/analytics";
import { Analytics as VercelAnalytics } from "@vercel/analytics/next";
import { site } from "@/lib/config";
import { publicOrigin } from "@/lib/site-origin";
import { JsonLd } from "@/components/json-ld";
import "./globals.css";
const manrope = Manrope({
  subsets: ["latin"],
  variable: "--font-manrope",
  display: "swap",
});
export const metadata: Metadata = {
  // Local social previews need a base; this never creates a public canonical.
  metadataBase: new URL(publicOrigin() || "http://localhost:3000"),
  title: {
    default: "Themis Family — Clear digital boundaries",
    template: "%s | Themis Family",
  },
  description:
    "Clear digital boundaries without the daily arguments. Family agreements around homework, bedtime, games and school access. iPhone and iPad first.",
};
export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  const origin = publicOrigin();

  return (
    <html lang="en-GB" className={manrope.variable}>
      <body>
        <a className="skip-link" href="#main">
          Skip to content
        </a>
        <Header />
        <main id="main" tabIndex={-1}>
          {children}
        </main>
        <Footer />
        <Analytics />
        <VercelAnalytics />
        {origin && (
          <>
            <JsonLd
              data={{
                "@context": "https://schema.org",
                "@type": "Organization",
                "@id": origin + "/#organization",
                name: site.name,
                alternateName: "Themis",
                url: origin,
                description:
                  "Themis Family helps families create clearer digital boundaries with visible agreements, requests and privacy-first parental controls.",
                logo: {
                  "@type": "ImageObject",
                  url: origin + "/icon.svg",
                },
                ...(site.socials.length ? { sameAs: site.socials.map((s) => s.href) } : {}),
              }}
            />
            <JsonLd
              data={{
                "@context": "https://schema.org",
                "@type": "WebSite",
                "@id": origin + "/#website",
                url: origin,
                name: site.name,
                alternateName: "Themis",
                inLanguage: "en-GB",
                publisher: { "@id": origin + "/#organization" },
              }}
            />
          </>
        )}
      </body>
    </html>
  );
}
