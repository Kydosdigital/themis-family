---
name: build-slice
description: Implement one bounded Themis vertical slice from traced requirements through verification and commit.
---

1. Read docs/implementation/CURRENT_STATE.md.
2. Check branch and working tree.
3. Identify the exact requirement chain and acceptance criteria.
4. Confirm the work is allowed by docs/37_BUILD_SEQUENCE.md.
5. Set CURRENT_STATE to IN_PROGRESS, record refs/scope, set Commit required: YES, and record the next action.
6. Write a short implementation plan.
7. Implement the smallest complete vertical slice.
8. Add/update tests without weakening existing tests.
9. Run relevant checks.
10. Use QA/security reviewers where warranted.
11. Review git diff against requirements.
12. Update BUILD_LOG and IMPLEMENTATION_DECISIONS if needed.
13. Set CURRENT_STATE to COMPLETE only after verification.
14. Commit the verified slice with a focused message.
15. Record the commit in CURRENT_STATE.

If blocked by Apple/platform evidence, set Status: BLOCKED and record the exact spike/evidence needed. Do not substitute an assumption.
