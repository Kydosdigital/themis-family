import { Smartphone, QrCode } from "lucide-react";
import { PageHero, Card, ButtonLink, PhonePreview } from "@/components/ui";
import { site, launch } from "@/lib/config";
import { metadata as meta } from "@/lib/metadata";
import { ContactForm } from "@/components/forms";
import { submissionsEnabled } from "@/lib/services";
export const metadata = meta(
  "Themis Family App for iPhone & iPad",
  "Themis Family parental controls are coming to iPhone and iPad first. Get launch updates and the verified App Store link when available.",
  "/download",
);
export default function Page() {
  return (
    <>
      <PageHero
        label="Get the app"
        title="iPhone and iPad first."
        intro={
          launch
            ? "Get Themis Family from the App Store."
            : "We’re building the first Themis Family experience. Be first to hear when it’s ready."
        }
      />
      <section
        className="container section editorial-split"
        style={{ paddingTop: 0 }}
      >
        <div>
          <div className="two-grid">
            <Card title={launch ? "Get Themis" : "App Store — coming soon"}>
              <Smartphone size={28} />
              <p style={{ marginTop: 20 }}>
                {launch
                  ? "Follow the verified App Store link."
                  : "The app is not available to download yet. A verified App Store link will appear here."}
              </p>
              {launch && (
                <a
                  href={site.appStoreUrl}
                  className="text-link"
                  data-event="download_cta"
                >
                  Open the App Store →
                </a>
              )}
            </Card>
            <Card title="Scan to download, later">
              <QrCode size={28} />
              <p style={{ marginTop: 20 }}>
                QR placeholder. We’ll add a working code once the official
                download link is available.
              </p>
            </Card>
          </div>
          <p className="lede">
            No Android availability or launch date has been announced. Join the
            waitlist for launch updates.
          </p>
          <div style={{ marginTop: 25 }}>
            <ButtonLink href="/waitlist">Get launch updates</ButtonLink>
          </div>
        </div>
        <PhonePreview />
      </section>
      {!launch && (
        <section
          className="container section"
          style={{ maxWidth: 780, paddingTop: 0 }}
        >
          <ContactForm demo={submissionsEnabled()} />
        </section>
      )}
    </>
  );
}
