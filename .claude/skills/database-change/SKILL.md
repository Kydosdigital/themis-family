---
name: database-change
description: Make a safe Supabase/Postgres schema or policy change through versioned migrations and verification.
---

Before changing the database:

1. Read `.claude/rules/database.md`.
2. Trace the change to the approved data model/security requirements.
3. Confirm the target Supabase project/environment.
4. Never use production as the default development target.
5. Inspect existing migrations before creating a new one.

For the change:

1. Create a new forward migration in `supabase/migrations/`.
2. Add constraints/indexes/RLS policies required for correctness and security.
3. Avoid embedding generated project/user IDs into reusable migrations.
4. Test locally or on an approved development branch/project.
5. Run Supabase security/performance advisors when the project connection is available.
6. Add integration tests for RLS and critical invariants.
7. Record any implementation-only choice in IMPLEMENTATION_DECISIONS.
8. Do not rewrite a shared migration to hide a mistake; add a corrective migration.

For privileged functions:
- minimise SECURITY DEFINER use
- set an explicit safe search_path
- verify role checks server-side
- test unauthorised calls

Commit migration and tests together when practical.
