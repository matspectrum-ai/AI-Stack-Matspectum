#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT/scripts/lib.sh"

WITH_PI=0
WITH_BROWSER=0
WITH_SDD=0
WITH_CORE_SKILLS=1

usage() {
  cat <<'EOF'
Usage: ai-stack bootstrap [options]

Default:
  - verifies Git + Node/npm
  - installs OpenCode if missing
  - installs the global core skill profile

Options:
  --with-pi          Install Pi coding agent too
  --with-browser     Install Playwright CLI + browser agent skills
  --with-sdd         Install OpenSpec CLI
  --no-core-skills   Do not install the default global core skills
  -h, --help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-pi) WITH_PI=1 ;;
    --with-browser) WITH_BROWSER=1 ;;
    --with-sdd) WITH_SDD=1 ;;
    --no-core-skills) WITH_CORE_SKILLS=0 ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
  shift
done

has git || die "Git is required. Install git with your OS package manager first."
has npm || die "npm is required. Install Node.js 20+ and npm first."
node_version_ok 20 || die "Node.js 20+ is required. Current: $(node --version 2>/dev/null || echo missing)"

if ! has opencode; then
  npm_global_install "opencode-ai"
else
  ok "OpenCode already installed: $(opencode --version 2>/dev/null || echo present)"
fi

if [[ "$WITH_PI" -eq 1 ]]; then
  if ! has pi; then
    info "Installing Pi without dependency lifecycle scripts"
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
  else
    ok "Pi already installed"
  fi
fi

if [[ "$WITH_SDD" -eq 1 ]]; then
  if ! node -e 'const [a,b]=process.versions.node.split(".").map(Number); process.exit(a>20 || (a===20 && b>=19) ? 0 : 1)'; then
    die "OpenSpec requires Node.js >=20.19.0. Current: $(node --version)"
  fi
  if ! has openspec; then
    npm_global_install "@fission-ai/openspec@latest"
  else
    ok "OpenSpec already installed: $(openspec --version 2>/dev/null || echo present)"
  fi
fi

if [[ "$WITH_BROWSER" -eq 1 ]]; then
  if ! has playwright-cli; then
    npm_global_install "@playwright/cli@latest"
  else
    ok "Playwright CLI already installed"
  fi
  info "Installing Playwright agent skills"
  playwright-cli install --skills
  info "Ensuring the default browser is installed"
  playwright-cli install-browser
fi

if [[ "$WITH_CORE_SKILLS" -eq 1 ]]; then
  "$ROOT/scripts/profile.sh" core
fi

mkdir -p "$HOME/.local/bin"
if [[ ! -e "$HOME/.local/bin/ai-stack" ]]; then
  ln -s "$ROOT/ai-stack" "$HOME/.local/bin/ai-stack"
  ok "Linked ai-stack -> ~/.local/bin/ai-stack"
else
  warn "~/.local/bin/ai-stack already exists; leaving it unchanged"
fi

printf '\n'
ok "Bootstrap complete."
info "Next: run './ai-stack doctor', then start 'opencode' and use /connect."
