# Website QA — 29 September 2026

## Verified implementation

- All 22 requested route patterns implemented, including three example article URLs (24 rendered page URLs).
- TypeScript, ESLint, production build and 15 unit/integration tests pass.
- Full Chromium Playwright suite: 70 passing tests across 1440px desktop and an emulated iPhone 13 viewport.
- 48 axe scans across all 24 pages at both sizes: no WCAG A/AA violations reported.
- Additional responsive checks at 320px, 768px and 1920px: no horizontal overflow.
- All internal homepage/navigation/footer links resolve. Unknown routes return 404 and draft routes emit noindex.
- Form validation, preserved answers on network errors, duplicate state, pending/disabled state, rate-limit feedback and disabled production provider verified.
- Local-adapter tests use synthetic data in an isolated temporary directory and cover persisted success, concurrent duplicate handling and support storage.
- WebGL tested on desktop and emulated mobile: successful rendering, finite rendering after settling, off-screen suspension, context loss, unavailable context and reduced-motion fallback.
- Licensed images load successfully; full-page screenshots reviewed for all page URLs at desktop and mobile widths.
- Keyboard menu opening, Escape and focus return verified; form error focus and native FAQ disclosures verified.
- Runtime browser errors absent in page scans. Next.js 16.3.6 can log an internal NoFallbackError while correctly returning 404 for a non-generated dynamic route; the HTTP response and user-facing 404 are tested.
- Repository Claude workflow validator passes. iOS code and approved requirements are unchanged.

## Performance

Production server on localhost, Chrome, Lighthouse 13 mobile simulated throttling. Figures are a single final lab run, not field Core Web Vitals.

| Route     | Performance | Accessibility | Best practices |   LCP | CLS | Total blocking time |
| --------- | ----------: | ------------: | -------------: | ----: | --: | ------------------: |
| /         |          93 |           100 |            100 | 2.79s |   0 |                85ms |
| /privacy  |          95 |           100 |            100 | 2.40s |   0 |               166ms |
| /waitlist |          91 |           100 |            100 | 2.80s |   0 |               230ms |

The 2.5s LCP target was met on Privacy but not Home or Waitlist in this run. Measure again on the configured production hosting and representative physical phones before launch; no field-performance guarantee is made.

WebGL is dynamically split (largest scene chunk approximately 940KB uncompressed). It is not requested by default on touch/reduced-motion/constrained devices; those get the complete HTML/CSS visual. Desktop scenes use demand rendering and capped DPR. Mobile homepage transfer fell from about 620KB to 369KB after deferring 3D on touch hardware. A short global loading fallback was removed after a waitlist footer shift was observed; pages now arrive as complete content, while forms and scenes retain their own loading states.

SEO scores are intentionally limited in this local build: no production origin is configured, every page is noindex and robots disallows crawling. Canonical URLs and the public sitemap require the verified origin. Draft legal and example articles remain excluded regardless.

Run node tests/performance.mjs against the production server, with CHROME_PATH if Chrome is not auto-detected. Raw reports and the isolated Chrome profile remain ignored in lighthouse-results.

## Review boundaries

Chromium mobile emulation is not a physical iPhone/Safari test. Semantic structure, accessible names and keyboard behaviour have been checked; a full human screen-reader audit and physical-device Safari testing remain pre-launch checks. Automated axe results do not establish complete WCAG conformance.

No Apple enforcement was implemented or validated. No live waitlist, support delivery, analytics provider, Supabase project, public deployment, payment collection or application launch was activated. Website legal pages, contact routing, prices and App Store assets remain explicitly pending as requested.
