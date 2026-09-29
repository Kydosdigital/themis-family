import { describe, it, expect, vi, afterEach } from "vitest";
vi.mock("server-only", () => ({}));
import { handleForm } from "../../src/lib/form-handler";
afterEach(() => vi.unstubAllEnvs());
function request(body: unknown, origin = "http://localhost:3000") {
  return new Request("http://localhost:3000/api/waitlist", {
    method: "POST",
    headers: { "content-type": "application/json", origin },
    body: JSON.stringify(body),
  });
}
describe("form boundary", () => {
  it("rejects cross-origin requests", async () =>
    expect(
      (await handleForm(request({}, "https://other.example"), "waitlist"))
        .status,
    ).toBe(403));
  it("returns field errors for invalid email and consent", async () => {
    const r = await handleForm(
      request({ firstName: "Alex", email: "bad", consent: false }),
      "waitlist",
    );
    expect(r.status).toBe(400);
    expect((await r.json()).errors).toHaveProperty("email");
  });
  it("rejects oversized bodies", async () =>
    expect(
      (await handleForm(request({ challenge: "x".repeat(13000) }), "waitlist"))
        .status,
    ).toBe(413));
  it("rejects unsupported media types", async () =>
    expect(
      (
        await handleForm(
          new Request("http://localhost:3000/api/support", {
            method: "POST",
            headers: {
              origin: "http://localhost:3000",
              "content-type": "text/plain",
            },
            body: "test",
          }),
          "support",
        )
      ).status,
    ).toBe(415));
  it("fails closed with no production backend", async () => {
    vi.stubEnv("NODE_ENV", "production");
    vi.stubEnv("FORM_PROVIDER", "local");
    const r = await handleForm(
      request({ firstName: "Alex", email: "alex@example.com", consent: true }),
      "waitlist",
    );
    expect(r.status).toBe(503);
    expect((await r.json()).status).toBe("unavailable");
  });
});
