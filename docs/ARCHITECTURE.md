# Architecture

## Goal

The stack is designed as a portable substrate for AI-assisted software engineering, not a monolithic agent framework.

```text
Intent / acceptance criteria
          |
          v
      Harness
    (OpenCode)
          |
  +-------+--------+
  |       |        |
Context  Skills   Tools
  |       |        |
  +-------+--------+
          |
          v
   Implementation
          |
          v
 Deterministic verification
          |
          v
 Review / evidence / Git
```

## Why OpenCode is the default

OpenCode gives a broad operational baseline: terminal harness, provider abstraction, code intelligence, skills, permissions, plugins and server/client primitives. That reduces the amount of custom harness work needed before productive software development starts.

Pi remains optional because its smaller core and extension API are valuable when the work is harness engineering itself.

The portable layer must not depend on either choice.

## Context engineering

Always-loaded context should stay small.

- `AGENTS.md`: stable operational rules and constraints.
- `CONTEXT.md`: system/domain mental model.
- ADRs: durable rationale for costly decisions.
- Skills: procedural/domain knowledge loaded on demand.
- Source/tests/tool output: retrieved only when relevant.

A large context window is capacity, not a target fill level.

## Skills

Skills are split along two axes.

Workflow:
- debugging
- TDD
- review
- handoff
- long-running completion gates

Domain:
- UI/design
- Postgres
- security
- motion

A task may combine one workflow skill and one domain skill. That does not imply a multi-agent architecture.

## Tools

Prefer the simplest interface with good observability:

1. project-native CLI/script,
2. CLI + Skill,
3. MCP for remote structured integrations,
4. custom tool/plugin only when the previous levels are insufficient.

## Verification

Preferred order from cheap/deterministic to expensive/judgment-based:

```text
format/lint
  -> typecheck/static analysis
  -> unit tests
  -> integration/contract tests
  -> browser/E2E
  -> specialized security/performance checks
  -> LLM review
  -> human review
```

Never use an LLM reviewer as a substitute for a deterministic check that already exists.

## SDD

SDD is adaptive:

- tiny change: explicit observable outcome,
- normal feature: acceptance criteria + implementation plan,
- cross-system/high-risk change: OpenSpec or another formal change/spec workflow.

OpenSpec is optional by design.

## Loops and graphs

Do not add a loop framework merely to repeat an agent.

A bounded loop needs:
- explicit goal,
- state,
- verifier,
- max iterations/time/cost,
- escalation/stop condition.

A graph layer is justified only when work requires explicit routing, joins, parallel branches, persistent state or human gates.

## Isolation

For highly autonomous or untrusted execution, use an OS/container boundary such as rootless Podman in addition to harness permissions. A permission prompt is not a sandbox.

## Portability invariant

Important engineering state belongs in the repository or open skill format, not only in a proprietary session database:

```text
AGENTS.md
CONTEXT.md
ADRs
specs
tests
contracts
skills
CLI contracts
```

This allows the harness/model to change without rebuilding the engineering process.
