# Skill Profiles

AI Stack Matspectrum uses a small universal core plus project-local capability profiles. Framework/provider skills should normally be installed with `--project` so unrelated projects do not inherit irrelevant instructions.

Prefer:

```bash
ai-stack detect .
```

over manually collecting profiles.

## Maturity labels

- **stable / official**: maintained by the framework/vendor and suitable as a normal project profile.
- **stable / community**: strong OSS source with meaningful adoption, suitable when its domain applies.
- **official / optional**: official, but useful only for a specific capability/provider/intent.
- **experimental / official**: maintained upstream, but the agent surface is still moving enough that it should be project-pinned and explicitly requested.

## Profile matrix

| Profile | Maturity | Use when | Upstream |
|---|---|---|---|
| `core` | stable / community | Most software work | Matt Pocock diagnosing-bugs, TDD, code-review, handoff |
| `long-autonomy` | emerging | Long tasks need observable completion gates | Unlazy |
| `security` | stable / community | Security review/hardening | Trail of Bits |
| `nextjs` | stable / official | Next.js 16.3+ runtime work | `vercel/next.js:next-dev-loop` |
| `nextjs-cache-adoption` | official / optional | Intentionally migrate to Cache Components | Vercel/Next.js |
| `nextjs-cache-optimize` | official / optional | Optimize Cache Components/PPR shell/navigation | Vercel/Next.js |
| `nextjs-partial-prefetch` | official / optional | Adopt/verify Partial Prefetching | Vercel/Next.js |
| `react` | stable / official | React/Next performance and rendering/data patterns | Vercel Labs `vercel-react-best-practices` |
| `react-components` | stable / official | Scalable React component APIs/composition | Vercel Labs `vercel-composition-patterns` |
| `react-view-transitions` | official / optional | Native React/Next View Transitions | Vercel Labs |
| `vercel-web-design` | official / optional | Audit UI/UX/a11y against Vercel Web Interface Guidelines | Vercel Labs |
| `vite` | stable / community | Project uses Vite | Anthony Fu |
| `vitest` | stable / community | Project uses Vitest | Anthony Fu |
| `web-quality` | stable / community | Broad web quality audit | Addy Osmani |
| `web-performance` | stable / community | Focused web performance work | Addy Osmani |
| `design` | stable / community | UI creation/refinement | Anthropic Frontend Design + Impeccable + Taste |
| `design-redesign` | stable / community | Existing UI redesign | Impeccable + Taste |
| `motion` | stable / community | Motion is a real product requirement | Emil Kowalski |
| `shadcn` | stable / official | Project uses shadcn/ui | shadcn/ui |
| `database-postgres` | stable / official | Generic Postgres work | Supabase Postgres best practices |
| `supabase` | stable / official | Project uses Supabase products | Supabase |
| `prisma` | stable / official | Project uses Prisma | Prisma |
| `drizzle-experimental` | experimental / official | Compatible local Drizzle agent surface | Drizzle Kit bundled skills |
| `cloudflare` | stable / official | Workers/Pages/D1/R2/KV/Durable Objects/etc. | Cloudflare |
| `cloudflare-agents` | official / optional | Project uses Cloudflare Agents SDK | Cloudflare |
| `vercel-optimize` | official / optional | Metrics-first audit of a deployed Vercel project | Vercel Labs |
| `better-auth` | stable / official | Project uses Better Auth | Better Auth |
| `clerk-nextjs` | official / optional | Next.js project uses Clerk | Clerk |
| `stripe` | official / optional | Project integrates Stripe | Stripe docs skills |
| `sentry-nextjs` | official / optional | Next.js project uses Sentry | Sentry |
| `saas-nextjs` | convenience preset | Provider-neutral Next.js SaaS bootstrap | core + nextjs + security |

## React / UI routing

For a normal React project, `detect` recommends:

```text
react
react-components
```

These solve different problems:

- `react` -> performance, async/data patterns, server/client rendering and bundle behavior.
- `react-components` -> component API architecture, compound components, state lifting and composition.

Intent-dependent UI profiles remain optional:

- `vercel-web-design` -> audit against interface/UX/a11y rules.
- `design` -> generate/refine visual direction.
- `motion` -> animation and motion design.
- `react-view-transitions` -> native React/Next View Transition implementation.
- `web-quality` / `web-performance` -> evidence-led quality and performance work.

Do not treat these as synonyms or invoke all of them for every UI task.

### Vercel Labs license hygiene

The individual `vercel-react-best-practices`, `vercel-composition-patterns` and `vercel-react-view-transitions` manifests declare MIT. The parent `vercel-labs/agent-skills` repository also declares MIT in README metadata, but its top-level LICENSE file is still unresolved upstream as of August 2026.

`web-design-guidelines` fetches its actual rule source from `vercel-labs/web-interface-guidelines`, which has a normal MIT license. AI Stack keeps this profile opt-in and does not vendor/relicense the upstream repository.

## Next.js routing

The universal Next.js profile is:

```bash
ai-stack profile nextjs --project
```

It installs `next-dev-loop`, which verifies a running Next.js app through both framework runtime introspection and a real browser.

The other Next.js skills are task-specific:

```bash
ai-stack profile nextjs-cache-adoption --project
ai-stack profile nextjs-cache-optimize --project
ai-stack profile nextjs-partial-prefetch --project
```

Do not install migration/optimization skills just because Next.js is present.

## Backend / ORM routing

### Prisma

```bash
ai-stack profile prisma --project
```

Installs focused Prisma CLI, Client API and database setup skills.

### Drizzle

```bash
ai-stack profile drizzle-experimental --project
```

This profile does not install a new Drizzle version. It requires the target project's own `./node_modules/.bin/drizzle-kit` and invokes its bundled skill surface. Experimental profiles are never auto-applied.

## Infrastructure routing

### Cloudflare

```bash
ai-stack profile cloudflare --project
```

Add `cloudflare-agents` only if the project actually uses the Agents SDK.

### Vercel

Use deterministic Vercel operations through:

```bash
ai-stack toolchain vercel-cli
```

For an already linked/deployed Vercel project, `vercel-optimize` is an optional metrics-first analysis skill, not a universal frontend skill.

## Observability

```bash
ai-stack profile sentry-nextjs --project
```

Production issue fixing that needs Sentry MCP access remains outside the default profile because it expands permissions/data access.

## API engineering

APIs use deterministic contracts rather than a generic backend persona:

```bash
ai-stack toolchain api-contracts
```

The contract loop is OpenAPI -> lint -> breaking-change check -> implementation -> integration/contract tests -> optional property-based runtime testing.

## Routing rule

```text
Task
  -> workflow capability
  -> framework/runtime capability
  -> domain/provider capability
  -> deterministic verification
```

Profiles are dependency-specific context, not badges to collect. Universal means broad coverage with selective activation, not loading everything at once.
