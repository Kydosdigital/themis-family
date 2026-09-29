import { describe, it, expect, vi, afterEach } from "vitest";
import { waitlistSchema, supportSchema } from "../../src/lib/forms";
vi.mock("server-only", () => ({}));
import { waitlistService, supportService } from "../../src/lib/services";
const valid = {
  firstName: " Alex ",
  email: " ALEX@EXAMPLE.COM ",
  consent: true,
};
afterEach(() => vi.unstubAllEnvs());
describe("submission validation", () => {
  it("normalises an adult's name and email", () =>
    expect(waitlistSchema.parse(valid)).toMatchObject({
      firstName: "Alex",
      email: "alex@example.com",
    }));
  it.each([
    { ...valid, consent: false },
    { ...valid, email: "bad" },
    { ...valid, firstName: "" },
    { ...valid, challenge: "<script>alert(1)</script>" },
    { ...valid, challenge: "a".repeat(501) },
  ])("rejects invalid or unsafe input %#", (data) =>
    expect(waitlistSchema.safeParse(data).success).toBe(false),
  );
  it("strips unexpected fields including child identifiers", () =>
    expect(
      waitlistSchema.parse({ ...valid, childName: "private" }),
    ).not.toHaveProperty("childName"));
  it("rejects empty and oversized support messages", () => {
    for (const message of ["", "a".repeat(2001)])
      expect(
        supportSchema.safeParse({
          name: "Alex",
          email: "a@example.com",
          topic: "Setup",
          message,
        }).success,
      ).toBe(false);
  });
  it("never uses a local provider in production", async () => {
    vi.stubEnv("NODE_ENV", "production");
    vi.stubEnv("FORM_PROVIDER", "local");
    expect(
      (await waitlistService.submit(waitlistSchema.parse(valid))).status,
    ).toBe("unavailable");
    expect(
      (
        await supportService.submit({
          name: "Alex",
          email: "a@example.com",
          topic: "Setup",
          message: "Test support enquiry.",
        })
      ).status,
    ).toBe("unavailable");
  });
});
