# Public website implementation

Status: IMPLEMENTED — draft review; launch dependencies remain
Branch: feat/public-website
Scope: Complete public website in apps/web, isolated from apps/ios.
Authority: User-approved public-website brief and implementation plan.

The existing CURRENT_STATE.md continues to describe the native application's design work. This record does not replace it.

Implemented: site shell and semantic design system; every requested route; local editorial examples; Three.js boundary storytelling and static alternatives; development-only form services; claims controls; SEO; optional consent-gated analytics; verification scripts and CI.

Verified: TypeScript, lint, production build, 15 unit/integration tests, 70 Playwright tests, 48 desktop/mobile accessibility scans and repository verification. All requested routes and responsive screenshots reviewed. See apps/web/QA.md for evidence and limitations.

Lighthouse mobile lab scores: Home 93, Privacy 95, Waitlist 91; CLS 0 on each. Home and Waitlist LCP remain approximately 2.8s against the 2.5s target. Physical Safari and a full human screen-reader audit remain required before launch.

Launch dependencies: production origin and hosting configuration; approved legal text and safeguarding/contact routing; an approved durable backend with rate limiting and server-only credentials; production performance and device validation. Production form providers intentionally fail closed. Pricing, App Store links and social accounts remain unconfigured.

No deployment, application enforcement, Supabase project changes, or approved requirement modifications.
