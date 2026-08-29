# AGENTS.md

## Purpose

This repository packages a portable open-source-first AI engineering workstation stack. Changes must preserve portability, inspectability and low coupling to any single coding harness.

## Engineering rules

1. Keep OpenCode as the default harness unless evidence justifies changing the default.
2. Keep Pi optional and usable as an alternate/minimal harness.
3. Prefer open standards and portable files (`AGENTS.md`, Agent Skills, CLI contracts, tests).
4. Do not vendor third-party skills unless there is a specific reproducibility/security reason.
5. Do not add a skill to a default profile without checking:
   - upstream repository and maintainer,
   - license,
   - adoption signal,
   - executable scripts / shell directives,
   - network and secret access,
   - overlap with skills already in the profile.
6. Do not add an MCP server if an existing CLI + skill is sufficient.
7. Do not add a multi-agent or graph framework without a concrete workflow that requires routing, parallelism, persistence or isolated context.
8. Scripts must be idempotent where practical and must not overwrite user configuration without explicit consent.
9. Never write API keys, tokens or secrets into this repository.
10. A bootstrap failure should explain the missing prerequisite and stop; do not silently improvise privileged system changes.

## Verification

Before considering a change complete:

```bash
bash -n ai-stack scripts/*.sh
./ai-stack doctor
```

`doctor` is allowed to report optional components as missing.

## Shell style

- Bash with `set -Eeuo pipefail`.
- Quote variable expansions.
- Prefer explicit functions and readable error messages.
- No `curl | sh` in our own bootstrap when a package-manager install is available.
