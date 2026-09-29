import "server-only";
import { promises as fs } from "node:fs";
import path from "node:path";
import type { WaitlistInput, SupportInput, SubmissionResult } from "./forms";
export interface WaitlistService {
  submit(input: WaitlistInput): Promise<SubmissionResult>;
}
export interface SupportService {
  submit(input: SupportInput): Promise<SubmissionResult>;
}
const unavailable: SubmissionResult = {
  status: "unavailable",
  message: "We’re not accepting submissions just yet. Please check back soon.",
};
let queue = Promise.resolve();
function serial<T>(work: () => Promise<T>): Promise<T> {
  const next = queue.then(work);
  queue = next.then(
    () => undefined,
    () => undefined,
  );
  return next;
}
async function localSubmit(
  kind: "waitlist" | "support",
  input: WaitlistInput | SupportInput,
): Promise<SubmissionResult> {
  return serial(async () => {
    const dir = path.join(process.cwd(), ".local-data");
    await fs.mkdir(dir, { recursive: true });
    const file = path.join(dir, kind + ".json");
    let records: (WaitlistInput | SupportInput)[] = [];
    try {
      records = JSON.parse(await fs.readFile(file, "utf8"));
    } catch (e) {
      if ((e as NodeJS.ErrnoException).code !== "ENOENT") throw e;
    }
    if (kind === "waitlist" && records.some((r) => r.email === input.email))
      return {
        status: "duplicate",
        message:
          "This email is already on the local demo waitlist. No live sign-up has been made.",
        demo: true,
      };
    records.push(input);
    await fs.writeFile(file + ".tmp", JSON.stringify(records, null, 2), {
      mode: 0o600,
    });
    await fs.rename(file + ".tmp", file);
    return {
      status: "success",
      message:
        kind === "waitlist"
          ? "Demo sign-up saved locally. You have not joined a live waitlist."
          : "Demo message saved locally. It has not been sent to support.",
      demo: true,
    };
  });
}
export function submissionsEnabled() {
  return (
    process.env.NODE_ENV === "development" &&
    process.env.FORM_PROVIDER === "local"
  );
}
export const waitlistService: WaitlistService = {
  submit: (input) =>
    submissionsEnabled()
      ? localSubmit("waitlist", input)
      : Promise.resolve(unavailable),
};
export const supportService: SupportService = {
  submit: (input) =>
    submissionsEnabled()
      ? localSubmit("support", input)
      : Promise.resolve(unavailable),
};
