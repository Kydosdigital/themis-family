import { ImageResponse } from "next/og";
export const alt =
  "Themis Family — Clear digital boundaries without the daily arguments.";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
export default function Image() {
  return new ImageResponse(
    <div
      style={{
        background: "#f6f7f9",
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        padding: 80,
        color: "#182b35",
      }}
    >
      <div style={{ fontSize: 35, marginBottom: 70 }}>themis family</div>
      <div
        style={{
          fontSize: 70,
          fontWeight: 600,
          lineHeight: 1.08,
          letterSpacing: -3,
        }}
      >
        Clear digital boundaries.
      </div>
      <div
        style={{
          fontSize: 70,
          fontWeight: 600,
          lineHeight: 1.08,
          letterSpacing: -3,
          color: "#2563eb",
        }}
      >
        Without the daily arguments.
      </div>
      <div style={{ fontSize: 25, marginTop: 50 }}>
        iPhone and iPad first. Coming soon.
      </div>
    </div>,
    size,
  );
}
