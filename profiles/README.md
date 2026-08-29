# Skill Profiles

Profiles are curated groups of upstream Agent Skills.

They are routing aids, not personas and not separate agents.

## Routing model

```text
task
  |
  +-- workflow skill: debugging / TDD / review / long-autonomy
  +-- domain skill: design / Postgres / security / motion
  +-- deterministic verifier: tests / typecheck / browser / scanner
```

Install only the profiles a machine/project actually needs.

`./ai-stack profile list` is the source of truth for names.

## Selection policy

A default/recommended skill should have:

1. identifiable upstream maintainer/repository,
2. an OSS license suitable for use,
3. meaningful community adoption or strong domain authority,
4. a scope that does not duplicate an existing default,
5. inspectable scripts and dependencies.

Popularity alone is insufficient.
