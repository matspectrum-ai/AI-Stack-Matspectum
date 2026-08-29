# Security and Skill Supply Chain

Agent Skills can contain shell directives, scripts and network operations. Treat them as executable dependencies.

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

### Financial/payment operations

A Stripe/payment skill does not imply permission to perform financial mutations. Treat operations such as charging, refunding, canceling subscriptions, finalizing invoices, changing payout settings or modifying production payment configuration as approval-gated actions.

Prefer:
- test/sandbox environments by default,
- restricted credentials/scopes,
- idempotency keys for retryable payment mutations,
- explicit human approval before irreversible or monetary actions,
- webhook/contract tests before production changes.

## Updates

`npx skills update` changes executable/procedural dependencies. Do not assume an updated skill has identical behavior.

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
