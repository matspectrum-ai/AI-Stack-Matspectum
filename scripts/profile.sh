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
    -h|--help) PROFILE="help" ;;
    *) die "Unknown option: $1" ;;
  esac
  shift
done

list_profiles() {
  cat <<'EOF'
Available profiles:

Workflow / universal
  core                 Debugging, TDD, code review, handoff
  long-autonomy        Observable completion gates (Unlazy)
  security             Context-first audit + Semgrep workflow

Frontend / design
  design               Original UI + product refinement + high-end frontend
  design-redesign      Existing-project redesign/refinement
  motion               Build and review UI motion
  shadcn               Official shadcn/ui skill
  nextjs               Official Next.js runtime verification workflow

Backend / data
  database-postgres    Postgres best practices maintained by Supabase
  supabase             Comprehensive Supabase + Postgres best practices
  prisma               Official Prisma ORM CLI/client/database skills
  drizzle-experimental Install Drizzle Kit bundled skills from the project's local CLI

Infrastructure / platform
  cloudflare           Official Cloudflare platform + Workers best practices
  cloudflare-agents    Official Cloudflare Agents SDK skill

Authentication
  better-auth          Better Auth setup, best practices and security
  clerk-nextjs         Clerk setup + Next.js patterns + auth testing

Billing
  stripe               Official Stripe agent skills from docs.stripe.com

Observability
  sentry-nextjs        Official Sentry Next.js setup + tracing + logging skills

Composed application profiles
  saas-nextjs          Core + Next.js + security. Provider-neutral SaaS base.
  all-recommended      Universal workstation skills only; no framework/provider lock-in

Profiles are installed globally by default.
Use --project for framework/provider/domain profiles in real projects.
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

install_skill_source() {
  local source="$1"
  info "Installing skills from $source [$SCOPE -> ${agents[*]}]"
  DISABLE_TELEMETRY=1 npx --yes skills add "$source" \
    "${scope_args[@]}" \
    "${agent_args[@]}" \
    --yes
}

require_project_scope() {
  local name="$1"
  [[ "$SCOPE" == "project" ]] || die "$name is project-scoped. Re-run with --project from the target repository."
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

profile_supabase() {
  install_skill "https://github.com/supabase/agent-skills" "supabase"
  install_skill "https://github.com/supabase/agent-skills" "supabase-postgres-best-practices"
}

profile_prisma() {
  install_skill "https://github.com/prisma/skills" "prisma-cli"
  install_skill "https://github.com/prisma/skills" "prisma-client-api"
  install_skill "https://github.com/prisma/skills" "prisma-database-setup"
}

profile_drizzle_experimental() {
  require_project_scope "drizzle-experimental"
  local drizzle_bin="./node_modules/.bin/drizzle-kit"
  [[ -x "$drizzle_bin" ]] || die "A compatible project-local drizzle-kit is required. Install the Drizzle version your project uses first; this stack will not silently fetch an RC."
  info "Installing Agent Skills bundled by the project's drizzle-kit"
  "$drizzle_bin" skills
  warn "Drizzle Agent Skills are still an emerging/RC surface. Keep them project-local and review upgrades."
}

profile_security() {
  install_skill "https://github.com/trailofbits/skills" "audit-context-building"
  install_skill "https://github.com/trailofbits/skills" "semgrep"
}

profile_shadcn() {
  install_skill "https://github.com/shadcn-ui/ui" "shadcn"
}

profile_nextjs() {
  install_skill "https://github.com/vercel/next.js" "next-dev-loop"
  info "next-dev-loop requires Next.js 16.3+ and agent-browser >=0.31.1."
  info "Run 'ai-stack bootstrap --with-browser' if agent-browser is missing."
}

profile_cloudflare() {
  install_skill "https://github.com/cloudflare/skills" "cloudflare"
  install_skill "https://github.com/cloudflare/skills" "workers-best-practices"
}

profile_cloudflare_agents() {
  install_skill "https://github.com/cloudflare/skills" "agents-sdk"
}

profile_better_auth() {
  install_skill "https://github.com/better-auth/skills" "better-auth-best-practices"
  install_skill "https://github.com/better-auth/skills" "better-auth-security-best-practices"
  install_skill "https://github.com/better-auth/skills" "create-auth"
}

profile_clerk_nextjs() {
  install_skill "https://github.com/clerk/skills" "clerk"
  install_skill "https://github.com/clerk/skills" "clerk-setup"
  install_skill "https://github.com/clerk/skills" "clerk-nextjs-patterns"
  install_skill "https://github.com/clerk/skills" "clerk-testing"
}

profile_stripe() {
  install_skill_source "https://docs.stripe.com"
}

profile_sentry_nextjs() {
  install_skill "https://github.com/getsentry/sentry-agent-skills" "sentry-nextjs-sdk"
  install_skill "https://github.com/getsentry/sentry-agent-skills" "sentry-setup-tracing"
  install_skill "https://github.com/getsentry/sentry-agent-skills" "sentry-setup-logging"
  info "For production issue fixing, Sentry's sentry-fix-issues skill additionally requires Sentry MCP access."
}

profile_saas_nextjs() {
  profile_core
  profile_nextjs
  profile_security
  info "SaaS base installed without vendor lock-in. Add only the providers the project actually uses:"
  info "  ai-stack profile supabase --project"
  info "  ai-stack profile prisma --project"
  info "  ai-stack profile drizzle-experimental --project"
  info "  ai-stack profile better-auth --project   OR   ai-stack profile clerk-nextjs --project"
  info "  ai-stack profile stripe --project       (only for Stripe billing/payments)"
  info "  ai-stack profile sentry-nextjs --project (when using Sentry)"
  info "  ai-stack profile design --project       (when UI/design work requires it)"
  info "  ai-stack toolchain api-contracts         (when the SaaS exposes an OpenAPI contract)"
}

case "$PROFILE" in
  core) profile_core ;;
  design) profile_design ;;
  design-redesign) profile_design_redesign ;;
  motion) profile_motion ;;
  long-autonomy) profile_long_autonomy ;;
  database-postgres) profile_database_postgres ;;
  supabase) profile_supabase ;;
  prisma) profile_prisma ;;
  drizzle-experimental) profile_drizzle_experimental ;;
  security) profile_security ;;
  shadcn) profile_shadcn ;;
  nextjs) profile_nextjs ;;
  cloudflare) profile_cloudflare ;;
  cloudflare-agents) profile_cloudflare_agents ;;
  better-auth) profile_better_auth ;;
  clerk-nextjs) profile_clerk_nextjs ;;
  stripe) profile_stripe ;;
  sentry-nextjs) profile_sentry_nextjs ;;
  saas-nextjs) profile_saas_nextjs ;;
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
