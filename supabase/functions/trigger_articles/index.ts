import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type IncomingBody = {
  keyword?: string;
  source?: "appointment" | "video" | "manual";
  context?: Record<string, unknown>;
};

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

const supabase = createClient(supabaseUrl, supabaseAnonKey);
const headers = { "Content-Type": "application/json" };

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers,
    });
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.replace("Bearer ", "").trim();
  if (!token) {
    return new Response(JSON.stringify({ error: "Missing or invalid Authorization header" }), {
      status: 401,
      headers,
    });
  }

  const { data: userData, error: authError } = await supabase.auth.getUser(token);
  if (authError || !userData?.user) {
    return new Response(
      JSON.stringify({ error: "Unauthorized", details: authError?.message }),
      { status: 401, headers },
    );
  }

  let body: IncomingBody;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON body" }), {
      status: 400,
      headers,
    });
  }

  const keyword = (body.keyword ?? "").trim().replace(/\s+/g, " ");
  if (keyword.length < 2 || keyword.length > 80) {
    return new Response(
      JSON.stringify({ error: "Invalid keyword", details: "keyword must be 2-80 characters" }),
      { status: 400, headers },
    );
  }

  const allowedSources = new Set(["appointment", "video", "manual"]);
  const source = allowedSources.has(body.source ?? "") ? (body.source as string) : "manual";
  const context = typeof body.context === "object" && body.context !== null ? body.context : {};

  const webhookUrl = Deno.env.get("N8N_WEBHOOK_URL");
  if (!webhookUrl) {
    return new Response(JSON.stringify({ error: "Missing N8N_WEBHOOK_URL secret" }), {
      status: 500,
      headers,
    });
  }
  const webhookSecret = Deno.env.get("N8N_WEBHOOK_SECRET");

  const forwardPayload = {
    keyword,
    source,
    context,
    user_id: userData.user.id,
  };

  const forwardHeaders: Record<string, string> = { "Content-Type": "application/json" };
  if (webhookSecret) {
    forwardHeaders["X-Webhook-Secret"] = webhookSecret;
  }

  const webhookResp = await fetch(webhookUrl, {
    method: "POST",
    headers: forwardHeaders,
    body: JSON.stringify(forwardPayload),
  });

  if (!webhookResp.ok) {
    const detail = await webhookResp.text().catch(() => "");
    return new Response(
      JSON.stringify({ error: "n8n failed", details: detail || webhookResp.statusText }),
      { status: 502, headers },
    );
  }

  return new Response(JSON.stringify({ ok: true }), { status: 200, headers });
});
