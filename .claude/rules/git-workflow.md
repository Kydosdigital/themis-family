# Git workflow rule

Before editing:
- check branch
- check working tree
- understand unrelated existing changes

Before committing:
- inspect git diff
- run applicable verification
- ensure no secrets or local settings are staged
- update implementation state/logs

Use focused commit messages that describe one coherent unit of work.

Never:
- force push
- hard reset away work
- run git clean destructively
- rewrite shared history
- discard unrelated user changes

Do not push automatically unless the user requested a push or the active task explicitly requires remote delivery.
