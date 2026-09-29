---
name: review-feature
description: Run a complete requirement-aware review of one Themis implementation feature before closeout.
---

Use after implementation and before close-task for any non-trivial feature.

1. Identify requirement and acceptance-criteria coverage.
2. Run the code-reviewer.
3. Run the qa-reviewer.
4. Run the security-reviewer if auth, child data, permissions, notifications, device binding, Supabase policies or enforcement state is involved.
5. Run the architect if the change crosses module/device/backend boundaries.
6. Run applicable automated verification.
7. Review the current diff.
8. Consolidate duplicate findings.
9. Classify each material finding:
   - BLOCKER
   - HIGH
   - MEDIUM
   - LOW
10. Fix BLOCKER/HIGH findings before completion unless explicitly accepted by the founder.
11. Re-run relevant checks after fixes.
12. Record the result in BUILD_LOG.

Do not mark a feature complete just because reviewer agents found no issue; automated and acceptance-criteria verification still apply.
