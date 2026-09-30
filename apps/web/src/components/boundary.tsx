"use client";
import dynamic from "next/dynamic";
import { Component, useEffect, useRef, useState, type ReactNode } from "react";
import {
  BookOpen,
  Gamepad2,
  MessageCircle,
  GraduationCap,
  Check,
} from "lucide-react";
const Scene = dynamic(() => import("./boundary-scene"), {
  ssr: false,
  loading: () => null,
});
class SceneError extends Component<
  { children: ReactNode; onFail: () => void },
  { failed: boolean }
> {
  state = { failed: false };
  static getDerivedStateFromError() {
    return { failed: true };
  }
  componentDidCatch() {
    this.props.onFail();
  }
  render() {
    return this.state.failed ? null : this.props.children;
  }
}
export function Boundary({ walkthrough = false }: { walkthrough?: boolean }) {
  const host = useRef<HTMLDivElement>(null);
  const manuallySelected = useRef(false);
  const [enabled, setEnabled] = useState(false),
    [visible, setVisible] = useState(false),
    [ready, setReady] = useState(false),
    [failed, setFailed] = useState(false),
    [progress, setProgress] = useState(0),
    [reduced, setReduced] = useState(false);
  useEffect(() => {
    const preference = matchMedia("(prefers-reduced-motion: reduce)");
    const low = navigator as Navigator & {
      deviceMemory?: number;
      connection?: { saveData?: boolean };
    };
    const capable =
      !low.connection?.saveData &&
      (low.deviceMemory === undefined || low.deviceMemory >= 4) &&
      navigator.hardwareConcurrency >= 4 &&
      matchMedia("(pointer: fine)").matches;
    const change = () => {
      setReduced(preference.matches);
      if (!manuallySelected.current) setEnabled(capable && !preference.matches);
    };
    const timer = setTimeout(change, 700);
    preference.addEventListener("change", change);
    const observer = new IntersectionObserver(
      ([entry]) => setVisible(entry.isIntersecting && !document.hidden),
      { rootMargin: "100px" },
    );
    if (host.current) observer.observe(host.current);
    const visibility = () =>
      setVisible(
        !document.hidden &&
          !!host.current &&
          host.current.getBoundingClientRect().bottom > 0 &&
          host.current.getBoundingClientRect().top < innerHeight,
      );
    const scroll = () => {
      // Static mobile artwork does not need React updates on every scroll.
      if (!host.current || !enabled) return;
      const top = host.current.getBoundingClientRect().top;
      const story = host.current.closest(".walkthrough");
      if (walkthrough && story && innerWidth > 850) {
        const rect = story.getBoundingClientRect();
        setProgress(
          Math.min(
            1,
            Math.max(0, (120 - rect.top) / (rect.height - innerHeight)),
          ),
        );
        return;
      }
      setProgress(
        Math.min(
          1,
          Math.max(0, (innerHeight * 0.5 - top) / (innerHeight * 0.7)),
        ),
      );
    };
    document.addEventListener("visibilitychange", visibility);
    window.addEventListener("scroll", scroll, { passive: true });
    scroll();
    return () => {
      clearTimeout(timer);
      preference.removeEventListener("change", change);
      observer.disconnect();
      document.removeEventListener("visibilitychange", visibility);
      window.removeEventListener("scroll", scroll);
    };
  }, [walkthrough, enabled]);
  useEffect(() => {
    if (!enabled) return;
    try {
      const canvas = document.createElement("canvas");
      const context = canvas.getContext("webgl2");
      if (!context) {
        queueMicrotask(() => setFailed(true));
        return;
      }
      context.getExtension("WEBGL_lose_context")?.loseContext();
    } catch {
      queueMicrotask(() => setFailed(true));
    }
  }, [enabled]);
  return (
    <div
      className={`boundary ${ready && enabled ? "webgl-ready" : ""} ${progress > 0.6 && enabled && !reduced ? "boundary-settled" : ""}`}
      ref={host}
      data-scene-state={
        failed ? "fallback" : enabled && ready ? "webgl" : "static"
      }
      data-scene-active={visible && enabled && !failed}
    >
      <div className="boundary-static" aria-hidden="true">
        <div className="boundary-orbit" />
        <div className="boundary-tile games">
          <Gamepad2 />
          <span>Games</span>
        </div>
        <div className="boundary-tile social">
          <MessageCircle />
          <span>Social</span>
        </div>
        <div className="boundary-tile homework">
          <BookOpen />
          <span>Homework</span>
        </div>
        <div className="boundary-tile school">
          <GraduationCap />
          <span>School</span>
        </div>
      </div>
      <p className="boundary-label">
        {walkthrough
          ? "One agreement. Clearly understood."
          : "A little structure. A lot more space."}
      </p>
      {enabled && !failed && (
        <SceneError onFail={() => setFailed(true)}>
          <Scene
            progress={progress}
            active={visible}
            onReady={() => setReady(true)}
            onFail={() => setFailed(true)}
          />
        </SceneError>
      )}
      <div className="boundary-centre">
        <div className="boundary-phone-header" aria-hidden="true">
          <span>themis family</span>
          <span>6:00 PM</span>
        </div>
        <div className="row">
          <strong>
            {progress > 0.6
              ? "The agreement is clear."
              : "Homework first. Games later."}
          </strong>
          <Check size={17} color="var(--cobalt)" />
        </div>
        <p className="small">
          6:00 PM · Games pause until approved
          <br />
          School access stays available.
        </p>
        <div className="boundary-phone-detail" aria-hidden="true">
          <span>
            Games & social <strong>Paused</strong>
          </span>
          <span>
            School & homework <strong>Available</strong>
          </span>
          <span className="boundary-request">Ask for more time →</span>
        </div>
      </div>
      <p className="scene-status">Interactive concept · Product preview</p>
      <button
        className="motion-control"
        onClick={() => {
          manuallySelected.current = true;
          setEnabled((v) => !v);
          setFailed(false);
        }}
        aria-pressed={enabled && !failed}
      >
        {enabled && !failed ? "Pause motion" : "Enable motion"}
        {reduced ? " · reduced motion" : ""}
      </button>
      <p className="sr-only">
        A family agreement organises games and social apps into paused states.
        Homework and school remain available. This illustration is not live
        protection status.
      </p>
    </div>
  );
}
