# AI Stack Matspectrum

A portable, open-source-first AI engineering stack for software development.

The goal is not to install every agent framework. It is to provide a small universal core and add domain skills or deterministic toolchains only when a project needs them.

## Architecture

```text
Human intent
   |
   v
OpenCode (default harness)
   |
   +-- AGENTS.md / repository context
   +-- portable Agent Skills
   +-- framework/provider profiles
   +-- deterministic CLI toolchains
   +-- project-native tests / lint / typecheck
   +-- Playwright CLI for persistent E2E verification
   +-- agent-browser for interactive/runtime verification
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
- Domain skills are opt-in profiles, not one giant global prompt.
- Deterministic verification beats "the model says it is done".
- CLI + Skill is preferred when an existing CLI already solves the integration.
- MCP is reserved for remote/structured integrations that actually need it.
- Long-running autonomy must have gates, budgets and stop conditions.
- Third-party skills are dependencies: inspect source, license, scripts and permissions.
- Official but immature agent surfaces are marked experimental instead of being promoted to defaults.

## Quick start

Requirements: Linux/macOS, Git, Node.js 20+ and npm. OpenSpec specifically requires Node.js 20.19+.

```bash
git clone https://github.com/matspectrum-ai/AI-Stack-Matspectum.git
cd AI-Stack-Matspectum

# Core: OpenCode + core engineering skills
./ai-stack bootstrap

# Full recommended workstation stack in one command
./ai-stack bootstrap --full

# Or compose it explicitly
./ai-stack bootstrap --with-pi --with-browser --with-sdd

# Verify the installation
./ai-stack doctor
```

Then connect your model/provider inside OpenCode:

```bash
opencode
```

Use `/connect` in the TUI. This repository deliberately does not write API keys or replace your existing OpenCode configuration.

## Commands

```bash
ai-stack bootstrap [options]
ai-stack doctor
ai-stack profile <name|list> [--project]
ai-stack toolchain <name|list>
ai-stack init [path] [--sdd]
```

Profiles install contextual Agent Skills. Toolchains install deterministic CLIs. They are intentionally separate concepts.

## Skill profiles

List profiles:

```bash
./ai-stack profile list
```

Universal/workflow profiles:

```bash
./ai-stack profile core
./ai-stack profile long-autonomy
./ai-stack profile security
```

Framework/domain/provider profiles should usually be installed per project:

```bash
cd ~/projects/my-app
ai-stack profile nextjs --project
ai-stack profile prisma --project
ai-stack profile supabase --project
ai-stack profile cloudflare --project
ai-stack profile better-auth --project
ai-stack profile clerk-nextjs --project
ai-stack profile stripe --project
ai-stack profile sentry-nextjs --project
```

See [`docs/PROFILES.md`](docs/PROFILES.md) for maturity labels and the full routing matrix.

### Core

Stable workflow skills used across most software projects:

- `mattpocock/skills`: `diagnosing-bugs`
- `mattpocock/skills`: `tdd`
- `mattpocock/skills`: `code-review`
- `mattpocock/skills`: `handoff`

### Next.js

The `nextjs` profile installs the official `vercel/next.js` `next-dev-loop` workflow skill.

```bash
ai-stack profile nextjs --project
```

Current `next-dev-loop` is intended for Next.js 16.3+ and combines Next.js runtime introspection with `agent-browser`.

### Backend / ORM

Prisma uses the official Prisma Agent Skills:

```bash
ai-stack profile prisma --project
```

This installs focused CLI, Client API and database-setup skills rather than the whole Prisma catalog.

Drizzle's Agent Skills are official but still tied to its evolving RC/next-generation Drizzle Kit surface, so the stack marks them experimental and only invokes the project's own local CLI:

```bash
ai-stack profile drizzle-experimental --project
```

The stack will not silently install a new/RC Drizzle version just to obtain skills.

### Supabase / Postgres

Generic Postgres only:

```bash
ai-stack profile database-postgres --project
```

Full Supabase project:

```bash
ai-stack profile supabase --project
```

### Infrastructure / platform

Cloudflare has an official Apache-2.0 Agent Skills repository:

```bash
ai-stack profile cloudflare --project
```

For projects specifically using Cloudflare Agents SDK:

```bash
ai-stack profile cloudflare-agents --project
```

For Vercel deployment, the strict OSS stack uses the Apache-2.0 Vercel CLI rather than vendoring the current `vercel-labs/agent-skills` repository, whose top-level license-file hygiene is still unresolved:

```bash
ai-stack toolchain vercel-cli
```

### Observability

For a Next.js application using Sentry:

```bash
ai-stack profile sentry-nextjs --project
```

This installs official Sentry Next.js setup, tracing and logging guidance. Production issue-fixing skills that require Sentry MCP access are deliberately not enabled by default.

### Authentication

Better Auth:

```bash
ai-stack profile better-auth --project
```

Clerk + Next.js:

```bash
ai-stack profile clerk-nextjs --project
```

Do not install both unless you are intentionally migrating auth systems.

### Stripe

```bash
ai-stack profile stripe --project
```

This installs Stripe's official Agent Skills from `https://docs.stripe.com`. It is not part of the universal core because many SaaS/payment systems do not use Stripe.

### Design

Complementary UI/design capabilities:

- `anthropics/skills`: `frontend-design` — original UI direction.
- `pbakaus/impeccable`: `impeccable` — product UI critique/refinement.
- `leonxlnx/taste-skill`: `design-taste-frontend` — landing/marketing/high-end visual work.

Do not invoke all three for every frontend task. Route by intent.

### Long autonomy

- `leonxlnx/unlazy`: `unlazy`

Use on substantial tasks where completion needs observable gates. Do not make every small edit produce a gate ledger.

### Security

- `trailofbits/skills`: `audit-context-building`
- `trailofbits/skills`: `semgrep`

Security scanning can execute commands and clone rulesets. Review the skill and scan plan before approval.

## SaaS / full-stack composition

There is intentionally no giant generic "SaaS expert" skill. A SaaS is composed from the technologies it actually uses.

For a provider-neutral Next.js SaaS base:

```bash
ai-stack profile saas-nextjs --project
```

Then choose only the relevant pieces:

```bash
# Data/backend: choose what the project uses
ai-stack profile supabase --project
# OR
ai-stack profile prisma --project
# OR, only with compatible project-local Drizzle Kit
ai-stack profile drizzle-experimental --project

# Auth: choose one normal path
ai-stack profile better-auth --project
# OR
ai-stack profile clerk-nextjs --project

# Optional providers/capabilities
ai-stack profile stripe --project
ai-stack profile sentry-nextjs --project
ai-stack profile cloudflare --project
ai-stack profile design --project
ai-stack profile shadcn --project

# Public/API-heavy systems
ai-stack toolchain api-contracts
```

This is deliberately compositional: framework knowledge, database/auth/billing/infra knowledge and verification remain independent.

## Deterministic toolchains

List toolchains:

```bash
ai-stack toolchain list
```

### API contracts

```bash
ai-stack toolchain api-contracts
```

This installs:

- Spectral for OpenAPI linting.
- OpenAPI Generator CLI for validation and optional SDK/server generation.
- oasdiff automatically when Go is available, for breaking-change detection.

Schemathesis is recommended for property-based API testing but remains an explicit Python dependency rather than being silently installed.

See [`docs/API-CONTRACTS.md`](docs/API-CONTRACTS.md).

### Vercel CLI

```bash
ai-stack toolchain vercel-cli
```

The CLI is open source. Production deployment remains an external side effect and should always require explicit approval.

## SDD

Formal SDD is optional. The default stack does not force a large planning framework on every task.

Install OpenSpec:

```bash
./ai-stack bootstrap --with-sdd
```

Initialize it only in projects that benefit from change/spec tracking:

```bash
cd ~/projects/my-app
openspec init
```

For small tasks, acceptance criteria + tests are usually sufficient.

## Initialize an existing project

This command adds only missing portable context templates; it will never replace an existing `AGENTS.md` or `CONTEXT.md`.

```bash
./ai-stack init ~/projects/my-app
```

For a project that should also use OpenSpec:

```bash
./ai-stack init ~/projects/my-app --sdd
```

Then edit the generated files. Generic templates should not remain generic.

## Browser verification

Install both browser layers:

```bash
./ai-stack bootstrap --with-browser
```

This installs:

- `@playwright/cli` + Playwright agent skills/browser
- `agent-browser` + its Chrome runtime

On Linux, if `agent-browser install` reports missing system libraries, run:

```bash
agent-browser install --with-deps
```

Use browser exploration for feedback while keeping normal Playwright tests in the target project's own test suite.

## Pi

Pi is optional. OpenCode is the default daily-driver harness; Pi is included as a minimal alternative and harness-engineering laboratory.

```bash
./ai-stack bootstrap --with-pi
pi
```

The portable skill layer is targeted at both harnesses when Pi is present.

## What is deliberately NOT installed

- BMAD by default
- Superpowers by default
- LangGraph/CrewAI/AutoGen
- swarm or "company of agents" presets
- large MCP packs
- vector-memory/RAG for every repository
- arbitrary mega skill packs
- infinite Ralph loops
- framework/provider skills globally when the project does not use them
- unstable ORM releases merely to obtain agent integrations

Those can be justified by a concrete problem later. They are not universal prerequisites.

## Update skills

```bash
npx skills update -g -y
```

Review upstream changes before using updated skills in sensitive workflows.

## Repository layout

```text
.
├── ai-stack
├── AGENTS.md
├── docs/
│   ├── API-CONTRACTS.md
│   ├── ARCHITECTURE.md
│   ├── PROFILES.md
│   └── SECURITY.md
├── profiles/
├── scripts/
└── templates/
```

See `docs/ARCHITECTURE.md` for design rationale, `docs/PROFILES.md` for profile composition, `docs/API-CONTRACTS.md` for contract-driven API verification, and `docs/SECURITY.md` for the skill/tool supply-chain policy.

## License

The original code and documentation in this repository are MIT licensed. Third-party tools and skills retain their own licenses; this project installs them from their upstream sources and does not relicense them.
