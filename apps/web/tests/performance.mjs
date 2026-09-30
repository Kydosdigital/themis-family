import lighthouse from "lighthouse";
import { launch } from "chrome-launcher";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
await mkdir("lighthouse-results/chrome-profile", { recursive: true });
const chrome = await launch({
  chromePath: process.env.CHROME_PATH,
  userDataDir: path.resolve("lighthouse-results/chrome-profile"),
  chromeFlags: ["--headless", "--no-sandbox", "--disable-dev-shm-usage"],
});
await mkdir("lighthouse-results", { recursive: true });
try {
  for (const route of ["/", "/privacy", "/waitlist"]) {
    const result = await lighthouse(
      (process.env.SITE_URL || "http://127.0.0.1:3000") + route,
      {
        port: chrome.port,
        output: "json",
        onlyCategories: [
          "performance",
          "accessibility",
          "best-practices",
          "seo",
        ],
        logLevel: "error",
      },
    );
    if (!result) throw new Error("No Lighthouse result");
    const name = route === "/" ? "home" : route.slice(1);
    await writeFile(
      "lighthouse-results/" + name + ".json",
      JSON.stringify(result.lhr, null, 2),
    );
    console.log(
      JSON.stringify({
        route,
        scores: Object.fromEntries(
          Object.entries(result.lhr.categories).map(([k, v]) => [k, v.score]),
        ),
        lcp: result.lhr.audits["largest-contentful-paint"].numericValue,
        cls: result.lhr.audits["cumulative-layout-shift"].numericValue,
        tbt: result.lhr.audits["total-blocking-time"].numericValue,
        bytes: result.lhr.audits["total-byte-weight"].numericValue,
      }),
    );
  }
} finally {
  await chrome.kill();
}
