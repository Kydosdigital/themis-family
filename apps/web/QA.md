# Website QA — 29 September 2026

## Mobile follow-up — 30 September

The live review found a 35px header CTA with 10px text, 14px form inputs, undersized standalone links and squeezed two-column audience previews. The update provides 44px main navigation/link targets, 16px inputs, full-width hero buttons and stacked family previews. The menu close button stays visible while scrolling; focus returns after the modal closes, including WebKit.

All 14 new mobile checks pass across Chromium and WebKit: 320/375/390/430px layouts, small-phone and landscape key journeys, unclipped previews, readable forms and menu focus. The broader run passed the existing 70 tests and exposed narrow walkthrough overflow and Safari focus issues, both fixed and covered by the final mobile rerun. CI runs the complete suite.

Touch devices no longer request the desktop Motion module or update the static boundary on every scroll. A live Lighthouse baseline varied substantially on this workstation (Home 56, Privacy 47, Waitlist 72), with inconsistent resource latency and blocking times; it does not support a before/after speed claim. Physical iPhone and Android testing remains distinct from browser emulation.

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
