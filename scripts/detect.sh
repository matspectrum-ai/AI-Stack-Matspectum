#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT/scripts/lib.sh"

PROJECT="."
FORMAT="human"

usage() {
  cat <<'EOF'
Usage: ai-stack detect [path] [--machine]

Detects project technologies and recommends the smallest relevant AI Stack
capability set. Detection is read-only: it never installs anything.

Options:
  --machine   Emit parseable plan lines for ai-stack apply
  -h, --help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --machine) FORMAT="machine" ;;
    -h|--help) usage; exit 0 ;;
    -* ) die "Unknown option: $1" ;;
    *) PROJECT="$1" ;;
  esac
  shift
done

[[ -d "$PROJECT" ]] || die "Project directory not found: $PROJECT"
PROJECT="$(cd -- "$PROJECT" && pwd -P)"

profiles=()
optional_profiles=()
experimental_profiles=()
toolchains=()
signals=()
notes=()

contains() {
  local needle="$1"
  shift || true
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

signal() { contains "$1" "${signals[@]}" || signals+=("$1"); }
profile() { contains "$1" "${profiles[@]}" || profiles+=("$1"); }
optional_profile() { contains "$1" "${optional_profiles[@]}" || optional_profiles+=("$1"); }
experimental_profile() { contains "$1" "${experimental_profiles[@]}" || experimental_profiles+=("$1"); }
toolchain() { contains "$1" "${toolchains[@]}" || toolchains+=("$1"); }
note() { contains "$1" "${notes[@]}" || notes+=("$1"); }

manifest_list="$(find "$PROJECT" -maxdepth 5 -type f -name package.json -not -path '*/node_modules/*' -not -path '*/.next/*' -print 2>/dev/null || true)"

package_has() {
  local dep="$1"
  local escaped manifest
  [[ -n "$manifest_list" ]] || return 1
  escaped="$(printf '%s' "$dep" | sed 's/[][(){}.*+?^$|\\/]/\\&/g')"
  while IFS= read -r manifest; do
    [[ -n "$manifest" ]] || continue
    if grep -Eq '"'"$escaped"'"[[:space:]]*:' "$manifest" 2>/dev/null; then
      return 0
    fi
  done <<EOF
$manifest_list
EOF
  return 1
}

has_file_glob() {
  local pattern="$1"
  find "$PROJECT" -maxdepth 5 -type f -path "$pattern" -print -quit 2>/dev/null | grep -q .
}

[[ -n "$manifest_list" ]] && signal "Node.js / package.json"
[[ -f "$PROJECT/pyproject.toml" || -f "$PROJECT/requirements.txt" ]] && { signal "Python"; note "Python project detected; use project-native pytest/ruff/type-checking. No generic Python mega-skill is auto-applied."; }
[[ -f "$PROJECT/Cargo.toml" ]] && { signal "Rust"; note "Rust project detected; cargo fmt/clippy/test remain deterministic verification sources."; }
[[ -f "$PROJECT/go.mod" ]] && { signal "Go"; note "Go project detected; gofmt/go vet/go test remain deterministic verification sources."; }

if package_has next; then
  signal "Next.js"
  profile nextjs
  profile react
  profile react-components
  optional_profile vercel-web-design
  optional_profile web-quality
  optional_profile web-performance
  optional_profile design
  optional_profile react-view-transitions
  note "next-dev-loop requires Next.js 16.3+ with Turbopack; verify the installed framework version before relying on runtime MCP checks."

  if grep -E 'cacheComponents[[:space:]]*:[[:space:]]*true' "$PROJECT"/next.config.* >/dev/null 2>&1; then
    signal "Next.js Cache Components"
    optional_profile nextjs-cache-optimize
  else
    optional_profile nextjs-cache-adoption
  fi
  if grep -E 'partialPrefetching[[:space:]]*:[[:space:]]*true' "$PROJECT"/next.config.* >/dev/null 2>&1; then
    signal "Next.js Partial Prefetching"
    profile nextjs-partial-prefetch
  fi
elif package_has react || package_has react-dom; then
  signal "React"
  profile react
  profile react-components
  optional_profile vercel-web-design
  optional_profile web-quality
  optional_profile web-performance
  optional_profile design
  optional_profile react-view-transitions
fi

if package_has vite || has_file_glob '*/vite.config.*'; then
  signal "Vite"
  profile vite
fi

if package_has vitest || has_file_glob '*/vitest.config.*'; then
  signal "Vitest"
  profile vitest
fi

if [[ -f "$PROJECT/components.json" ]] || has_file_glob '*/components.json'; then
  signal "shadcn/ui"
  profile shadcn
fi

if package_has '@prisma/client' || package_has prisma || [[ -f "$PROJECT/prisma/schema.prisma" ]]; then
  signal "Prisma"
  profile prisma
fi

if package_has drizzle-orm || package_has drizzle-kit || has_file_glob '*/drizzle.config.*'; then
  signal "Drizzle"
  experimental_profile drizzle-experimental
fi

if package_has '@supabase/supabase-js' || package_has '@supabase/ssr' || [[ -d "$PROJECT/supabase" ]]; then
  signal "Supabase"
  profile supabase
fi

if package_has better-auth; then
  signal "Better Auth"
  profile better-auth
fi

if package_has '@clerk/nextjs'; then
  signal "Clerk + Next.js"
  profile clerk-nextjs
fi

if package_has stripe; then
  signal "Stripe"
  profile stripe
fi

if package_has '@sentry/nextjs'; then
  signal "Sentry + Next.js"
  profile sentry-nextjs
fi

if package_has wrangler || [[ -f "$PROJECT/wrangler.toml" || -f "$PROJECT/wrangler.json" || -f "$PROJECT/wrangler.jsonc" ]]; then
  signal "Cloudflare Workers"
  profile cloudflare
  if package_has agents; then
    signal "Cloudflare Agents SDK"
    profile cloudflare-agents
  fi
fi

if [[ -f "$PROJECT/vercel.json" || -d "$PROJECT/.vercel" ]]; then
  signal "Vercel project"
  toolchain vercel-cli
  optional_profile vercel-optimize
fi

if find "$PROJECT" -maxdepth 5 -type f \( -iname 'openapi.yaml' -o -iname 'openapi.yml' -o -iname 'openapi.json' -o -iname 'swagger.yaml' -o -iname 'swagger.yml' -o -iname 'swagger.json' \) -print -quit 2>/dev/null | grep -q .; then
  signal "OpenAPI contract"
  toolchain api-contracts
fi

if package_has '@playwright/test' || package_has playwright; then
  signal "Playwright"
  note "Playwright detected. Ensure workstation browser tooling exists with: ai-stack bootstrap --with-browser"
fi

optional_profile long-autonomy

if [[ "$FORMAT" == "machine" ]]; then
  for item in "${profiles[@]}"; do printf 'profile:%s\n' "$item"; done
  for item in "${optional_profiles[@]}"; do printf 'optional-profile:%s\n' "$item"; done
  for item in "${experimental_profiles[@]}"; do printf 'experimental-profile:%s\n' "$item"; done
  for item in "${toolchains[@]}"; do printf 'toolchain:%s\n' "$item"; done
  for item in "${signals[@]}"; do printf 'signal:%s\n' "$item"; done
  for item in "${notes[@]}"; do printf 'note:%s\n' "$item"; done
  exit 0
fi

printf 'AI Stack capability detection\n\n'
printf 'Project: %s\n' "$PROJECT"

printf '\nDetected signals:\n'
if [[ ${#signals[@]} -eq 0 ]]; then printf '  (no known stack signals detected)\n'; else printf '  + %s\n' "${signals[@]}"; fi

printf '\nRecommended project profiles (high confidence):\n'
if [[ ${#profiles[@]} -eq 0 ]]; then printf '  (none)\n'; else printf '  %s\n' "${profiles[@]}"; fi

printf '\nOptional capabilities (intent-dependent):\n'
if [[ ${#optional_profiles[@]} -eq 0 ]]; then printf '  (none)\n'; else printf '  %s\n' "${optional_profiles[@]}"; fi

if [[ ${#experimental_profiles[@]} -gt 0 ]]; then
  printf '\nExperimental capabilities (never auto-applied):\n'
  printf '  %s\n' "${experimental_profiles[@]}"
fi

printf '\nDeterministic toolchains:\n'
if [[ ${#toolchains[@]} -eq 0 ]]; then printf '  (none)\n'; else printf '  %s\n' "${toolchains[@]}"; fi

if [[ ${#notes[@]} -gt 0 ]]; then
  printf '\nNotes:\n'
  for item in "${notes[@]}"; do printf '  - %s\n' "$item"; done
fi

printf '\nNext:\n'
printf '  ai-stack apply "%s"        # preview + install high-confidence recommendations\n' "$PROJECT"
printf '  ai-stack apply "%s" --include-optional\n' "$PROJECT"
