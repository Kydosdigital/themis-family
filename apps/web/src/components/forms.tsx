"use client";
import { useRef, useState } from "react";
import Link from "next/link";
import { ArrowUpRight, Check } from "lucide-react";
import {
  waitlistSchema,
  supportSchema,
  type SubmissionResult,
} from "@/lib/forms";
import { track } from "./analytics";
export function ContactForm({
  kind = "waitlist",
  demo = false,
}: {
  kind?: "waitlist" | "support";
  demo?: boolean;
}) {
  const waitlist = kind === "waitlist";
  const [busy, setBusy] = useState(false),
    [result, setResult] = useState<SubmissionResult | null>(null),
    [errors, setErrors] = useState<Record<string, string>>({});
  const status = useRef<HTMLDivElement>(null);
  async function submit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (busy) return;
    const form = e.currentTarget;
    const data = Object.fromEntries(new FormData(form));
    const input = waitlist ? { ...data, consent: data.consent === "on" } : data;
    const parsed = (waitlist ? waitlistSchema : supportSchema).safeParse(input);
    if (!parsed.success) {
      const next = Object.fromEntries(
        parsed.error.issues.map((i) => [String(i.path[0]), i.message]),
      );
      setErrors(next);
      setResult(null);
      setTimeout(
        () => form.querySelector<HTMLElement>("[aria-invalid=true]")?.focus(),
        0,
      );
      return;
    }
    setErrors({});
    setBusy(true);
    setResult(null);
    try {
      const response = await fetch("/api/" + kind, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(parsed.data),
      });
      const answer = (await response.json()) as SubmissionResult;
      setResult(answer);
      setErrors(answer.errors || {});
      track(waitlist ? "waitlist_submit" : "support_submit", {
        outcome: answer.status,
      });
    } catch {
      setResult({
        status: "unavailable",
        message:
          "We couldn’t connect. Check your connection and try again. Your answers are still here.",
      });
    } finally {
      setBusy(false);
      setTimeout(() => status.current?.focus(), 0);
    }
  }
  function field(name: string, label: string, type = "text", required = false) {
    return (
      <div className="form-field">
        <label htmlFor={kind + "-" + name}>
          {label}
          {!required && " (optional)"}
        </label>
        <input
          id={kind + "-" + name}
          name={name}
          type={type}
          required={required}
          maxLength={type === "email" ? 254 : 100}
          autoComplete={
            name === "email" ? "email" : waitlist ? "given-name" : "name"
          }
          aria-invalid={!!errors[name]}
          aria-describedby={
            errors[name] ? kind + "-" + name + "-error" : undefined
          }
        />
        {errors[name] && (
          <span className="field-error" id={kind + "-" + name + "-error"}>
            {errors[name]}
          </span>
        )}
      </div>
    );
  }
  const done = result?.status === "success" || result?.status === "duplicate";
  return (
    <div className="form-panel">
      <h2>{waitlist ? "A calmer routine starts here." : "How can we help?"}</h2>
      <p>
        {waitlist
          ? "Leave your email. We’ll let you know when Themis is ready."
          : "Tell us about the Themis issue you need help with."}
      </p>
      {demo && (
        <p className="form-notice">
          Development demo — submissions stay on this computer and are not sent
          to Themis.
        </p>
      )}
      {!done && (
        <form onSubmit={submit} noValidate className="form-grid">
          {field(
            waitlist ? "firstName" : "name",
            waitlist ? "First name" : "Your name",
            "text",
            true,
          )}
          {field("email", "Email address", "email", true)}
          {waitlist ? (
            <>
              <div className="two-grid">
                <div className="form-field">
                  <label htmlFor="childCount">
                    Number of children (optional)
                  </label>
                  <select id="childCount" name="childCount">
                    <option value="">Prefer not to say</option>
                    {["1", "2", "3", "4+"].map((v) => (
                      <option key={v}>{v}</option>
                    ))}
                  </select>
                </div>
                <div className="form-field">
                  <label htmlFor="ageBand">Age band (optional)</label>
                  <select id="ageBand" name="ageBand">
                    <option value="">Prefer not to say</option>
                    {["8–12", "13–15", "Both", "Other"].map((v) => (
                      <option key={v}>{v}</option>
                    ))}
                  </select>
                </div>
              </div>
              <div className="form-field">
                <label htmlFor="challenge">
                  Your biggest digital-boundary challenge (optional)
                </label>
                <textarea
                  id="challenge"
                  name="challenge"
                  maxLength={500}
                  aria-invalid={!!errors.challenge}
                  aria-describedby="challenge-help challenge-error"
                />
                <small id="challenge-help">
                  Please don’t include children’s names or sensitive
                  information. Maximum 500 characters.
                </small>
                <span id="challenge-error" className="field-error">
                  {errors.challenge}
                </span>
              </div>
              <label className="consent">
                <input
                  type="checkbox"
                  name="consent"
                  required
                  aria-invalid={!!errors.consent}
                  aria-describedby={
                    errors.consent ? "consent-error" : undefined
                  }
                />
                <span>
                  I’d like to receive Themis Family launch updates. I can
                  unsubscribe from live updates at any time. Read our{" "}
                  <Link href="/legal/privacy-policy">draft privacy policy</Link>
                  .
                </span>
              </label>
              {errors.consent && (
                <p className="field-error" id="consent-error">
                  {errors.consent}
                </p>
              )}
            </>
          ) : (
            <>
              <div className="form-field">
                <label htmlFor="topic">Topic</label>
                <select id="topic" name="topic">
                  {[
                    "Setup",
                    "Pairing",
                    "Rules",
                    "Approvals",
                    "Requests",
                    "Protection status",
                    "Subscriptions",
                    "Privacy",
                    "Other",
                  ].map((v) => (
                    <option key={v}>{v}</option>
                  ))}
                </select>
              </div>
              <div className="form-field">
                <label htmlFor="message">Your message</label>
                <textarea
                  id="message"
                  name="message"
                  minLength={10}
                  maxLength={2000}
                  required
                  aria-invalid={!!errors.message}
                  aria-describedby="message-help message-error"
                />
                <small id="message-help">
                  Don’t include passwords, payment details or sensitive
                  information about a child.
                </small>
                <span id="message-error" className="field-error">
                  {errors.message}
                </span>
              </div>
            </>
          )}
          <button type="submit" className="button" disabled={busy}>
            {busy ? "Saving…" : waitlist ? "Join the waitlist" : "Send message"}
            <ArrowUpRight size={18} />
          </button>
          <p className="small">
            Pre-launch: live submissions open when our service and privacy
            information are ready.
          </p>
        </form>
      )}
      {result && (
        <div
          ref={status}
          tabIndex={-1}
          role={done ? "status" : "alert"}
          className={`form-message ${done ? "" : "error"}`}
          style={{ marginTop: 25 }}
        >
          {done && <Check size={20} />}
          <p>{result.message}</p>
        </div>
      )}
    </div>
  );
}
