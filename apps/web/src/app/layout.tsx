import type { Metadata } from "next";
import { Manrope } from "next/font/google";
import { Header } from "@/components/header";
import { Footer } from "@/components/footer";
import { Analytics } from "@/components/analytics";
import { site } from "@/lib/config";
import { JsonLd } from "@/components/json-ld";
import "./globals.css";
const manrope = Manrope({
  subsets: ["latin"],
  variable: "--font-manrope",
  display: "swap",
});
export const metadata: Metadata = {
  // Local social previews need a base; this never creates a public canonical.
  metadataBase: new URL(site.origin || "http://localhost:3000"),
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
        {site.origin && (
          <JsonLd
            data={{
              "@context": "https://schema.org",
              "@type": "Organization",
              name: site.name,
              url: site.origin,
            }}
          />
        )}
      </body>
    </html>
  );
}
