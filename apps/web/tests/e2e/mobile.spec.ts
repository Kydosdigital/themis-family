import { test, expect } from "@playwright/test";

test.describe("Mobile ergonomics", () => {
  test.beforeEach(({ isMobile }) =>
    test.skip(!isMobile, "Touch layout checks"),
  );

  for (const width of [320, 375, 390, 430]) {
    test(`readable layout and touch targets at ${width}px`, async ({
      page,
    }) => {
      await page.setViewportSize({ width, height: 844 });
      await page.goto("/");
      await page.evaluate(() => document.fonts.ready);
      for (const selector of [
        ".header-cta",
        ".menu-trigger",
        ".hero .button",
        ".footer-grid a",
        ".text-link",
      ]) {
        for (const target of await page.locator(selector).all()) {
          const rect = await target.boundingBox();
          expect(rect?.height, selector).toBeGreaterThanOrEqual(44);
          expect(rect!.x + rect!.width, selector).toBeLessThanOrEqual(
            width + 1,
          );
        }
      }
      const primary = await page.locator(".hero .button").first().boundingBox();
      expect(primary!.y + primary!.height).toBeLessThan(650);
      await expect(page.locator(".boundary")).toHaveAttribute(
        "data-scene-state",
        "static",
      );
      await expect(page.locator(".boundary canvas")).toHaveCount(0);
      const font = await page
        .locator(".boundary-centre .small")
        .evaluate((el) => parseFloat(getComputedStyle(el).fontSize));
      expect(font).toBeGreaterThanOrEqual(12);
      for (const card of await page.locator(".experience-card").all()) {
        const phone = await card.locator(".phone").boundingBox();
        const outer = await card.boundingBox();
        expect(phone!.x).toBeGreaterThanOrEqual(outer!.x);
        expect(phone!.x + phone!.width).toBeLessThanOrEqual(
          outer!.x + outer!.width,
        );
      }
      expect(
        await page.evaluate(() => document.documentElement.scrollWidth),
      ).toBeLessThanOrEqual(width);
      await page.screenshot({ path: `test-results/mobile-home-${width}.png` });
    });
  }

  test("menu stays dismissible when scrolled and restores the page", async ({
    page,
  }) => {
    await page.goto("/");
    await page.getByRole("button", { name: "Open navigation" }).click();
    const menu = page.getByRole("dialog", { name: "Site navigation" });
    await menu.evaluate((el) => (el.scrollTop = el.scrollHeight));
    const close = page.getByRole("button", { name: "Close navigation" });
    await expect(close).toBeInViewport();
    await close.click();
    await expect(menu).not.toBeVisible();
    await expect(
      page.getByRole("button", { name: "Open navigation" }),
    ).toBeFocused();
    expect(await page.evaluate(() => document.body.style.overflow)).toBe("");
  });

  test("forms use readable input text without suppressing pinch zoom", async ({
    page,
  }) => {
    for (const route of ["/waitlist", "/support"]) {
      await page.goto(route);
      for (const input of await page
        .locator(".form-field input, .form-field select, .form-field textarea")
        .all()) {
        expect(
          await input.evaluate((el) =>
            parseFloat(getComputedStyle(el).fontSize),
          ),
        ).toBeGreaterThanOrEqual(16);
      }
      const viewport = await page
        .locator('meta[name="viewport"]')
        .getAttribute("content");
      expect(viewport).not.toMatch(/user-scalable=no|maximum-scale=1/);
    }
  });

  test("key journeys fit a small phone and landscape", async ({ page }) => {
    for (const viewport of [
      { width: 320, height: 740 },
      { width: 844, height: 390 },
    ]) {
      await page.setViewportSize(viewport);
      for (const route of [
        "/how-it-works",
        "/rules",
        "/for-parents",
        "/for-children",
        "/for-teens",
        "/waitlist",
        "/support",
        "/download",
      ]) {
        await page.goto(route);
        await expect(page.locator("h1")).toBeVisible();
        await page.evaluate(() => document.fonts.ready);
        expect(
          await page.evaluate(() => document.documentElement.scrollWidth),
          route,
        ).toBeLessThanOrEqual(viewport.width);
      }
    }
  });
});
