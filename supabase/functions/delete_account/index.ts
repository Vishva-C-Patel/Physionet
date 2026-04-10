import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const headers = { "Content-Type": "application/json" };

type StorageRef = { bucket: string; path: string };

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405, headers });
  }

  if (!supabaseUrl || !supabaseAnonKey || !serviceRoleKey) {
    return new Response(
      JSON.stringify({ error: "Missing Supabase env vars", details: "SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY required" }),
      { status: 500, headers },
    );
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.replace(/^Bearer\s+/i, "").trim();
  if (!token) {
    return new Response(JSON.stringify({ error: "Missing or invalid Authorization header" }), { status: 401, headers });
  }

  const userClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: `Bearer ${token}` } },
  });
  const adminClient = createClient(supabaseUrl, serviceRoleKey);

  const { data: authData, error: authError } = await userClient.auth.getUser();
  if (authError || !authData?.user) {
    const details = authError?.message?.includes("Invalid JWT")
      ? "Session expired. Please log in again and retry."
      : authError?.message;
    return new Response(JSON.stringify({ error: "Unauthorized", details }), { status: 401, headers });
  }

  const uid = authData.user.id;
  const storageRefs: StorageRef[] = [];

  try {
    const [physioRes, customerRes] = await Promise.all([
      userClient
        .from("physiotherapists")
        .select("profile_image_path,id_proof_path,license_proof_path")
        .eq("id", uid)
        .maybeSingle(),
      userClient
        .from("customers")
        .select("avatar_url")
        .eq("id", uid)
        .maybeSingle(),
    ]);

    if (physioRes.data) {
      const p = physioRes.data as Record<string, string | null>;
      [p.profile_image_path, p.id_proof_path, p.license_proof_path]
        .map((v) => parseStorageRef(v))
        .filter((v): v is StorageRef => v !== null)
        .forEach((v) => storageRefs.push(v));
    }

    if (customerRes.data) {
      const c = customerRes.data as Record<string, string | null>;
      const avatarRef = parseStorageRef(c.avatar_url);
      if (avatarRef) storageRefs.push(avatarRef);
    }

    const metadataAvatar = parseStorageRef((authData.user.user_metadata?.avatar_url as string | undefined) ?? null);
    if (metadataAvatar) storageRefs.push(metadataAvatar);

    const { error: cleanupError } = await userClient.rpc("delete_my_account_data");
    if (cleanupError) {
      return new Response(JSON.stringify({ error: "Cleanup failed", details: cleanupError.message }), { status: 400, headers });
    }

    const grouped = groupByBucket(storageRefs);
    for (const [bucket, paths] of Object.entries(grouped)) {
      if (!paths.length) continue;
      await adminClient.storage.from(bucket).remove(paths);
    }

    const { error: deleteError } = await adminClient.auth.admin.deleteUser(uid);
    if (deleteError) {
      return new Response(JSON.stringify({ error: "Auth user delete failed", details: deleteError.message }), { status: 400, headers });
    }

    return new Response(JSON.stringify({ ok: true }), { status: 200, headers });
  } catch (error) {
    return new Response(
      JSON.stringify({ error: "Delete account failed", details: error instanceof Error ? error.message : String(error) }),
      { status: 500, headers },
    );
  }
});

function parseStorageRef(raw: string | null | undefined): StorageRef | null {
  if (!raw) return null;
  const trimmed = raw.trim();
  if (!trimmed) return null;

  const marker = "/storage/v1/object/public/";
  const markerIndex = trimmed.indexOf(marker);
  if (markerIndex >= 0) {
    const tail = trimmed.slice(markerIndex + marker.length);
    const [bucket, ...rest] = tail.split("/");
    const path = rest.join("/");
    if (bucket && path) return { bucket, path };
  }

  const cleaned = trimmed.replace(/^\/+|\/+$/g, "");
  const [bucket, ...rest] = cleaned.split("/");
  const path = rest.join("/");
  if (!bucket || !path) return null;
  return { bucket, path };
}

function groupByBucket(refs: StorageRef[]): Record<string, string[]> {
  const result: Record<string, string[]> = {};
  for (const ref of refs) {
    if (!result[ref.bucket]) result[ref.bucket] = [];
    if (!result[ref.bucket].includes(ref.path)) result[ref.bucket].push(ref.path);
  }
  return result;
}
