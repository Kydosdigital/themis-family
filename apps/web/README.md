# Themis Family website

Complete pre-launch marketing website. The native app remains separate in ../ios. Website completion does not mean Apple enforcement or public launch is approved.

## Stack and local setup

Node 24 LTS, npm, Next.js App Router, React, TypeScript, Tailwind CSS v4, Three.js, React Three Fiber/Drei, Motion, Lucide and trusted local MDX. Native details and dialog elements provide the accessible disclosure primitives; no generic component kit skin.

From apps/web:

- npm ci
- Copy .env.example to .env.local. Leave the production origin blank for local development.
- Set FORM_PROVIDER=local only to exercise the development form adapter.
- npm run dev

Commands: npm run typecheck, npm run lint, npm test, npm run build, npm run start, npm run test:e2e, npm run verify. Install browser binaries with npx playwright install chromium before E2E tests. E2E starts the production server itself if port 3000 is free. Use only synthetic personal data in tests.

## Configuration

| Variable                                            | Default / effect                                                                                         |
| --------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| NEXT_PUBLIC_SITE_URL                                | Empty. All pages noindex; sitemap empty. Set the verified HTTPS public origin before a production build. |
| NEXT_PUBLIC_LAUNCH_STATE                            | prelaunch. A launched state additionally needs a valid Apple App Store URL before CTA changes.           |
| NEXT_PUBLIC_APP_STORE_URL                           | Empty; no invented download link.                                                                        |
| NEXT_PUBLIC_SUPPORT_EMAIL / NEXT_PUBLIC_MEDIA_EMAIL | Empty; no invented inbox.                                                                                |
| FORM_PROVIDER                                       | disabled. local is permitted only with NODE_ENV=development.                                             |
| NEXT_PUBLIC_GA4_ID / NEXT_PUBLIC_GTM_ID             | Empty. Analytics disabled. GTM takes precedence if both exist.                                           |

Public environment values are embedded at build time. Changing them requires rebuilding. Preview deployments are non-indexed when VERCEL_ENV=preview. Pricing, future child/device limits and social links are centralised in src/lib/config.ts. No price is currently configured.

## Design and content

Semantic colour, surface, type, spacing, radius, shadow and motion tokens live in globals.css. Layout breakpoints cover 320px, 600px, 850px, 1100px and 1500px. The site uses the approved calm-editorial / confident-minimal direction with restrained warmth. Cobalt is the action colour; no purple. Keep child and teen experiences visibly distinct but within the same system.

Most routes are server-rendered. Shared product copy is in src/lib/content.ts. Change app claims only against approved requirements; see CLAIMS.md. Local MDX is repository-trusted code, never user-supplied HTML or remote content. Each article has an explicit draft flag. The three examples are labelled and noindexed; published Article JSON-LD is emitted only after the flag changes. Do not fabricate author identities or publication dates.

Replace the text wordmark, text favicon and generated social image only after logo approval. Photography is local and rendered with next/image; source/usage notes are in IMAGE_SOURCES.md. There are no published testimonials or press claims.

## WebGL and motion

Boundary is a small client island with a complete HTML/CSS fallback. It dynamically imports the R3F scene after initial content. Canvas uses demand rendering, capped 1–1.5 DPR, simple geometry and no heavy postprocessing. Intersection and page visibility controls prevent off-screen/hidden animation; transitions settle. Touch, reduced-motion, save-data and low-capability devices default to static. Visitors may enable or pause motion. Context loss and render errors retain the fallback.

The same visual language is used in the hero and How It Works. The preview never connects to actual devices. All essential explanations remain ordinary text, independent of WebGL.

## Forms and Supabase integration

POST /api/waitlist accepts firstName, email, optional childCount/ageBand/challenge, and consent=true.
POST /api/support accepts name, email, topic and message.
Responses expose status (success, duplicate, validation, rate_limited, unavailable), message, optional field errors and demo flag.

The shared Zod schemas strip unknown fields, normalise email and bound input lengths. Endpoints enforce origin, content type and payload size. Errors never disclose provider internals. No form content is logged.

The development-only adapter serialises writes to ignored .local-data JSON files and detects duplicate waitlist addresses. Data survives development restarts. It is not multi-process storage. Remove local test files when no longer needed. Production always fails closed with HTTP 503 until a real provider is implemented; setting FORM_PROVIDER=local cannot enable the mock in production.

A future Supabase provider must implement the WaitlistService and SupportService interfaces:

1. Use the explicitly authorised Themis project, never another connected project.
2. Add migration-backed, web-specific tables with least-privilege access. Enforce normalised-email uniqueness for the waitlist and atomic duplicate handling.
3. Keep service credentials server-only. Add durable per-client rate limiting before any live write; the current in-memory limiter is development-only.
4. Record consent purpose/version and time as reviewed, without collecting child identifiers. Approve retention/deletion and unsubscribe operations.
5. Provide monitored support delivery and separate safeguarding routing; do not make the support form a parent-approval channel.
6. Add provider contract, concurrency and rate-limit tests before enabling collection.

No Supabase schema or remote project has been mutated.

## Analytics and cookies

With IDs absent, no analytics scripts or consent storage are loaded. Configured providers load only after affirmative consent. The local storage key themis-analytics records the choice. Reject remains equally available. Withdrawing accepted consent reloads the page; old provider cookies may require browser removal. Review the actual GTM container and cookie inventory before activation.

Typed events cover CTA actions, waitlist/support outcomes, pricing, FAQ, download and section engagement. Only allowlisted section/outcome metadata is sent, never names, emails, message text or child data.

## Deployment

Vercel root directory: apps/web. Install: npm ci. Build: npm run build. Framework: Next.js. No deploy has been performed.

Before public release configure the verified HTTPS origin, approved legal text, form provider with durable rate limiting, operational contact/safeguarding routes and consent-reviewed analytics (if used). Do not change the iOS project's readiness gates. App Store launch state requires a real verified URL; a QR code must encode that URL when supplied. Current QR is explicitly a placeholder.

## Verification

Unit tests cover boundary validation and production mock protection. Playwright covers all routes at mobile and desktop widths, accessibility, navigation, forms, content interactions, fallbacks and indexing. Browser tests use a production build. See QA.md for actual results and remaining manual limitations.

The repository's scripts/verify.sh includes web verification. The path-scoped web CI runs npm ci, verification and Chromium E2E. It does not modify app requirements.
