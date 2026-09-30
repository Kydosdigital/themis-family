"use client";
import { motion, useReducedMotion } from "motion/react";
import type { ReactNode } from "react";
export default function RevealMotion({ children }: { children: ReactNode }) {
  const reduced = useReducedMotion();
  return (
    <motion.div
      initial={false}
      whileInView={reduced ? {} : { y: [12, 0] }}
      viewport={{ once: true, amount: 0.1 }}
      transition={{ duration: 0.6 }}
    >
      {children}
    </motion.div>
  );
}
