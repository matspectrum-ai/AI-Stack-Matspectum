#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT/scripts/lib.sh"

PROFILE="${1:-list}"
shift || true
SCOPE="global"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) SCOPE="project" ;;
    -h|--help)
      PROFILE="help"
      ;;
    *) die "Unknown option: $1" ;;
  esac
  shift
done

list_profiles() {
  cat <<'EOF'
Available profiles:
  core                 Debugging, TDD, code review, handoff
  design               Original UI + product refinement + high-end frontend
  design-redesign      Existing-project redesign/refinement
  motion               Build and review UI motion
  long-autonomy        Observable completion gates (Unlazy)
  database-postgres    Postgres best practices maintained by Supabase
  security             Context-first audit + Semgrep workflow
  shadcn               Official shadcn/ui skill
  all-recommended      core + design + motion + long-autonomy + database-postgres + security

Profiles are installed globally by default.
Use --project to install only into the current project.
EOF
}

[[ "$PROFILE" == "list" ]] && { list_profiles; exit 0; }
[[ "$PROFILE" == "help" ]] && { list_profiles; exit 0; }

has npm || die "npm/npx is required."

agents=(opencode)
if has pi; then
  agents+=(pi)
fi

scope_args=()
if [[ "$SCOPE" == "global" ]]; then
  scope_args=(-g)
fi

agent_args=()
for agent in "${agents[@]}"; do
  agent_args+=(-a "$agent")
done

install_skill() {
  local source="$1"
  local skill="$2"
  info "Installing $skill from $source [$SCOPE -> ${agents[*]}]"
  DISABLE_TELEMETRY=1 npx --yes skills add "$source" \
    --skill "$skill" \
    "${scope_args[@]}" \
    "${agent_args[@]}" \
    --yes
}

profile_core() {
  install_skill "https://github.com/mattpocock/skills" "diagnosing-bugs"
  install_skill "https://github.com/mattpocock/skills" "tdd"
  install_skill "https://github.com/mattpocock/skills" "code-review"
  install_skill "https://github.com/mattpocock/skills" "handoff"
}

profile_design() {
  install_skill "https://github.com/anthropics/skills" "frontend-design"
  install_skill "https://github.com/pbakaus/impeccable" "impeccable"
  install_skill "https://github.com/leonxlnx/taste-skill" "design-taste-frontend"
}

profile_design_redesign() {
  install_skill "https://github.com/pbakaus/impeccable" "impeccable"
  install_skill "https://github.com/leonxlnx/taste-skill" "redesign-existing-projects"
}

profile_motion() {
  install_skill "https://github.com/emilkowalski/skills" "animate"
  install_skill "https://github.com/emilkowalski/skills" "review-animations"
}

profile_long_autonomy() {
  install_skill "https://github.com/leonxlnx/unlazy" "unlazy"
}

profile_database_postgres() {
  install_skill "https://github.com/supabase/agent-skills" "supabase-postgres-best-practices"
}

profile_security() {
  install_skill "https://github.com/trailofbits/skills" "audit-context-building"
  install_skill "https://github.com/trailofbits/skills" "semgrep"
}

profile_shadcn() {
  install_skill "https://github.com/shadcn-ui/ui" "shadcn"
}

case "$PROFILE" in
  core) profile_core ;;
  design) profile_design ;;
  design-redesign) profile_design_redesign ;;
  motion) profile_motion ;;
  long-autonomy) profile_long_autonomy ;;
  database-postgres) profile_database_postgres ;;
  security) profile_security ;;
  shadcn) profile_shadcn ;;
  all-recommended)
    profile_core
    profile_design
    profile_motion
    profile_long_autonomy
    profile_database_postgres
    profile_security
    ;;
  *)
    list_profiles >&2
    die "Unknown profile: $PROFILE"
    ;;
esac

ok "Profile '$PROFILE' installed."
