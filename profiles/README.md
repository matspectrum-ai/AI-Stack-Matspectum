# Skill Profiles

Profiles are curated groups of upstream Agent Skills.

They are routing aids, not personas and not separate agents.

## Routing model

```text
task
  |
  +-- workflow: debugging / TDD / review / long-autonomy
  +-- framework: Next.js / future framework-specific workflows
  +-- domain: design / security / motion
  +-- provider: Supabase / Better Auth / Clerk / Stripe
  +-- deterministic verifier: tests / typecheck / browser / scanner / contracts
```

Install only the profiles a machine/project actually needs.

- Universal workflow skills may be global.
- Framework/provider skills should usually be project-local with `--project`.
- Do not install competing providers (for example Better Auth and Clerk) unless a migration explicitly needs both.
- `saas-nextjs` is a provider-neutral composition, not a generic SaaS persona.

`./ai-stack profile list` is the source of truth for names. See `docs/PROFILES.md` for the detailed matrix and examples.

## Selection policy

A default/recommended skill should have:

1. identifiable upstream maintainer/repository,
2. an OSS license suitable for use,
3. meaningful community adoption or strong domain authority,
4. a scope that does not duplicate an existing default,
5. inspectable scripts and dependencies,
6. a clear reason to be global versus project-local.

Popularity alone is insufficient.
