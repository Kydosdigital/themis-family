"use client";
export default function ErrorPage({ reset }: { reset: () => void }) {
  return (
    <div className="container section">
      <p className="eyebrow">Something went wrong</p>
      <h1>Let’s try that again.</h1>
      <p className="lede">
        We couldn’t load this page. Your family’s settings are not affected by
        this website.
      </p>
      <button className="button" style={{ marginTop: 30 }} onClick={reset}>
        Try again
      </button>
    </div>
  );
}
