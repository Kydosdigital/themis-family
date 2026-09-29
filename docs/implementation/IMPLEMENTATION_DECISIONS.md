# Themis Family Implementation Decisions

Use this file for implementation choices that do not alter approved product requirements.

If a choice changes product behaviour, policy, an acceptance criterion, a security invariant, or an Apple capability assumption, it is not an implementation decision. It requires a specification amendment.

## IMP-001: Claude Code operating layer

Date: 2026-09-29
Status: Confirmed implementation-process decision

Decision:
Use committed project-level Claude Code instructions, rules, hooks, specialist agents, skills and persistent implementation-state files before application coding begins.

Rationale:
The product has a large approved specification and multiple Apple/platform gates. The operating layer reduces incomplete long-running tasks, protects approved requirements, preserves context across compaction, and creates deterministic quality checks around destructive commands and task completion.

Product impact:
None. This changes the development workflow only.
