# Supabase and database rule

Supabase is the selected backend platform for Themis Family.

## Schema discipline

- Every durable schema change must be represented by a migration under `supabase/migrations/`.
- Do not rely on ad-hoc Dashboard changes as the durable source of truth.
- Once a migration is shared/merged, prefer a forward-fix migration over rewriting history.
- Use explicit constraints for invariants that PostgreSQL can enforce.
- Keep the one-active-household-binding invariant backed by database constraints/transactions where feasible, not application code alone.
- Use transactions for multi-row state transitions that must be atomic.

## Security

- Enable and test Row Level Security for user-accessible tables before shipping.
- Deny by default. Add the minimum policies required for each role.
- Never expose a service-role key to the iOS app.
- Never commit database passwords, access tokens, service-role secrets or signing material.
- Treat `SECURITY DEFINER` functions as privileged code. Set an explicit safe `search_path` and keep their surface narrow.
- Support/admin access must remain scenario-scoped and must not create parental-decision powers.
- Child-device credentials are a Themis security boundary and must not be replaced with a broad anonymous database permission.

## Client/server boundary

Use Supabase Auth for appropriate Owner/Guardian identity flows only where it fits the approved requirements.

Do not conflate:
- Supabase authentication
- Themis child-device scoped credentials
- Apple Family Controls authorisation

They are separate mechanisms.

Privileged operations such as ownership transfer, device re-pairing recovery, atomic approvals, destructive account actions and other security-sensitive state changes should run through controlled server-side logic/RPC/Edge Functions rather than trusting a client-side sequence of table writes.

## MCP usage

The committed Supabase MCP server must be project-scoped via `SUPABASE_PROJECT_REF`.

Use MCP writes only against the intended development project and only within the active task scope.

Never point the coding agent at a production project with broad write access for routine development.

Use manual tool approval for schema/data-changing MCP actions.

## Data minimisation

Store only data justified by the approved data model and privacy requirements.

Do not add detailed browsing data, message contents, Apple raw Screen Time data, or "useful later" child behavioural fields outside the approved model.
