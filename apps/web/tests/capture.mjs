import { chromium } from "@playwright/test";
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 320, height: 1000 } });
await page.goto("http://127.0.0.1:3000");
await page.locator("h1").waitFor();
await page.evaluate(() => document.fonts.ready);
console.log(
  await page.evaluate(() =>
    [...document.querySelectorAll("body *")]
      .filter((e) => e.getBoundingClientRect().right > innerWidth + 1)
      .map((e) => ({
        tag: e.tagName,
        cls: e.className,
        width: e.getBoundingClientRect().width,
        right: e.getBoundingClientRect().right,
      }))
      .slice(0, 30),
  ),
);
await page.screenshot({ path: "test-results/home-320.png" });
await page.setViewportSize({ width: 1440, height: 1000 });
await page.goto("http://127.0.0.1:3000");
await page.locator("h1").waitFor();
await page.waitForTimeout(2000);
await page.screenshot({ path: "test-results/home-desktop.png" });
console.log(
  "scene",
  await page.locator(".boundary").getAttribute("data-scene-state"),
);
await browser.close();
