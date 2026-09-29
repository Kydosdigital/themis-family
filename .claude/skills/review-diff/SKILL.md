---
name: review-diff
description: Perform a requirement-aware review of the current git diff before a Themis task is closed or committed.
---

Review the current diff as if it were a pull request.

Prioritise requirement violations, security/privacy regressions, incorrect state transitions, race/offline failures, missing tests, accidental scope expansion and material maintainability issues.

Use specialist reviewer agents when useful.

Do not nitpick formatting unless it affects correctness or conventions.

If no issues are found, say so explicitly and identify which requirements were checked.
