# Requirements-first rule

The approved product specification is authoritative.

Before changing product behaviour, identify the requirement chain:
Business goal -> HLR -> FR/BR/DEC -> user story -> acceptance criteria -> test.

Do not implement a feature from memory when the repository contains the relevant requirement.

Do not weaken, reinterpret or edit approved requirements to make implementation easier.

During normal implementation, specification files under `docs/` are read-only except `docs/implementation/`.

If code, platform behaviour or a spike contradicts the specification:
1. preserve the evidence
2. record the discrepancy in `docs/implementation/IMPLEMENTATION_DECISIONS.md`
3. mark the affected implementation BLOCKED
4. request an explicit spec amendment

The technical spike programme is part of the requirement system, not optional research.
