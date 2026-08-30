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
Available capability profiles:

Workflow / universal
  core                       Debugging, TDD, code review, handoff
  long-autonomy              Observable completion gates (Unlazy)
  security                   Context-first audit + Semgrep workflow

Framework / frontend
  nextjs                     Next.js runtime verification loop
  nextjs-cache-adoption      Adopt Next.js Cache Components
  nextjs-cache-optimize      TDD loop for instant Cache Components navigation
  nextjs-partial-prefetch    Adopt Next.js Partial Prefetching
  vite                       Vite configuration/build knowledge
  shadcn                     Official shadcn/ui skill

Testing / quality
  vitest                     Vitest configuration, mocking, coverage and tests
  web-quality                Evidence-led web quality audit
  web-performance            Evidence-led web performance optimization

Design / UX
  design                     Original UI + product refinement + high-end frontend
  design-redesign            Existing-project redesign/refinement
  motion                     Build and review UI motion

Backend / data
  database-postgres          Postgres best practices maintained by Supabase
  supabase                   Comprehensive Supabase + Postgres best practices
  prisma                     Official Prisma ORM CLI/client/database skills
  drizzle-experimental       Project-bundled Drizzle Kit skills (experimental)

Infrastructure / platform
  cloudflare                 Cloudflare platform + Workers best practices
  cloudflare-agents          Cloudflare Agents SDK skill

Authentication
  better-auth                Better Auth setup, best practices and security
  clerk-nextjs               Clerk setup + Next.js patterns + auth testing

Billing
  stripe                     Official Stripe agent skills from docs.stripe.com

Observability
  sentry-nextjs              Sentry Next.js setup + tracing + logging

Presets / convenience compositions
  saas-nextjs                Core + Next.js + security; provider-neutral SaaS base
  all-recommended            Universal workstation skills only; no provider lock-in

Profiles are installed globally by default.
Use --project for framework/provider/domain profiles in real projects.
Prefer `ai-stack detect` instead of collecting profiles manually.
EOF
}

[[ "$PROFILE" == "list" ]] && { list_profiles; exit 0; }
[[ "$PROFILE" == "help" ]] && { list_profiles; exit 0; }

has npm || die "npm/npx is required."

if [[ "$SCOPE" == "project" ]]; then
  project_dir="$(pwd -P)"
  home_dir="$(cd -- "$HOME" && pwd -P)"
  [[ "$project_dir" != "$home_dir" ]] || die "--project must be run from the target project directory, not from HOME ($HOME). cd into the repository first."
  if has git && ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    warn "Current directory is not inside a Git repository. Project-local skills will still be installed here; verify this is intentional."
  fi
fi

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

profile_long_autonomy() {
  install_skill "https://github.com/leonxlnx/unlazy" "unlazy"
}

profile_security() {
  install_skill "https://github.com/trailofbits/skills" "audit-context-building"
  install_skill "https://github.com/trailofbits/skills" "semgrep"
}

profile_nextjs() {
  install_skill "https://github.com/vercel/next.js" "next-dev-loop"
  info "next-dev-loop requires Next.js 16.3+ with Turbopack and agent-browser >=0.31.1."
  info "Run 'ai-stack bootstrap --with-browser' if browser tooling is missing."
}

profile_nextjs_cache_adoption() {
  install_skill "https://github.com/vercel/next.js" "next-cache-components-adoption"
}

profile_nextjs_cache_optimize() {
  install_skill "https://github.com/vercel/next.js" "next-cache-components-optimizer"
}

profile_nextjs_partial_prefetch() {
  install_skill "https://github.com/vercel/next.js" "next-partial-prefetching-adoption"
}

profile_vite() {
  install_skill "https://github.com/antfu/skills" "vite"
}

profile_vitest() {
  install_skill "https://github.com/antfu/skills" "vitest"
}

profile_web_quality() {
  install_skill "https://github.com/addyosmani/web-quality-skills" "web-quality-audit"
}

profile_web_performance() {
  install_skill "https://github.com/addyosmani/web-quality-skills" "performance"
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

profile_shadcn() {
  install_skill "https://github.com/shadcn-ui/ui" "shadcn"
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
  require_project_scope "saas-nextjs"
  profile_core
  profile_nextjs
  profile_security
  info "Convenience preset installed. Prefer 'ai-stack detect' for general projects."
}

case "$PROFILE" in
  core) profile_core ;;
  long-autonomy) profile_long_autonomy ;;
  security) profile_security ;;
  nextjs) profile_nextjs ;;
  nextjs-cache-adoption) profile_nextjs_cache_adoption ;;
  nextjs-cache-optimize) profile_nextjs_cache_optimize ;;
  nextjs-partial-prefetch) profile_nextjs_partial_prefetch ;;
  vite) profile_vite ;;
  vitest) profile_vitest ;;
  web-quality) profile_web_quality ;;
  web-performance) profile_web_performance ;;
  design) profile_design ;;
  design-redesign) profile_design_redesign ;;
  motion) profile_motion ;;
  shadcn) profile_shadcn ;;
  database-postgres) profile_database_postgres ;;
  supabase) profile_supabase ;;
  prisma) profile_prisma ;;
  drizzle-experimental) profile_drizzle_experimental ;;
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
