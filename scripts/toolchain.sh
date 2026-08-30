#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT/scripts/lib.sh"

TOOLCHAIN="${1:-list}"
shift || true

list_toolchains() {
  cat <<'EOF'
Available toolchains:
  api-contracts   Spectral OpenAPI lint + OpenAPI Generator; oasdiff when Go is available
  vercel-cli      Apache-2.0 Vercel CLI for preview/deployment workflows

Toolchains are deterministic CLI capabilities, not Agent Skills.
They are opt-in because not every project needs them.
EOF
}

[[ "$TOOLCHAIN" == "list" ]] && { list_toolchains; exit 0; }
[[ "$TOOLCHAIN" == "help" || "$TOOLCHAIN" == "-h" || "$TOOLCHAIN" == "--help" ]] && { list_toolchains; exit 0; }
[[ $# -eq 0 ]] || die "Unexpected arguments: $*"

has npm || die "npm is required."

install_api_contracts() {
  if ! has spectral; then
    npm_global_install "@stoplight/spectral-cli@latest"
  else
    ok "Spectral already installed: $(spectral --version 2>/dev/null || echo present)"
  fi

  if ! has openapi-generator-cli; then
    npm_global_install "@openapitools/openapi-generator-cli@latest"
  else
    ok "OpenAPI Generator CLI already installed: $(openapi-generator-cli version 2>/dev/null || echo present)"
  fi

  if ! has java; then
    warn "Java is not installed. OpenAPI Generator's normal CLI path requires a Java runtime; use its container workflow or install Java before generating/validating."
  fi

  mkdir -p "$HOME/.local/bin"
  if has go; then
    info "Installing oasdiff into ~/.local/bin using Go"
    GOBIN="$HOME/.local/bin" go install github.com/oasdiff/oasdiff@latest
  elif has oasdiff; then
    ok "oasdiff already installed"
  else
    warn "Go is not installed, so oasdiff was not installed automatically. See docs/API-CONTRACTS.md for binary/container options."
  fi

  info "Recommended contract loop: spectral lint -> breaking-change check -> contract/E2E tests."
  info "Schemathesis is recommended for property-based OpenAPI testing but is not auto-installed because it is a Python toolchain dependency."
}

install_vercel_cli() {
  if ! has vercel; then
    npm_global_install "vercel@latest"
  else
    ok "Vercel CLI already installed: $(vercel --version 2>/dev/null || echo present)"
  fi
  info "The Vercel CLI is OSS; deploying to Vercel is still an external cloud operation and should require explicit approval for production."
}

case "$TOOLCHAIN" in
  api-contracts) install_api_contracts ;;
  vercel-cli) install_vercel_cli ;;
  *)
    list_toolchains >&2
    die "Unknown toolchain: $TOOLCHAIN"
    ;;
esac

ok "Toolchain '$TOOLCHAIN' ready."
