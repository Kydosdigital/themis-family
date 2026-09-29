---
name: close-task
description: Close a Themis implementation task only after verification, logs, diff review and the required commit are complete.
---

Before closing:
1. CURRENT_STATE must exist.
2. Re-read the objective and requirement refs.
3. Run verification.
4. Review the diff.
5. Resolve findings or mark BLOCKED.
6. Update BUILD_LOG.
7. Update IMPLEMENTATION_DECISIONS for any genuine implementation decision.
8. If Commit required is YES, inspect staged files, create one focused commit and record its SHA.
9. Set Status: COMPLETE only when all completion conditions are true.
10. Report what changed, requirement coverage, checks run, reviewer findings, blockers and commit SHA.

Do not call a task complete with a dirty working tree when the task requires a commit.
