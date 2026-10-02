import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";
const routes = [
  "/",
  "/how-it-works",
  "/for-parents",
  "/for-children",
  "/for-teens",
  "/rules",
  "/school-access",
  "/privacy",
  "/safety",
  "/features",
  "/pricing",
  "/faq",
  "/about",
  "/support",
  "/download",
  "/waitlist",
  "/insights",
  "/insights/how-we-research",
  "/insights/child-bypassing-parental-controls",
  "/insights/is-chatgpt-for-homework-cheating",
  "/insights/found-porn-on-child-phone",
  "/insights/how-much-screen-time-is-too-much",
  "/insights/phone-in-bedroom-at-night",
  "/insights/what-age-first-phone",
  "/insights/is-my-child-ready-for-social-media",
  "/insights/child-angry-when-video-games-stop",
  "/insights/should-i-read-my-childs-text-messages",
  "/insights/child-talking-to-strangers-online",
  "/press",
  "/legal/privacy-policy",
  "/legal/terms",
  "/legal/cookies",
];
for (const route of routes)
  test("page, overflow and accessibility: " + route, async ({ page }) => {
    await page.emulateMedia({ reducedMotion: "reduce" });
    const errors: string[] = [];
    page.on("pageerror", (e) => errors.push(e.message));
    const response = await page.goto(route);
    expect(response?.status()).toBe(200);
    await expect(page.locator("h1")).toHaveCount(1);
    await expect(page.locator("h1")).toBeVisible();
    await page.evaluate(() => document.fonts.ready);
    expect(
      await page.evaluate(
        () => document.documentElement.scrollWidth <= innerWidth + 1,
      ),
    ).toBe(true);
    const result = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21aa", "wcag22aa"])
      .analyze();
    expect(
      result.violations.map((v) => ({
        id: v.id,
        nodes: v.nodes.map((n) => n.target),
      })),
    ).toEqual([]);
    expect(errors).toEqual([]);
    for (const img of await page.locator("img").all()) {
      await img.scrollIntoViewIfNeeded();
      await expect
        .poll(() =>
          img.evaluate(
            (el) =>
              (el as HTMLImageElement).complete &&
              (el as HTMLImageElement).naturalWidth > 0,
          ),
        )
        .toBe(true);
    }
    await page.evaluate(() => window.scrollTo(0, 0));
    await page.screenshot({
      path:
        "test-results/screens/" +
        test.info().project.name +
        "-" +
        (route === "/" ? "home" : route.replaceAll("/", "-")) +
        ".png",
      fullPage: true,
    });
  });

test("Community guides include TLDR, FAQs and structured FAQ data", async ({
  page,
}) => {
  for (const route of [
    "/insights/child-bypassing-parental-controls",
    "/insights/is-chatgpt-for-homework-cheating",
    "/insights/found-porn-on-child-phone",
    "/insights/how-much-screen-time-is-too-much",
    "/insights/phone-in-bedroom-at-night",
    "/insights/what-age-first-phone",
    "/insights/is-my-child-ready-for-social-media",
    "/insights/child-angry-when-video-games-stop",
    "/insights/should-i-read-my-childs-text-messages",
    "/insights/child-talking-to-strangers-online",
  ]) {
    await page.goto(route);
    await expect(page.getByText("TL;DR", { exact: true })).toBeVisible();
    await expect(
      page.getByRole("heading", { name: "Frequently asked questions." }),
    ).toBeVisible();
    await expect(page.locator(".article-faq-list details")).toHaveCount(4);
    const jsonLd = await page
      .locator('script[type="application/ld+json"]')
      .allTextContents();
    expect(jsonLd.some((value) => value.includes('"FAQPage"'))).toBe(true);
  }
});


test("Community is organised into topic journeys with curated internal links", async ({
  page,
}) => {
  await page.goto("/insights");
  await expect(page.locator(".topic-cluster-card")).toHaveCount(4);

  const clusterLinks = page.locator(".topic-cluster-card a[href^='/insights/']");
  expect(await clusterLinks.count()).toBeGreaterThanOrEqual(15);

  for (const route of [
    "/insights/child-bypassing-parental-controls",
    "/insights/is-chatgpt-for-homework-cheating",
    "/insights/found-porn-on-child-phone",
    "/insights/how-much-screen-time-is-too-much",
    "/insights/phone-in-bedroom-at-night",
    "/insights/what-age-first-phone",
    "/insights/is-my-child-ready-for-social-media",
    "/insights/child-angry-when-video-games-stop",
    "/insights/should-i-read-my-childs-text-messages",
    "/insights/child-talking-to-strangers-online",
  ]) {
    await page.goto(route);
    await expect(
      page.getByRole("heading", { name: "The next questions usually connect." }),
    ).toBeVisible();
    await expect(page.locator(".article-related .article-card")).toHaveCount(3);

    const hrefs = await page
      .locator(".article-related .article-card")
      .evaluateAll((links) => links.map((link) => link.getAttribute("href")));
    expect(hrefs).not.toContain(route);
  }
});


test("indexable pages have unique descriptive titles and descriptions", async ({
  page,
}) => {
  const indexable = routes.filter((route) => !route.startsWith("/legal/"));
  const titles = new Map<string, string>();

  for (const route of indexable) {
    await page.goto(route);
    const title = await page.title();
    const description = await page
      .locator('meta[name="description"]')
      .getAttribute("content");

    expect(title.length, route + " title").toBeGreaterThan(20);
    expect(title.length, route + " title").toBeLessThan(75);
    expect(description?.length ?? 0, route + " description").toBeGreaterThan(60);
    expect(description?.length ?? 0, route + " description").toBeLessThan(190);
    expect(titles.has(title), "Duplicate title: " + title).toBe(false);
    titles.set(title, route);
  }
});

test("Community articles expose trust and hierarchy signals", async ({ page }) => {
  await page.goto("/insights/what-age-first-phone");

  await expect(
    page.getByRole("link", { name: "Themis Family Editorial Team" }),
  ).toHaveAttribute("href", "/insights/how-we-research");

  const crumbs = page.locator(".breadcrumb a, .breadcrumb-part > span:last-child");
  await expect(crumbs).toHaveCount(3);

  const inlineImages = page.locator(".article-prose img");
  expect(await inlineImages.count()).toBeGreaterThanOrEqual(2);
  for (const image of await inlineImages.all()) {
    await expect(image).toHaveAttribute("loading", "lazy");
    await expect(image).toHaveAttribute("decoding", "async");
  }

  const jsonLd = await page
    .locator('script[type="application/ld+json"]')
    .allTextContents();
  expect(jsonLd.some((value) => value.includes('"Article"'))).toBe(true);
  expect(jsonLd.some((value) => value.includes('"BreadcrumbList"'))).toBe(true);
});

test("research methodology is publicly linked from Community", async ({ page }) => {
  await page.goto("/insights");
  await expect(
    page.getByRole("link", { name: "Read our research and editorial standards." }),
  ).toHaveAttribute("href", "/insights/how-we-research");
  await page.goto("/insights/how-we-research");
  await expect(page.getByRole("heading", { name: "We show our work." })).toBeVisible();
});

test("all internal links resolve", async ({ page, request }) => {
  await page.goto("/");
  const links = await page
    .locator('a[href^="/"]')
    .evaluateAll((els) => [
      ...new Set(els.map((e) => e.getAttribute("href")!)),
    ]);
  for (const link of links)
    expect((await request.get(link)).status(), link).toBeLessThan(400);
});
test("navigation supports keyboard and escape", async ({ page, isMobile }) => {
  await page.goto("/");
  if (isMobile) {
    await page.getByRole("button", { name: "Open navigation" }).click();
    await expect(page.getByRole("dialog")).toBeVisible();
    await page.keyboard.press("Escape");
    await expect(page.getByRole("dialog")).not.toBeVisible();
    await expect(
      page.getByRole("button", { name: "Open navigation" }),
    ).toBeFocused();
  } else {
    const product = page.locator(".desktop-nav summary").first();
    await product.focus();
    await page.keyboard.press("Enter");
    await expect(page.locator(".nav-dropdown").first()).toBeVisible();
    await page.keyboard.press("Escape");
    await expect(product).toBeFocused();
    await expect(page.locator(".nav-dropdown").first()).not.toBeVisible();
  }
});
test("form validation and production unavailable outcome", async ({ page }) => {
  await page.goto("/waitlist");
  await page
    .getByRole("button", { name: "Join the waitlist", exact: true })
    .click();
  await expect(page.getByLabel("First name", { exact: true })).toBeFocused();
  await page.getByLabel("First name", { exact: true }).fill("Test");
  await page
    .getByLabel("Email address", { exact: true })
    .fill("test@example.com");
  await page.getByRole("checkbox").check();
  await page
    .getByRole("button", { name: "Join the waitlist", exact: true })
    .click();
  await expect(page.locator(".form-message[role=alert]")).toContainText(
    "not accepting submissions",
  );
  await expect(page.getByLabel("Email address", { exact: true })).toHaveValue(
    "test@example.com",
  );
});
test("form handles duplicate and network errors accessibly", async ({
  page,
}) => {
  await page.goto("/waitlist");
  await page.getByLabel("First name", { exact: true }).fill("Test");
  await page
    .getByLabel("Email address", { exact: true })
    .fill("test@example.com");
  await page.getByRole("checkbox").check();
  await page.route("**/api/waitlist", (route) => route.abort());
  await page
    .getByRole("button", { name: "Join the waitlist", exact: true })
    .click();
  await expect(page.locator(".form-message[role=alert]")).toContainText(
    "couldn’t connect",
  );
  await page.unroute("**/api/waitlist");
  await page.route("**/api/waitlist", (route) =>
    route.fulfill({
      json: {
        status: "duplicate",
        message: "Already on the demo waitlist.",
        demo: true,
      },
    }),
  );
  await page
    .getByRole("button", { name: "Join the waitlist", exact: true })
    .click();
  await expect(page.getByRole("status")).toContainText("Already on");
});
test("rules and FAQ interactions", async ({ page }) => {
  await page.goto("/rules");
  await page.getByRole("button", { name: "Free Pass", exact: true }).click();
  await expect(page.locator("#rule-preview")).toContainText("20 minutes");
  await page.goto("/faq");
  await page
    .getByText("Does Themis read my child’s messages?", { exact: true })
    .click();
  await expect(page.locator("details[open]")).toContainText(
    "not designed to read",
  );
});
test("reduced motion has a complete fallback", async ({ page }) => {
  await page.emulateMedia({ reducedMotion: "reduce" });
  await page.goto("/");
  await page.waitForTimeout(1000);
  await expect(page.locator(".boundary")).toHaveAttribute(
    "data-scene-state",
    "static",
  );
  await expect(page.locator(".boundary-centre")).toContainText(
    "School access stays available",
  );
  expect(await page.locator("canvas").count()).toBe(0);
});
test("320px, tablet and large desktop", async ({ page }) => {
  for (const width of [320, 768, 1920]) {
    await page.setViewportSize({ width, height: 1000 });
    await page.goto("/");
    await expect(page.locator("h1")).toBeVisible();
    await page.evaluate(() => document.fonts.ready);
    expect(
      await page.evaluate(
        () => document.documentElement.scrollWidth <= innerWidth + 1,
      ),
    ).toBe(true);
  }
});
test("pre-launch legal pages are crawlable but noindex", async ({ page }) => {
  for (const route of [
    "/legal/privacy-policy",
    "/legal/terms",
    "/legal/cookies",
  ]) {
    await page.goto(route);
    await expect(page.locator('meta[name="robots"]')).toHaveAttribute(
      "content",
      /noindex/,
    );
  }
  expect((await page.goto("/not-a-real-page"))?.status()).toBe(404);
});
