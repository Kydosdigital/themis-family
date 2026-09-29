import Link from "next/link";
import {
  ArrowRight,
  Check,
  EyeOff,
  MessageCircle,
  MapPin,
  Globe,
  Activity,
  ShieldCheck,
} from "lucide-react";
import { Eyebrow } from "./ui";
import { protectionStates } from "@/lib/content";
export function AgreementStory() {
  return (
    <div className="agreement-story">
      <div className="row story-top">
        <strong>Your family agreement</strong>
        <span className="status-badge">Product preview</span>
      </div>
      {[
        ["Agree the boundary", "Homework completed and approved by 6:00 PM."],
        [
          "Choose what changes",
          "Roblox and Minecraft pause if it isn’t approved.",
        ],
        [
          "Keep the conversation open",
          "See what still works. Ask for more time.",
        ],
      ].map(([title, body], i) => (
        <div className="agreement-step" key={title}>
          <span className="step-dot">
            {i === 2 ? <Check size={14} /> : String(i + 1).padStart(2, "0")}
          </span>
          <div>
            <h3>{title}</h3>
            <p>{body}</p>
          </div>
        </div>
      ))}
    </div>
  );
}
export function PrivacyPanel() {
  return (
    <div className="privacy-panel" data-engagement="privacy">
      <div>
        <Eyebrow>Cooperation, not surveillance</Eyebrow>
        <h2>
          Know what Themis can see.
          <br />
          And what it can’t.
        </h2>
        <p className="lede">
          Clear agreements don’t need a window into every private moment.
        </p>
        <Link href="/privacy" className="text-link">
          Our approach to privacy <ArrowRight size={17} />
        </Link>
      </div>
      <div>
        <p className="small" style={{ marginBottom: 15 }}>
          Themis is not designed to provide:
        </p>
        <ul className="privacy-list">
          {[
            [MessageCircle, "Private message contents"],
            [Globe, "A full browsing diary"],
            [MapPin, "Continuous location tracking"],
            [Activity, "Minute-by-minute surveillance"],
          ].map(([Icon, title]) => {
            const I = Icon as typeof EyeOff;
            return (
              <li key={String(title)}>
                <I size={18} />
                {String(title)}
              </li>
            );
          })}
        </ul>
      </div>
    </div>
  );
}
export function ProtectionStates() {
  return (
    <div className="status-list">
      <p className="small">
        Illustrative status explanations — not live device information.
      </p>
      {protectionStates.map((s) => (
        <div className="status-row" key={s.label}>
          <div>
            <span className={`status-badge ${s.tone}`}>
              <ShieldCheck size={14} />
              {s.label}
            </span>
          </div>
          <p>{s.description}</p>
        </div>
      ))}
    </div>
  );
}
