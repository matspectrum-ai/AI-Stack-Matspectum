# AI Stack Matspectrum

A portable, open-source-first AI engineering stack for software development.

The stack is capability-centric, not product-centric: a Next.js app, API, dashboard, CLI, library, fintech system, e-commerce project or SaaS is composed from the framework, data, design, testing, security and infrastructure capabilities it actually uses.

## Architecture

```text
Human intent
   |
   v
OpenCode (default harness)
   |
   +-- AGENTS.md / repository context
   +-- portable Agent Skills
   +-- capability profiles selected per project
   +-- deterministic CLI toolchains
   +-- project-native tests / lint / typecheck
   +-- Playwright + agent-browser verification
   +-- optional OpenSpec for formal SDD
   +-- optional Pi for harness experiments
   |
   v
Evidence -> review -> Git
```

Principles:

- Open source tools first.
- Harness-neutral repository context where possible.
- Single strong agent + good tools before multi-agent orchestration.
- Skills are organized by capability/domain instead of one giant global pack.
- Detection is conservative: dependencies can be detected; user intent cannot.
- Deterministic verification beats "the model says it is done".
- CLI + Skill is preferred when an existing CLI already solves the integration.
- MCP is reserved for remote/structured integrations that actually need it.
- Long-running autonomy must have gates, budgets and stop conditions.
- Third-party skills are executable dependencies: inspect source, license, scripts and permissions.
- Experimental surfaces are marked experimental instead of silently becoming defaults.

## Quick start

Requirements: Linux/macOS, Git, Node.js 20+ and npm. OpenSpec specifically requires Node.js 20.19+.

```bash
git clone https://github.com/matspectrum-ai/AI-Stack-Matspectum.git
cd AI-Stack-Matspectum

./ai-stack bootstrap --full
./ai-stack doctor
```

Then connect your provider inside OpenCode:

```bash
opencode
```

Use `/connect` in the TUI. The repository does not store API keys or replace an existing provider configuration.

## Project workflow

Instead of manually collecting skills, inspect a real project:

```bash
cd ~/projects/my-app
ai-stack detect .
```

Example output can recommend only the capabilities actually detected:

```text
Next.js
React
Prisma
Vitest
shadcn/ui
OpenAPI

Recommended profiles:
  nextjs
  react
  react-components
  prisma
  vitest
  shadcn

Toolchains:
  api-contracts
```

Preview and apply high-confidence recommendations:

```bash
ai-stack apply .
```

Include intent-dependent capabilities such as design, web-quality or View Transitions only when desired:

```bash
ai-stack apply . --include-optional
```

Experimental profiles are never auto-applied:

```bash
ai-stack apply . --include-experimental
```

## Commands

```bash
ai-stack bootstrap [options]
ai-stack doctor
ai-stack detect [path]
ai-stack apply [path] [options]
ai-stack profile <name|list> [--project]
ai-stack toolchain <name|list>
ai-stack init [path] [--sdd]
```

Profiles install contextual Agent Skills. Toolchains install deterministic CLI capabilities. They are intentionally separate concepts.

## Capability profiles

List all profiles:

```bash
ai-stack profile list
```

### Workflow

- `core` — Matt Pocock debugging, TDD, review and handoff workflows.
- `long-autonomy` — Unlazy observable completion gates.
- `security` — Trail of Bits context-first audit + Semgrep.

### Next.js

- `nextjs` — official `vercel/next.js` `next-dev-loop` runtime verification.
- `nextjs-cache-adoption` — adopt Cache Components.
- `nextjs-cache-optimize` — test-driven instant shell/navigation optimization.
- `nextjs-partial-prefetch` — adopt/verify Partial Prefetching.

`nextjs` is the normal project profile. The other three are task-specific and should not be loaded just because a project uses Next.js.

### React / Vercel engineering

The Vercel Labs skill pack is exposed as separate capabilities rather than installed wholesale:

- `react` — `vercel-react-best-practices`: React/Next performance, async/data/rendering and bundle guidance.
- `react-components` — `vercel-composition-patterns`: compound components, state lifting and scalable component APIs.
- `react-view-transitions` — native React/Next View Transition patterns.
- `vercel-web-design` — Vercel Web Interface Guidelines audit for UI/UX/accessibility.
- `vercel-optimize` — metrics-first optimization for a deployed Vercel project.

`react` and `react-components` are high-confidence recommendations when React is detected. The design audit, View Transitions and Vercel production optimization remain opt-in.

License note: the individual React/composition/View Transition manifests declare MIT. `vercel-labs/agent-skills` also declares MIT in its README, but its top-level LICENSE-file hygiene is still unresolved as of August 2026. `web-design-guidelines` fetches its rules from the separate MIT-licensed `vercel-labs/web-interface-guidelines` repository. AI Stack does not vendor or relicense this content.

### Design / UI

- `design` — Anthropic Frontend Design + Impeccable + Taste, routed by intent.
- `design-redesign` — existing-product redesign/refinement.
- `motion` — Emil Kowalski animation implementation/review.
- `shadcn` — official shadcn/ui guidance.
- `vercel-web-design` — interface-quality audit, not generative visual direction.
- `react-components` — component architecture, not visual styling.

Do not invoke every design skill for every frontend task.

### Testing / quality

- `vitest` — Vitest configuration, mocking, coverage and tests.
- `web-quality` — broad evidence-led web quality audit.
- `web-performance` — focused web performance optimization.

Normal tests, lint, typecheck, browser/E2E evidence and contract checks remain the authoritative completion gates.

### Backend / data

- `database-postgres` — generic Postgres best practices.
- `supabase` — Supabase products + Postgres guidance.
- `prisma` — official Prisma CLI, Client API and database setup skills.
- `drizzle-experimental` — project-bundled Drizzle Kit skills; explicit experimental opt-in.

### Auth / billing / observability

- `better-auth`
- `clerk-nextjs`
- `stripe`
- `sentry-nextjs`

These are provider-specific and should normally be project-local.

### Platform / infrastructure

- `cloudflare` — Cloudflare platform + Workers best practices.
- `cloudflare-agents` — Cloudflare Agents SDK.
- `vercel-optimize` — Vercel production metrics/cost/performance audit.

For deterministic Vercel operations use the open-source Vercel CLI toolchain:

```bash
ai-stack toolchain vercel-cli
```

## API engineering

API engineering is contract-first rather than based on a generic "API expert" prompt.

```bash
ai-stack toolchain api-contracts
```

The toolchain uses:

- Spectral for OpenAPI linting.
- OpenAPI Generator CLI for validation/code generation when appropriate.
- oasdiff when Go is available for breaking-change checks.
- Schemathesis as a recommended optional property-based runtime verifier.

See [`docs/API-CONTRACTS.md`](docs/API-CONTRACTS.md).

## Browser verification

```bash
ai-stack bootstrap --with-browser
```

Installs two different layers:

- Playwright CLI/browser skills for persistent E2E/regression evidence.
- `agent-browser` for interactive/runtime agent inspection.

The Next.js `next-dev-loop` uses `agent-browser` together with Next.js runtime introspection.

## Context / SDD

Initialize portable repository context without overwriting existing files:

```bash
ai-stack init ~/projects/my-app
```

With optional OpenSpec initialization:

```bash
ai-stack bootstrap --with-sdd
ai-stack init ~/projects/my-app --sdd
```

Formal SDD is not forced onto trivial tasks; acceptance criteria + deterministic verification are often enough.

## Pi

OpenCode is the default daily-driver harness. Pi remains an optional minimal alternative and harness-engineering laboratory:

```bash
ai-stack bootstrap --with-pi
pi
```

The portable `.agents/skills` layer targets both when Pi is installed.

## What is deliberately not universal

The core does not automatically install:

- BMAD / Superpowers / heavy SDLC frameworks
- LangGraph / CrewAI / AutoGen
- agent swarms
- large MCP packs
- repository-wide vector-memory/RAG
- arbitrary mega skill packs
- infinite Ralph loops
- provider/framework context unrelated to the project
- experimental ORM releases merely to obtain agent integrations

These can be added when a concrete problem justifies the complexity.

## Repository layout

```text
.
├── ai-stack
├── AGENTS.md
├── docs/
│   ├── API-CONTRACTS.md
│   ├── ARCHITECTURE.md
│   ├── CAPABILITIES.md
│   ├── PROFILES.md
│   └── SECURITY.md
├── profiles/
├── scripts/
│   ├── detect.sh
│   ├── apply.sh
│   └── ...
└── templates/
```

See [`docs/CAPABILITIES.md`](docs/CAPABILITIES.md) for the routing/detection model.

## License

The original code and documentation in this repository are MIT licensed. Third-party tools and skills retain their own licenses; this project installs them from upstream sources and does not relicense them.
