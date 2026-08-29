#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT/scripts/lib.sh"

TARGET="."
USE_SDD=0

if [[ $# -gt 0 && "${1:-}" != --* ]]; then
  TARGET="$1"
  shift
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sdd) USE_SDD=1 ;;
    -h|--help)
      cat <<'EOF'
Usage: ai-stack init [path] [--sdd]

Adds missing AGENTS.md / CONTEXT.md templates without overwriting existing files.
--sdd also runs `openspec init` interactively in the target project.
EOF
      exit 0
      ;;
    *) die "Unknown option: $1" ;;
  esac
  shift
done

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

copy_if_missing() {
  local src="$1"
  local dst="$2"
  if [[ -e "$dst" ]]; then
    warn "Exists, not replacing: $dst"
  else
    cp "$src" "$dst"
    ok "Created: $dst"
  fi
}

copy_if_missing "$ROOT/templates/AGENTS.md" "$TARGET/AGENTS.md"
copy_if_missing "$ROOT/templates/CONTEXT.md" "$TARGET/CONTEXT.md"

mkdir -p "$TARGET/docs/adr"
if [[ ! -e "$TARGET/docs/adr/README.md" ]]; then
  cp "$ROOT/templates/ADR-README.md" "$TARGET/docs/adr/README.md"
  ok "Created: $TARGET/docs/adr/README.md"
fi

if [[ "$USE_SDD" -eq 1 ]]; then
  has openspec || die "OpenSpec is not installed. Run './ai-stack bootstrap --with-sdd'."
  info "Starting OpenSpec initialization in $TARGET"
  (cd "$TARGET" && openspec init)
fi

ok "Project initialized. Replace generic template text with project-specific facts before asking an agent to rely on it."
