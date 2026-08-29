# AI Stack Matspectrum

A portable, open-source-first AI engineering stack for software development.

The goal is not to install every agent framework. It is to provide a small universal core and add domain skills only when a project needs them.

## Architecture

```text
Human intent
   |
   v
OpenCode (default harness)
   |
   +-- AGENTS.md / repository context
   +-- portable Agent Skills
   +-- CLI tools
   +-- project-native tests / lint / typecheck
   +-- Playwright CLI for browser verification
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

## Skill profiles

List profiles:

```bash
./ai-stack profile list
```

Install globally for OpenCode (and Pi too when Pi is installed):

```bash
./ai-stack profile core
./ai-stack profile design
./ai-stack profile long-autonomy
./ai-stack profile database-postgres
./ai-stack profile security
./ai-stack profile motion
```

Install a profile into one project instead of globally:

```bash
cd ~/projects/my-app
/path/to/AI-Stack-Matspectum/ai-stack profile design --project
```

Profiles intentionally overlap as little as possible.

### Core

Stable workflow skills used across most software projects:

- `mattpocock/skills`: `diagnosing-bugs`
- `mattpocock/skills`: `tdd`
- `mattpocock/skills`: `code-review`
- `mattpocock/skills`: `handoff`

### Design

Complementary UI/design capabilities:

- `anthropics/skills`: `frontend-design` — original UI direction.
- `pbakaus/impeccable`: `impeccable` — product UI critique/refinement.
- `leonxlnx/taste-skill`: `design-taste-frontend` — landing/marketing/high-end visual work.

Do not invoke all three for every frontend task. Route by intent.

### Long autonomy

- `leonxlnx/unlazy`: `unlazy`

Use on substantial tasks where completion needs observable gates. Do not make every small edit produce a gate ledger.

### Database / Postgres

- `supabase/agent-skills`: `supabase-postgres-best-practices`

Useful for Postgres schema, RLS, indexing, query and performance work. It is not a generic backend skill.

### Security

- `trailofbits/skills`: `audit-context-building`
- `trailofbits/skills`: `semgrep`

Security scanning can execute commands and clone rulesets. Review the skill and scan plan before approval.

### Motion

- `emilkowalski/skills`: `animate`
- `emilkowalski/skills`: `review-animations`

Use only for interfaces where motion is a real requirement.

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

Install Playwright's agent CLI:

```bash
./ai-stack bootstrap --with-browser
```

This installs `@playwright/cli` and its agent skills. Use it interactively for visual/browser feedback while keeping normal Playwright tests in the target project's own test suite.

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
├── profiles/
├── scripts/
└── templates/
```

See `docs/ARCHITECTURE.md` for the design rationale and `docs/SECURITY.md` for the skill supply-chain policy.

## License

The original code and documentation in this repository are MIT licensed. Third-party tools and skills retain their own licenses; this project installs them from their upstream sources and does not relicense them.
