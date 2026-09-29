---
name: verify
description: Verify a Themis implementation slice against requirements, tests, git diff, security and completion criteria.
---

1. Re-read traced acceptance criteria.
2. Inspect git status and diff.
3. Run narrow relevant tests first, then broader checks if warranted.
4. Confirm no legitimate test was deleted, skipped or weakened.
5. Check failure and permission paths.
6. Check security/privacy requirements where applicable.
7. Check no approved specification file changed.
8. Check no production Apple behaviour crossed an unresolved spike gate.
9. Check no secrets or local settings are staged.
10. Record exact commands/results in CURRENT_STATE under Last verification.

Return PASS, FAIL or BLOCKED with specific reasons.
