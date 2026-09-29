"use client";
import { useState } from "react";
import { rules } from "@/lib/content";
import { Clock, ArrowRight } from "lucide-react";
export function RuleDemo() {
  const [active, setActive] = useState(0);
  const rule = rules[active];
  return (
    <div>
      <div
        className="rules-tabs"
        role="group"
        aria-label="Explore family agreements"
      >
        {rules.map((r, i) => (
          <button
            key={r.title}
            aria-pressed={active === i}
            aria-controls="rule-preview"
            onClick={() => setActive(i)}
          >
            {r.title}
          </button>
        ))}
      </div>
      <div className="rule-demo" id="rule-preview" aria-live="polite">
        <div>
          <p className="eyebrow">{rule.kind}</p>
          <h3>{rule.description}</h3>
          <p>{rule.detail}</p>
        </div>
        <div className="rule-preview">
          <div className="row">
            <span className="small">Example agreement</span>
            <span className="small">Product preview</span>
          </div>
          <h4>{rule.title}</h4>
          <div
            className="row"
            style={{ justifyContent: "start", fontSize: 14, marginBottom: 20 }}
          >
            <Clock size={18} />
            {rule.time}
          </div>
          <span className="status-badge">{rule.state}</span>
          <div className="mini-line">
            <span />
          </div>
          <p style={{ marginTop: 20 }}>{rule.outcome}</p>
          <div
            className="row"
            style={{ marginTop: 20, fontSize: 12, color: "var(--cobalt)" }}
          >
            Visible to the whole family
            <ArrowRight size={16} />
          </div>
        </div>
      </div>
    </div>
  );
}
