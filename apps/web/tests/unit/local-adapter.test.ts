import { it, expect, vi } from "vitest";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
vi.mock("server-only", () => ({}));
import { waitlistService, supportService } from "../../src/lib/services";
it("persists local submissions and atomically recognises duplicate emails", async () => {
  const temp = await mkdtemp(path.join(tmpdir(), "themis-web-test-"));
  const cwd = vi.spyOn(process, "cwd").mockReturnValue(temp);
  vi.stubEnv("NODE_ENV", "development");
  vi.stubEnv("FORM_PROVIDER", "local");
  try {
    const input = {
      firstName: "Synthetic",
      email: "synthetic@example.com",
      consent: true as const,
    };
    const results = await Promise.all([
      waitlistService.submit(input),
      waitlistService.submit(input),
    ]);
    expect(results.map((r) => r.status).sort()).toEqual([
      "duplicate",
      "success",
    ]);
    expect(results.every((r) => r.demo)).toBe(true);
    expect(
      (
        await supportService.submit({
          name: "Synthetic",
          email: "synthetic@example.com",
          topic: "Setup",
          message: "Synthetic development support test.",
        })
      ).status,
    ).toBe("success");
  } finally {
    cwd.mockRestore();
    vi.unstubAllEnvs();
    if (
      path.dirname(path.resolve(temp)) !== path.resolve(tmpdir()) ||
      !path.basename(temp).startsWith("themis-web-test-")
    )
      throw new Error("Unexpected temporary test path");
    await rm(temp, { recursive: true, force: true });
  }
});
