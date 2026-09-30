"use client";
import { useEffect, useState, type ComponentType, type ReactNode } from "react";

// Keep the complete server-rendered content visible while desktop-only
// enhancements load. Touch devices never request the animation module.
export function Reveal({ children }: { children: ReactNode }) {
  const [Animated, setAnimated] = useState<ComponentType<{
    children: ReactNode;
  }> | null>(null);
  useEffect(() => {
    const query = matchMedia(
      "(pointer: fine) and (prefers-reduced-motion: no-preference)",
    );
    let cancelled = false;
    if (query.matches) {
      import("./reveal-motion")
        .then((module) => {
          if (!cancelled) setAnimated(() => module.default);
        })
        .catch(() => {
          /* The static content remains fully usable. */
        });
    }
    return () => {
      cancelled = true;
    };
  }, []);
  return Animated ? <Animated>{children}</Animated> : <div>{children}</div>;
}
