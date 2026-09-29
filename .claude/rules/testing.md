# Testing rule

Tests are part of implementation, not cleanup.

For each slice:
- trace changed behaviour to acceptance criteria
- test happy path
- test failure path
- test permission/role boundaries
- test offline/race behaviour where relevant
- test child-facing neutral copy where behaviour can feel punitive
- test privacy/security invariants where relevant

Never remove, skip or weaken a legitimate test merely to make a build pass.

When platform behaviour is unverified, write a spike or harness test and record measured results instead of encoding an assumed production test.

Real-device spike results must record:
- OS version
- device model
- setup conditions
- expected behaviour
- observed behaviour
- repeatability
- screenshots/logs or other evidence where useful
- specification impact
