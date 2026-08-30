# Skill Profiles

AI Stack Matspectrum uses a small universal core plus project-local domain profiles. Framework/provider skills should normally be installed with `--project` so unrelated projects do not inherit irrelevant instructions.

## Maturity labels

- **stable / official**: maintained by the framework/vendor and suitable as a normal project profile.
- **official / optional**: official, but only useful when that provider/platform is actually used.
- **experimental / official**: maintained upstream, but the agent surface is still moving enough that it should be pinned to the project and reviewed on upgrade.

## Profile matrix

| Profile | Maturity | Use when | Upstream skills |
|---|---|---|---|
| `core` | stable | Most software work | Matt Pocock: diagnosing-bugs, TDD, code-review, handoff |
| `nextjs` | stable / official | Next.js 16.3+ runtime work | Vercel/Next.js: `next-dev-loop` |
| `design` | stable | UI creation/refinement | Anthropic frontend-design, Impeccable, Taste |
| `design-redesign` | stable | Existing UI redesign | Impeccable + Taste redesign workflow |
| `motion` | stable | Motion is a real product requirement | Emil Kowalski animation skills |
| `shadcn` | official / optional | Project uses shadcn/ui | Official shadcn skill |
| `database-postgres` | stable / official | Generic Postgres work | Supabase Postgres best practices |
| `supabase` | stable / official | Project uses Supabase products | Supabase + Postgres best practices |
| `prisma` | stable / official | Project uses Prisma ORM 7.x | Prisma CLI, Client API, database setup |
| `drizzle-experimental` | experimental / official | Project already uses a compatible Drizzle Kit RC/new agent surface | Drizzle Kit bundled project skills |
| `cloudflare` | stable / official | Workers/Pages/D1/R2/KV/Durable Objects/etc. | Cloudflare platform + Workers best practices |
| `cloudflare-agents` | official / optional | Project uses Cloudflare Agents SDK | Cloudflare Agents SDK skill |
| `better-auth` | stable / official | Project uses Better Auth | Better Auth best practices, security, create-auth |
| `clerk-nextjs` | official / optional | Next.js project uses Clerk | Clerk router/setup/Next.js/testing |
| `stripe` | official / optional | Project integrates Stripe | Official Stripe skills from docs.stripe.com |
| `sentry-nextjs` | official / optional | Next.js project uses Sentry | Sentry Next.js SDK + tracing + logging |
| `security` | stable | Security review/hardening | Trail of Bits audit-context-building + Semgrep |
| `long-autonomy` | emerging | Long tasks need observable completion gates | Unlazy |
| `saas-nextjs` | stable composition | Provider-neutral Next.js SaaS base | core + nextjs + security |

## Backend / ORM routing

Do not install multiple ORM profiles merely because they exist.

### Prisma

```bash
ai-stack profile prisma --project
```

The official Prisma skill repository is intentionally used even though its GitHub star count is small: domain authority matters more here than repository popularity, and individual Prisma skills have substantial installs in the Agent Skills ecosystem.

The profile installs:

- `prisma-cli`
- `prisma-client-api`
- `prisma-database-setup`

These cover migrations/CLI behavior, query/client usage, and database-provider setup without pulling unrelated Prisma Platform skills into every session.

### Drizzle

```bash
ai-stack profile drizzle-experimental --project
```

This profile does **not** install a new Drizzle version. It requires `./node_modules/.bin/drizzle-kit` from the target project and runs its bundled `skills` command.

Reason: Drizzle's official agent skills are real, but the packaging is still being actively redesigned around the RC/next-generation Drizzle Kit surface. The stack therefore treats them as project-pinned experimental context rather than a global default.

## Infrastructure routing

### Cloudflare

```bash
ai-stack profile cloudflare --project
```

Installs the official Cloudflare platform router plus `workers-best-practices`. Use for Workers, Pages, D1, R2, KV, Durable Objects, Queues, Workflows, Wrangler, security and related platform work.

If the application specifically builds agents on Cloudflare:

```bash
ai-stack profile cloudflare-agents --project
```

Do not load `agents-sdk` in a normal Worker that does not use the Agents SDK.

### Vercel

The strict OSS stack does not currently install `vercel-labs/agent-skills/deploy-to-vercel` because the repository still lacks a top-level license file despite an MIT statement in its README. Instead, use the Apache-2.0 Vercel CLI as a deterministic toolchain:

```bash
ai-stack toolchain vercel-cli
```

Deployment remains an external side effect; production deployment requires explicit user approval.

## Observability

### Sentry + Next.js

```bash
ai-stack profile sentry-nextjs --project
```

Installs official Sentry skills for Next.js setup, tracing and logging. Production issue fixing (`sentry-fix-issues`) is intentionally not installed by default because it additionally relies on access to Sentry through MCP and therefore expands permissions/data access.

## Next.js

Install into the project:

```bash
ai-stack profile nextjs --project
```

The official Next.js `next-dev-loop` skill is a runtime verification workflow, not a replacement for framework documentation. Current Next.js versions bundle version-matched framework docs; workflow skills sequence runtime inspection and verification.

`next-dev-loop` currently requires:

- Next.js 16.3+
- Turbopack
- `agent-browser` >= 0.31.1

Install browser tooling with:

```bash
ai-stack bootstrap --with-browser
```

## SaaS composition

There is intentionally no generic `saas` skill. SaaS architecture is composed from the actual framework and providers.

Start a Next.js SaaS project with:

```bash
ai-stack profile saas-nextjs --project
```

Then add only what the project uses.

Typical choices:

```bash
# Data / backend
ai-stack profile supabase --project
# OR
ai-stack profile prisma --project
# OR, when the project already runs the compatible Drizzle agent surface
ai-stack profile drizzle-experimental --project

# Auth: choose the actual provider
ai-stack profile better-auth --project
# OR
ai-stack profile clerk-nextjs --project

# Billing only when used
ai-stack profile stripe --project

# Observability only when used
ai-stack profile sentry-nextjs --project

# Infrastructure only when used
ai-stack profile cloudflare --project

# Public/API-heavy SaaS
ai-stack toolchain api-contracts
```

For gateways or payment systems that do not use Stripe, prefer the system's own OpenAPI/contracts, integration tests and domain documentation rather than forcing Stripe knowledge into the agent context.

## Routing rule

Treat profiles as dependency-specific context, not badges to collect.

```text
Task
  -> workflow skill (debug/TDD/review)
  -> framework skill (Next.js)
  -> backend/provider skill (Prisma/Supabase/Cloudflare/etc.)
  -> deterministic verifier (tests/types/browser/contracts)
```

Prefer the smallest set that covers the current project.