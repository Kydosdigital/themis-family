import { z } from "zod";
const text = (max: number) =>
  z
    .string()
    .trim()
    .max(max)
    .refine((v) => !/[<>\u0000-\u0008]/.test(v), "Please use plain text.");
export const waitlistSchema = z.object({
  firstName: text(60).pipe(z.string().min(1, "Enter your first name.")),
  email: z
    .string()
    .trim()
    .toLowerCase()
    .email("Enter a valid email address.")
    .max(254),
  childCount: z.enum(["", "1", "2", "3", "4+"]).optional(),
  ageBand: z.enum(["", "8–12", "13–15", "Both", "Other"]).optional(),
  challenge: text(500).optional(),
  consent: z.literal(true, {
    error: "Please agree to receive launch updates.",
  }),
});
export const supportSchema = z.object({
  name: text(100).pipe(z.string().min(1, "Enter your name.")),
  email: z
    .string()
    .trim()
    .toLowerCase()
    .email("Enter a valid email address.")
    .max(254),
  topic: z.enum([
    "Setup",
    "Pairing",
    "Rules",
    "Approvals",
    "Requests",
    "Protection status",
    "Subscriptions",
    "Privacy",
    "Other",
  ]),
  message: text(2000).pipe(
    z.string().min(10, "Tell us a little more (at least 10 characters)."),
  ),
});
export type WaitlistInput = z.infer<typeof waitlistSchema>;
export type SupportInput = z.infer<typeof supportSchema>;
export type SubmissionResult = {
  status:
    "success" | "duplicate" | "validation" | "rate_limited" | "unavailable";
  message: string;
  errors?: Record<string, string>;
  demo?: boolean;
};
