import { notFound } from "next/navigation";
import { PageHero, Callout } from "@/components/ui";
import { metadata as meta } from "@/lib/metadata";
const titles: Record<string, string> = {
  "privacy-policy": "Privacy policy",
  terms: "Terms",
  cookies: "Cookie information",
};
export const dynamicParams = false;
export function generateStaticParams() {
  return Object.keys(titles).map((slug) => ({ slug }));
}
export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  return meta(
    titles[slug] || "Legal",
    "Themis Family legal information and review status.",
    "/legal/" + slug,
    true,
  );
}
export default async function Page({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  if (!titles[slug]) notFound();
  const cookies = slug === "cookies";
  const analytics = !!(
    process.env.NEXT_PUBLIC_GA4_ID || process.env.NEXT_PUBLIC_GTM_ID
  );
  return (
    <>
      <PageHero
        label={titles[slug]}
        title={titles[slug]}
        intro={
          cookies
            ? "A short explanation of the technologies used on this website."
            : "Draft / legal review required"
        }
      />
      <div className="container page-body">
        <article className="article-prose">
          {cookies ? (
            <>
              <h2>With analytics disabled</h2>
              <p>
                The website does not set analytics or advertising cookies.
                Navigation, product previews and forms work without them. Our
                own form code does not set cookies.
              </p>
              <h2>Your analytics choice</h2>
              <p>
                {analytics
                  ? "Optional analytics is configured. It loads only after you accept it."
                  : "Optional analytics is not configured in this build, so no analytics service is loaded."}{" "}
                If enabled, the site stores your choice in your browser’s local
                storage under “themis-analytics”. This preference stays until
                you clear it or change it.
              </p>
              <h2>When optional analytics is enabled</h2>
              <p>
                Google Analytics or Google Tag Manager may use cookies after
                consent. You can reject analytics and still use the website.
                Changing an accepted preference reloads the page to stop further
                tracking; existing provider cookies may need clearing in your
                browser settings. The final provider configuration and cookie
                inventory must be reviewed before analytics is activated.
              </p>
              <h2>Other browser storage</h2>
              <p>
                Your browser can cache fonts, images and other assets to load
                pages more efficiently. Form submissions in local development
                are stored on the development computer, not in browser cookies.
              </p>
            </>
          ) : (
            <>
              <Callout title="Draft / legal review required">
                This page is a structured placeholder. It is not a legally final
                policy or set of terms. Live data collection and public launch
                require approved information.
              </Callout>
              {(slug === "privacy-policy"
                ? [
                    [
                      "Who is responsible",
                      "Confirm the legal entity, contact details and relevant privacy contact.",
                    ],
                    [
                      "Information and purposes",
                      "Document website waitlist and support data separately from app and child data. Identify the purpose and appropriate lawful basis for each.",
                    ],
                    [
                      "Recipients and international transfers",
                      "Confirm the production infrastructure, processors, locations and safeguards.",
                    ],
                    [
                      "Retention and deletion",
                      "Approve specific periods for website submissions, support records, logs and backups. Do not copy app retention periods into unrelated website processing.",
                    ],
                    [
                      "Your rights and choices",
                      "Add reviewed instructions for rights requests, withdrawing consent where applicable, complaints and contact routes.",
                    ],
                    [
                      "Children’s information",
                      "Complete specialist review and the Data Protection Impact Assessment before the child-facing product launches.",
                    ],
                    [
                      "Changes to this policy",
                      "Add an effective date only when the final version is approved.",
                    ],
                  ]
                : [
                    [
                      "Who provides the service",
                      "Confirm the contracting entity and contact details.",
                    ],
                    [
                      "Eligibility and family roles",
                      "Explain eligibility, household responsibilities and the account model using reviewed language.",
                    ],
                    [
                      "Availability and limitations",
                      "Describe supported devices and verified capabilities without unsupported guarantees.",
                    ],
                    [
                      "Subscriptions and cancellation",
                      "Add approved pricing, renewal, cancellation and applicable billing terms.",
                    ],
                    [
                      "Acceptable use and safety",
                      "Add reviewed responsibilities, safeguarding information and limitations.",
                    ],
                    [
                      "Liability, complaints and governing law",
                      "Reserved for specialist legal review. No legal terms are invented in this preview.",
                    ],
                  ]
              ).map(([title, body]) => (
                <section key={title}>
                  <h2>{title}</h2>
                  <p>{body}</p>
                </section>
              ))}
            </>
          )}
        </article>
      </div>
    </>
  );
}
