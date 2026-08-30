#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT/scripts/lib.sh"

PROJECT="."
ASSUME_YES=0
INCLUDE_OPTIONAL=0
INCLUDE_EXPERIMENTAL=0

usage() {
  cat <<'EOF'
Usage: ai-stack apply [path] [options]

Detects a project's stack, previews the plan, and installs only the relevant
project-local capability profiles and deterministic toolchains.

Default behavior:
  - installs high-confidence detected profiles
  - installs detected deterministic toolchains
  - does NOT install optional/intent-dependent capabilities
  - NEVER installs experimental capabilities unless explicitly requested

Options:
  --yes                   Skip confirmation
  --include-optional      Include optional profiles such as design/web-quality
  --include-experimental  Include experimental profiles (for example Drizzle)
  -h, --help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|-y) ASSUME_YES=1 ;;
    --include-optional) INCLUDE_OPTIONAL=1 ;;
    --include-experimental) INCLUDE_EXPERIMENTAL=1 ;;
    -h|--help) usage; exit 0 ;;
    -* ) die "Unknown option: $1" ;;
    *) PROJECT="$1" ;;
  esac
  shift
done

[[ -d "$PROJECT" ]] || die "Project directory not found: $PROJECT"
PROJECT="$(cd -- "$PROJECT" && pwd -P)"
home_dir="$(cd -- "$HOME" && pwd -P)"
[[ "$PROJECT" != "$home_dir" ]] || die "Refusing to apply project profiles directly to HOME. cd into a real project or pass its path."

plan="$($ROOT/scripts/detect.sh "$PROJECT" --machine)"

profiles=()
optional_profiles=()
experimental_profiles=()
toolchains=()
notes=()

while IFS= read -r line; do
  [[ -n "$line" ]] || continue
  case "$line" in
    profile:*) profiles+=("${line#profile:}") ;;
    optional-profile:*) optional_profiles+=("${line#optional-profile:}") ;;
    experimental-profile:*) experimental_profiles+=("${line#experimental-profile:}") ;;
    toolchain:*) toolchains+=("${line#toolchain:}") ;;
    note:*) notes+=("${line#note:}") ;;
  esac
done <<EOF
$plan
EOF

printf 'AI Stack apply plan\n\n'
printf 'Project: %s\n' "$PROJECT"

printf '\nProfiles to install:\n'
if [[ ${#profiles[@]} -eq 0 ]]; then printf '  (none)\n'; else printf '  %s\n' "${profiles[@]}"; fi

if [[ "$INCLUDE_OPTIONAL" -eq 1 ]]; then
  printf '\nOptional profiles included:\n'
  if [[ ${#optional_profiles[@]} -eq 0 ]]; then printf '  (none)\n'; else printf '  %s\n' "${optional_profiles[@]}"; fi
else
  printf '\nOptional profiles skipped (use --include-optional):\n'
  if [[ ${#optional_profiles[@]} -eq 0 ]]; then printf '  (none)\n'; else printf '  %s\n' "${optional_profiles[@]}"; fi
fi

if [[ ${#experimental_profiles[@]} -gt 0 ]]; then
  if [[ "$INCLUDE_EXPERIMENTAL" -eq 1 ]]; then
    printf '\nExperimental profiles INCLUDED by explicit request:\n'
  else
    printf '\nExperimental profiles skipped (use --include-experimental):\n'
  fi
  printf '  %s\n' "${experimental_profiles[@]}"
fi

printf '\nToolchains to ensure:\n'
if [[ ${#toolchains[@]} -eq 0 ]]; then printf '  (none)\n'; else printf '  %s\n' "${toolchains[@]}"; fi

if [[ ${#notes[@]} -gt 0 ]]; then
  printf '\nNotes:\n'
  for item in "${notes[@]}"; do printf '  - %s\n' "$item"; done
fi

if [[ "$ASSUME_YES" -ne 1 ]]; then
  printf '\nApply this plan? [y/N] '
  read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) info "No changes applied."; exit 0 ;;
  esac
fi

cd -- "$PROJECT"

for item in "${profiles[@]}"; do
  "$ROOT/scripts/profile.sh" "$item" --project
done

if [[ "$INCLUDE_OPTIONAL" -eq 1 ]]; then
  for item in "${optional_profiles[@]}"; do
    "$ROOT/scripts/profile.sh" "$item" --project
  done
fi

if [[ "$INCLUDE_EXPERIMENTAL" -eq 1 ]]; then
  for item in "${experimental_profiles[@]}"; do
    "$ROOT/scripts/profile.sh" "$item" --project
  done
fi

for item in "${toolchains[@]}"; do
  "$ROOT/scripts/toolchain.sh" "$item"
done

printf '\n'
ok "Detected AI Stack capabilities applied to: $PROJECT"
info "Open OpenCode from this project directory so project-local skills are discovered."
