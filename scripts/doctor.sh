#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT/scripts/lib.sh"

required_fail=0

check_required() {
  local cmd="$1"
  local label="${2:-$1}"
  if has "$cmd"; then
    ok "$label: $(command -v "$cmd")"
  else
    warn "$label: missing"
    required_fail=1
  fi
}

check_optional() {
  local cmd="$1"
  local label="${2:-$1}"
  if has "$cmd"; then
    ok "$label: $(command -v "$cmd")"
  else
    warn "$label: not installed (optional)"
  fi
}

echo "AI Stack Matspectrum doctor"
echo

check_required git Git
check_required node Node.js
check_required npm npm
check_required opencode OpenCode

if has node; then
  echo "    Node version: $(node --version)"
fi
if has opencode; then
  echo "    OpenCode version: $(opencode --version 2>/dev/null || echo unknown)"
fi

check_optional pi "Pi"
check_optional openspec "OpenSpec"
check_optional playwright-cli "Playwright CLI"
check_optional agent-browser "agent-browser"
check_optional podman "Podman"
check_optional just "just"
check_optional rg "ripgrep"
check_optional jq "jq"

echo
printf '%s\n' "Optional API/deployment toolchains:"
check_optional spectral "Spectral"
check_optional openapi-generator-cli "OpenAPI Generator CLI"
check_optional java "Java (OpenAPI Generator runtime)"
check_optional oasdiff "oasdiff"
check_optional go "Go (optional oasdiff installer)"
check_optional vercel "Vercel CLI"

echo
if [[ -d "$HOME/.config/opencode/skills" ]]; then
  count="$(find "$HOME/.config/opencode/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)"
  ok "OpenCode global skills directory exists ($count directories)"
else
  warn "No OpenCode global skills directory yet"
fi

if [[ -d "$HOME/.pi/agent/skills" ]]; then
  count="$(find "$HOME/.pi/agent/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)"
  ok "Pi global skills directory exists ($count directories)"
fi

echo
if [[ "$required_fail" -eq 0 ]]; then
  ok "Required core is ready."
else
  die "Required core has missing components. Run './ai-stack bootstrap'."
fi
