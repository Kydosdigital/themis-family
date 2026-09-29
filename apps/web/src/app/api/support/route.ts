import { handleForm } from "@/lib/form-handler";
export const runtime = "nodejs";
export async function POST(request: Request) {
  return handleForm(request, "support");
}
