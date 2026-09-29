---
name: spike
description: Run a bounded Themis technical spike, capture evidence and feed results back into implementation gates.
---

Use this for an approved technical spike, not production feature implementation.

Before the spike:
1. identify the exact Priority/OQ/NFR it answers
2. write hypothesis and success/failure criteria in SPIKE_RESULTS.md
3. set CURRENT_STATE to IN_PROGRESS

Build the smallest experiment that can answer the question.

Record date, priority, requirement refs, device, OS, build/configuration, exact steps, expected result, observed result, repeatability, evidence, conclusion and specification impact.

Do not promote spike code to production automatically.

If the result contradicts the approved specification, record the discrepancy and stop affected production work pending an explicit spec amendment.
