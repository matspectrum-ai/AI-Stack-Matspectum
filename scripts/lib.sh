#!/usr/bin/env bash

color() {
  if [[ -t 1 ]]; then
    printf '\033[%sm%s\033[0m' "$1" "$2"
  else
    printf '%s' "$2"
  fi
}

info() { printf '%s %s\n' "$(color '1;34' '==>')" "$*"; }
ok()   { printf '%s %s\n' "$(color '1;32' 'OK ')" "$*"; }
warn() { printf '%s %s\n' "$(color '1;33' 'WARN')" "$*" >&2; }
die()  { printf '%s %s\n' "$(color '1;31' 'ERR ')" "$*" >&2; exit 1; }

has() { command -v "$1" >/dev/null 2>&1; }

node_major() {
  node -p 'process.versions.node.split(".")[0]' 2>/dev/null || true
}

node_version_ok() {
  local min_major="${1:-20}"
  local major
  major="$(node_major)"
  [[ -n "$major" && "$major" -ge "$min_major" ]]
}

npm_global_install() {
  local pkg="$1"
  info "Installing npm package: $pkg"
  npm install -g "$pkg"
}
