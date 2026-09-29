import { test, expect } from "@playwright/test";
test("WebGL renders, settles, pauses off-screen and survives context loss", async ({
  page,
}) => {
  await page.emulateMedia({ reducedMotion: "no-preference" });
  await page.goto("/");
  await expect(page.locator("h1")).toBeVisible();
  const toggle = page.getByRole("button", { name: /motion/ });
  if ((await toggle.getAttribute("aria-pressed")) === "false")
    await toggle.click();
  await expect(page.locator(".boundary")).toHaveAttribute(
    "data-scene-state",
    "webgl",
    { timeout: 20000 },
  );
  await page.waitForTimeout(2200);
  const canvas = page.locator("canvas");
  const frames = await canvas.getAttribute("data-frames");
  await page.waitForTimeout(500);
  expect(await canvas.getAttribute("data-frames")).toBe(frames);
  await page.evaluate(() => window.scrollTo(0, 1800));
  await expect(page.locator(".boundary")).toHaveAttribute(
    "data-scene-active",
    "false",
  );
  await page.waitForTimeout(250);
  const offscreen = await canvas.getAttribute("data-frames");
  await page.waitForTimeout(400);
  expect(await canvas.getAttribute("data-frames")).toBe(offscreen);
  await page.evaluate(() => window.scrollTo(0, 0));
  await canvas.evaluate((el) =>
    (el as HTMLCanvasElement)
      .getContext("webgl2")
      ?.getExtension("WEBGL_lose_context")
      ?.loseContext(),
  );
  await expect(page.locator(".boundary")).toHaveAttribute(
    "data-scene-state",
    "fallback",
  );
  await expect(page.locator(".boundary-centre")).toBeVisible();
});
test("unavailable WebGL retains the readable illustration", async ({
  page,
}) => {
  await page.addInitScript(() => {
    const original = HTMLCanvasElement.prototype.getContext;
    HTMLCanvasElement.prototype.getContext = function (
      this: HTMLCanvasElement,
      type: string,
      ...args: unknown[]
    ) {
      if (type === "webgl2" || type === "webgl") return null;
      return original.apply(this, [type, ...args] as Parameters<
        typeof original
      >);
    } as typeof original;
  });
  await page.goto("/");
  await expect(page.locator("h1")).toBeVisible();
  await page.getByRole("button", { name: /motion/ }).click();
  await expect(page.locator(".boundary")).toHaveAttribute(
    "data-scene-state",
    "fallback",
  );
  await expect(page.locator(".boundary-centre")).toContainText(
    "School access stays available",
  );
});
test("support input, rate limit feedback and request loading", async ({
  page,
}) => {
  await page.goto("/support");
  await page.getByLabel("Your name", { exact: true }).fill("Synthetic Test");
  await page
    .getByLabel("Email address", { exact: true })
    .fill("synthetic@example.com");
  await page
    .getByLabel("Your message", { exact: true })
    .fill("A synthetic support request for testing.");
  let release: () => void = () => {};
  const pending = new Promise<void>((resolve) => {
    release = resolve;
  });
  await page.route("**/api/support", async (route) => {
    await pending;
    await route.fulfill({
      status: 429,
      json: {
        status: "rate_limited",
        message: "Please wait a minute before trying again.",
      },
    });
  });
  await page.getByRole("button", { name: "Send message" }).click();
  await expect(page.getByRole("button", { name: "Saving…" })).toBeDisabled();
  release();
  await expect(page.locator(".form-message")).toContainText("wait a minute");
});
