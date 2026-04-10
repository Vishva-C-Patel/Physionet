# PhysioNet (Physio Connect iOS App)

PhysioNet is a dual-role iOS app built with UIKit:
- `Patient` side: discover physiotherapists, book/manage appointments, watch exercises, view articles, track progress.
- `Physiotherapist` side: onboarding with proof documents, profile + availability management, appointments, programs, reports.

This repo also contains:
- Supabase migrations and edge functions.
- A small legal website (`legal-website/`) for Privacy Policy and Terms.

## Tech Stack

- iOS: Swift + UIKit (MVC-style screen modules)
- Backend: Supabase (Auth, Postgres, Storage, Edge Functions)
- Edge runtime: Deno

## Repository Structure

```text
.
├── Physio_Connect/                 # iOS source
│   ├── Core/
│   ├── Backend/
│   ├── Helpers/
│   ├── Extensions/
│   └── Screens/
│       ├── Common/
│       ├── Patient/
│       └── Physio/
├── Physio_Connect.xcodeproj/
├── supabase/
│   ├── migrations/
│   └── functions/
│       ├── delete_account/
│       └── trigger_articles/
├── legal-website/
├── .gitignore
└── LICENSE
```

## Prerequisites

- macOS + Xcode (latest stable recommended)
- iOS Simulator (or physical device)
- Supabase project

Optional:
- Supabase CLI (for local/deploy workflow)

## Run the iOS App

1. Open project:
   - `Physio_Connect.xcodeproj`
2. Select target/simulator.
3. Build and run (`Cmd + R`).

## Environment & Config

The app reads Supabase config from `Info.plist`:
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

Current helper files:
- `Physio_Connect/Backend/SupabaseManager.swift`
- `Physio_Connect/Backend/SupabaseConfig.swift`

Notes:
- Do **not** put service-role keys in iOS app code.
- Use publishable/anon-equivalent key only on client.
- Service-role key is only for server-side edge functions/secrets.

## Supabase Setup

### 1) Run SQL migrations

Run these SQL files in Supabase SQL Editor (in order):

1. `supabase/migrations/20260408_physio_proofs_storage_policies.sql`
2. `supabase/migrations/20260410_delete_account_support.sql`
3. `supabase/migrations/20260410_delete_account_block_booked.sql`

### 2) Deploy edge functions

Functions in this repo:
- `trigger_articles`
- `delete_account`

For `delete_account`, set secrets in Supabase Edge Function secrets:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY` (or publishable-compatible anon key expected by function)
- `SUPABASE_SERVICE_ROLE_KEY`

### 3) JWT verification note for `delete_account`

This project currently uses strict in-function auth validation and may require:
- `Verify JWT = OFF` on Supabase function settings for `delete_account`

Reason:
- Some environments show gateway-level `401 Invalid JWT` before function execution (`execution_id: null`) despite valid bearer payload metadata.
- Function itself validates bearer token via Supabase Auth (`auth.getUser`) before deletion logic.

If your project does not have this gateway mismatch, you can enable `Verify JWT`.

## Account Deletion Flow (Implemented)

The app supports account deletion for both patient and physiotherapist:

- Visible only when user is logged in.
- Hidden in logged-out/guest profile.
- Pre-check blocks deletion if there are `booked` appointments.
- Backend cleanup uses `delete_my_account_data()` RPC + auth user deletion.

Important:
- Keep legal text and App Store metadata aligned with this behavior.

## Legal Website

`legal-website/` contains static pages. Host this publicly and use the URL for:
- In-app Privacy Policy / Terms links
- App Store Connect Privacy Policy URL

Recommended:
- Keep policy content synchronized with actual data collection and deletion behavior.

## Apple App Review Readiness Notes

Before submission:

1. Login services
   - If third-party sign-in is shown, ensure Apple guideline compliance.
   - Current codebase has Google sign-in blocks commented with `GOOGLE_SIGNIN_TEMP_DISABLED`.

2. Privacy
   - Privacy Policy must be public and complete (data collected, purpose, retention, deletion, contact).

3. Deletion
   - In-app delete account must work for reviewer test account.

4. Completeness
   - Check console for no persistent AutoLayout break warnings on main flows.

## Tests

Project includes:
- `Physio_ConnectTests`
- `Physio_ConnectUITests`

Run from Xcode test navigator or `Cmd + U`.

## Security Recommendations

- Rotate and avoid hardcoding production keys in source files.
- Keep service-role keys only in Supabase secrets/server environments.
- Review RLS and storage policies regularly.

## License

MIT License. See [LICENSE](LICENSE).

## Maintainers

Project owner: `Vishva-C-Patel`  
Repository: `Vishva-C-Patel/Physionet`

