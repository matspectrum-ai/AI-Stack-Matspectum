# Security and Skill Supply Chain

Agent Skills can contain shell directives, scripts and network operations. Treat them as executable dependencies.

Deterministic toolchains also deserve review: package installers, code generators, deployment CLIs and database migration tools can have side effects even when no LLM is involved.

## Before adding a skill to a profile

Check:

1. Exact upstream repository and maintainer.
2. License.
3. `SKILL.md`.
4. Bundled scripts.
5. Shell commands.
6. Network access.
7. Secret/API-key expectations.
8. Install/update mechanism.
9. Overlap/conflicts with existing skills.
10. Community/domain-authority signal.

## Before running a third-party skill

Inspect commands that can:
- delete or overwrite data,
- modify Git history,
- access production,
- read credentials,
- send repository content over the network,
- install packages,
- run scanners/rules downloaded at runtime.

## Provider skills

Framework/provider profiles are normally project-local. Do not globally install provider context that unrelated repositories do not use.

Provider skills can describe or invoke CLIs/APIs with side effects. Authentication, billing, infrastructure and database operations deserve stricter review than read-only framework guidance.

### Database and migration operations

Treat these as approval-gated when they can affect shared/staging/production data:

- `prisma migrate deploy`, `db push`, destructive/reset operations,
- Drizzle `push`/migration execution against non-local databases,
- schema changes that drop/rename columns or alter constraints,
- RLS/policy changes,
- destructive seed/reset commands.

Prefer:

- local/ephemeral databases for agent iteration,
- generated migration review before execution,
- backups or rollback plans for production migrations,
- migration/contract tests,
- explicit target-environment confirmation before writes.

### Infrastructure and deployment

Cloud/Vercel/Cloudflare skills or CLIs do not imply production deployment permission.

Require explicit approval for:

- production deploy/promote/rollback,
- DNS/domain changes,
- secret/environment-variable mutations,
- destructive infrastructure changes,
- production database/storage binding changes.

Preview/local deployments are preferred for verification when available.

### Financial/payment operations

A Stripe/payment skill does not imply permission to perform financial mutations. Treat operations such as charging, refunding, canceling subscriptions, finalizing invoices, changing payout settings or modifying production payment configuration as approval-gated actions.

Prefer:
- test/sandbox environments by default,
- restricted credentials/scopes,
- idempotency keys for retryable payment mutations,
- explicit human approval before irreversible or monetary actions,
- webhook/contract tests before production changes.

### API code generation

OpenAPI Generator can write a large generated tree. Run generation into an explicit output directory and inspect the diff before replacing hand-written code.

Do not feed untrusted OpenAPI templates/specs into generators without review. Treat generated code as build input that still requires tests and dependency/security review.

## Updates

`npx skills update` changes executable/procedural dependencies. Do not assume an updated skill has identical behavior.

Global npm/toolchain upgrades can also change behavior. For sensitive CI, pin reviewed versions instead of following `latest` automatically.

For sensitive environments, pin or vendor reviewed revisions rather than following latest automatically.

## Secrets

- Keep secrets in environment variables or a secrets manager.
- Do not paste secrets into skills, `AGENTS.md`, specs or logs.
- Redact captured HTTP headers and auth material.
- Give agents minimum necessary scopes.

## Sandbox

Harness permission controls are policy, not isolation. For high-autonomy tasks use a container/VM/sandbox with:
- limited filesystem mounts,
- limited network,
- no production secrets by default,
- explicit writable paths.

## Security profile

The Trail of Bits skills are intentionally not part of the universal core because security scans can be expensive, intrusive and may require user approval of rulesets/tool execution.
