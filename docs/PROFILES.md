# Skill Profiles

AI Stack Matspectrum uses a small universal core plus project-local domain profiles. Framework/provider skills should normally be installed with `--project` so unrelated projects do not inherit irrelevant instructions.

## Profile matrix

| Profile | Use when | Upstream skills |
|---|---|---|
| `core` | Most software work | Matt Pocock: diagnosing-bugs, TDD, code-review, handoff |
| `nextjs` | Next.js 16.3+ runtime work | Vercel/Next.js: `next-dev-loop` |
| `design` | UI creation/refinement | Anthropic frontend-design, Impeccable, Taste |
| `design-redesign` | Existing UI redesign | Impeccable + Taste redesign workflow |
| `motion` | Motion is a real product requirement | Emil Kowalski animation skills |
| `shadcn` | Project uses shadcn/ui | Official shadcn skill |
| `database-postgres` | Generic Postgres work | Supabase Postgres best practices |
| `supabase` | Project uses Supabase products | Supabase + Postgres best practices |
| `better-auth` | Project uses Better Auth | Better Auth best practices, security, create-auth |
| `clerk-nextjs` | Next.js project uses Clerk | Clerk router/setup/Next.js/testing |
| `stripe` | Project integrates Stripe | Official Stripe skills from docs.stripe.com |
| `security` | Security review/hardening | Trail of Bits audit-context-building + Semgrep |
| `long-autonomy` | Long tasks need observable completion gates | Unlazy |
| `saas-nextjs` | Provider-neutral Next.js SaaS base | core + nextjs + security |

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

### Supabase

```bash
ai-stack profile supabase --project
```

Includes the comprehensive official Supabase skill plus Postgres best practices. Use for Database, Auth, Edge Functions, Realtime, Storage, SSR/RLS and related Supabase work.

### Better Auth

```bash
ai-stack profile better-auth --project
```

Use when Better Auth is the selected auth layer. Includes setup/implementation guidance plus security hardening.

### Clerk + Next.js

```bash
ai-stack profile clerk-nextjs --project
```

Use when Clerk is the selected auth layer. Includes Clerk setup, Next.js patterns and auth testing guidance.

Do not install Better Auth and Clerk profiles into the same project unless you are intentionally performing a migration.

### Stripe

```bash
ai-stack profile stripe --project
```

Installs Stripe's official Agent Skills from `https://docs.stripe.com`. Use only when Stripe is actually part of the application.

For gateways or payment systems that do not use Stripe, prefer the system's own OpenAPI/contracts, integration tests and domain documentation rather than forcing Stripe knowledge into the agent context.

## Example stacks

### Next.js + Supabase + Better Auth

```bash
ai-stack profile saas-nextjs --project
ai-stack profile supabase --project
ai-stack profile better-auth --project
ai-stack profile design --project
```

### Next.js + Supabase + Clerk + Stripe

```bash
ai-stack profile saas-nextjs --project
ai-stack profile supabase --project
ai-stack profile clerk-nextjs --project
ai-stack profile stripe --project
ai-stack profile shadcn --project   # only when components.json/shadcn is used
```

## Routing rule

Treat profiles as dependency-specific context, not badges to collect.

```text
Task
  -> workflow skill (debug/TDD/review)
  -> framework skill (Next.js)
  -> provider skill (Supabase/Auth/Stripe)
  -> deterministic verifier (tests/types/browser/contracts)
```

Prefer the smallest set that covers the current project.