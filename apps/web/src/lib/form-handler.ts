import { NextResponse } from "next/server";
import { waitlistSchema, supportSchema, type SubmissionResult } from "./forms";
import {
  waitlistService,
  supportService,
  submissionsEnabled,
} from "./services";
const attempts = new Map<string, { count: number; until: number }>();
export async function handleForm(
  request: Request,
  kind: "waitlist" | "support",
) {
  const origin = request.headers.get("origin");
  const target = new URL(request.url);
  // Next may reconstruct the local request URL with localhost while the browser
  // uses 127.0.0.1. Permit only the actual local Host, never arbitrary forwarded hosts.
  const host = request.headers.get("host");
  const localOrigin =
    host && /^(localhost|127\.0\.0\.1)(:\d+)?$/.test(host)
      ? target.protocol + "//" + host
      : target.origin;
  const allowed = process.env.NEXT_PUBLIC_SITE_URL
    ? new URL(process.env.NEXT_PUBLIC_SITE_URL).origin
    : localOrigin;
  if (!origin || origin !== allowed)
    return NextResponse.json(
      {
        status: "validation",
        message: "Please submit this form from the Themis website.",
      },
      { status: 403 },
    );
  if (!request.headers.get("content-type")?.startsWith("application/json"))
    return NextResponse.json(
      { status: "validation", message: "Expected a JSON submission." },
      { status: 415 },
    );
  if (Number(request.headers.get("content-length") || 0) > 12000)
    return NextResponse.json(
      { status: "validation", message: "Your message is too long." },
      { status: 413 },
    );
  // Local development only. A live provider MUST supply durable rate limiting before activation.
  if (submissionsEnabled()) {
    const key =
      kind +
      ":" +
      (request.headers.get("x-forwarded-for")?.split(",")[0] || "local");
    const now = Date.now();
    for (const [k, v] of attempts) if (v.until < now) attempts.delete(k);
    const item = attempts.get(key) || { count: 0, until: now + 60000 };
    item.count++;
    attempts.set(key, item);
    if (item.count > 10)
      return NextResponse.json(
        {
          status: "rate_limited",
          message: "Please wait a minute before trying again.",
        },
        { status: 429, headers: { "Retry-After": "60" } },
      );
  }
  try {
    const raw = await request.text();
    if (raw.length > 12000)
      return NextResponse.json(
        { status: "validation", message: "Your message is too long." },
        { status: 413 },
      );
    let input: unknown;
    try {
      input = JSON.parse(raw);
    } catch {
      return NextResponse.json(
        {
          status: "validation",
          message: "We couldn’t read the form. Please try again.",
        },
        { status: 400 },
      );
    }
    const schema = kind === "waitlist" ? waitlistSchema : supportSchema;
    const parsed = schema.safeParse(input);
    if (!parsed.success) {
      const errors = Object.fromEntries(
        parsed.error.issues.map((i) => [String(i.path[0]), i.message]),
      );
      return NextResponse.json(
        {
          status: "validation",
          message: "Please check the highlighted fields.",
          errors,
        },
        { status: 400 },
      );
    }
    const result: SubmissionResult =
      kind === "waitlist"
        ? await waitlistService.submit(waitlistSchema.parse(input))
        : await supportService.submit(supportSchema.parse(input));
    return NextResponse.json(result, {
      status: result.status === "unavailable" ? 503 : 200,
      headers: { "Cache-Control": "no-store" },
    });
  } catch {
    return NextResponse.json(
      {
        status: "unavailable",
        message: "We couldn’t save your submission. Please try again later.",
      },
      { status: 503 },
    );
  }
}
