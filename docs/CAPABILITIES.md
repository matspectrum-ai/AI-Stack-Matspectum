# Capability Architecture

AI Stack Matspectrum is capability-centric, not product-centric.

A SaaS, dashboard, API, CLI, library, e-commerce app or fintech system is treated as a composition of the technologies and verification surfaces it actually uses.

```text
project
  |
  +-- workflow capabilities
  +-- framework/runtime capabilities
  +-- frontend/design capabilities
  +-- backend/data capabilities
  +-- testing/quality capabilities
  +-- infra/observability capabilities
  +-- deterministic toolchains
```

## Detection and application

Read-only detection:

```bash
ai-stack detect .
```

Preview and apply high-confidence profiles:

```bash
ai-stack apply .
```

Include intent-dependent recommendations such as design or web-quality profiles:

```bash
ai-stack apply . --include-optional
```

Experimental surfaces are never auto-applied:

```bash
ai-stack apply . --include-experimental
```

`detect` is intentionally conservative. Static dependency detection can identify frameworks and providers, but it cannot infer whether a project needs a visual redesign, motion work, a cache migration or long-running autonomous execution.

## Capability classes

### Workflow

| Profile | Purpose |
|---|---|
| `core` | Debugging, TDD, review and handoff workflows |
| `long-autonomy` | Observable completion gates for substantial tasks |
| `security` | Context-first security review and Semgrep |

### Next.js

| Profile | Purpose | Default? |
|---|---|---|
| `nextjs` | Runtime verification through `/_next/mcp` + browser | Yes for detected Next.js |
| `nextjs-cache-adoption` | Adopt Cache Components | No; migration intent required |
| `nextjs-cache-optimize` | TDD optimization loop for instant shell/navigation | No |
| `nextjs-partial-prefetch` | Adopt/verify Partial Prefetching | Only when detected/configured |

### React / Vercel engineering skills

The Vercel Labs Agent Skills pack has strong community adoption. AI Stack exposes the useful application-development pieces separately rather than installing the whole pack.

| Profile | Upstream skill | Role |
|---|---|---|
| `react` | `vercel-react-best-practices` | React/Next performance and data/rendering patterns |
| `react-components` | `vercel-composition-patterns` | Compound components, state lifting and scalable component APIs |
| `react-view-transitions` | `vercel-react-view-transitions` | Native React/Next View Transition implementation |
| `vercel-web-design` | `web-design-guidelines` | UI/UX/accessibility review against Vercel Web Interface Guidelines |
| `vercel-optimize` | `vercel-optimize` | Metrics-first audit for deployed Vercel projects |

`react` and `react-components` are high-confidence recommendations when React is detected. `react-view-transitions`, `vercel-web-design` and `vercel-optimize` remain intent/provider-dependent.

### Vercel license note

The individual `vercel-react-best-practices`, `vercel-composition-patterns` and `vercel-react-view-transitions` skill manifests declare MIT. The `vercel-labs/agent-skills` repository also declares MIT in its README, but as of August 2026 its top-level `LICENSE` file has not been merged. `web-design-guidelines` fetches its rule source from `vercel-labs/web-interface-guidelines`, which has a normal MIT license. AI Stack therefore keeps Vercel Labs profiles project-local/opt-in where license hygiene is ambiguous rather than vendoring or relicensing them.

### Design / UI

| Profile | Role |
|---|---|
| `design` | New/original UI direction + product polish + visual taste |
| `design-redesign` | Existing product redesign/refinement |
| `motion` | Motion implementation and review |
| `shadcn` | shadcn/ui-specific component guidance |
| `vercel-web-design` | UI/UX/a11y audit, not generative visual direction |
| `react-components` | Component architecture, not visual design |

These profiles intentionally solve different problems. Do not invoke every design skill for one task.

### Testing / quality

| Profile | Role |
|---|---|
| `vitest` | Vitest configuration, mocking, coverage and tests |
| `web-quality` | Broad evidence-led web quality audit |
| `web-performance` | Focused web performance work |

Normal project tests, typecheck, lint and browser/E2E evidence remain more authoritative than an LLM review.

### Backend / data

| Profile | Role |
|---|---|
| `database-postgres` | Generic Postgres best practices |
| `supabase` | Supabase products + Postgres guidance |
| `prisma` | Prisma CLI, Client API and database setup |
| `drizzle-experimental` | Project-bundled Drizzle agent surface; experimental |

### Platform / observability

| Profile/toolchain | Role |
|---|---|
| `cloudflare` | Workers/platform best practices |
| `cloudflare-agents` | Cloudflare Agents SDK |
| `sentry-nextjs` | Sentry Next.js setup, tracing and logging |
| `vercel-optimize` | Vercel metrics/cost/performance analysis |
| `vercel-cli` toolchain | Deterministic Vercel CLI |

### API engineering

API engineering is deliberately contract-first rather than based on a generic "API expert" skill.

```text
OpenAPI
  -> Spectral
  -> oasdiff
  -> implementation
  -> integration/contract tests
  -> Schemathesis (optional)
```

Use:

```bash
ai-stack toolchain api-contracts
```

## Detection policy

High-confidence dependency signals can be auto-applied after user confirmation:

- Next.js -> `nextjs`, `react`, `react-components`
- React -> `react`, `react-components`
- Vite -> `vite`
- Vitest -> `vitest`
- shadcn -> `shadcn`
- Prisma -> `prisma`
- Supabase -> `supabase`
- Better Auth -> `better-auth`
- Clerk/Next.js -> `clerk-nextjs`
- Stripe -> `stripe`
- Sentry/Next.js -> `sentry-nextjs`
- Cloudflare/Wrangler -> `cloudflare`
- OpenAPI file -> `api-contracts` toolchain

Intent-dependent capabilities remain optional:

- visual design/redesign
- motion
- web quality/performance audits
- View Transitions
- Cache Components migration
- Vercel production optimization
- long autonomy

Experimental capabilities require explicit opt-in.

## Principle

Universal means the stack can represent many project types. It does not mean every project receives every capability.

```text
AI Stack knows many capabilities
        |
        v
project detection + user intent
        |
        v
small relevant capability set
```
