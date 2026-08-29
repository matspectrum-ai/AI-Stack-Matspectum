# AGENTS.md

## Project commands

Replace placeholders with the canonical commands for this repository.

```text
dev:        <command>
test:       <command>
lint:       <command>
typecheck:  <command>
e2e:        <command>
verify:     <single canonical verification command>
```

## Architecture constraints

Document only stable constraints that an agent must not infer incorrectly.

- <constraint>
- <constraint>

## Definition of done

A change is complete only when:

1. The requested observable behavior is implemented.
2. Relevant deterministic verification passes.
3. New behavior has appropriate tests or an explicit justification for why not.
4. UI changes are browser-verified when applicable.
5. No secrets or generated artifacts were committed accidentally.

## Agent behavior

- Read `CONTEXT.md` when domain/module understanding is needed.
- Read relevant ADRs before changing an architectural decision.
- Prefer repository commands over inventing new command sequences.
- Do not broaden task scope without a concrete reason.
- Do not report success based only on code inspection when a runnable verifier exists.
