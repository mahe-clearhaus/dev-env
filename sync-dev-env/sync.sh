#!/usr/bin/env bash
# dev-env sync — copy live configs into this repo (and report drift).
# Usage: .sync/sync.sh {status|pull|scan|check} [--only PATTERN]
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$REPO/.sync/manifest.tsv"
CANDIDATES="$REPO/.sync/candidates.txt"
ONLY=""

GLOBAL_EXCLUDES=(--exclude '.DS_Store' --exclude '.git/' --exclude '*.log' --exclude '*.swp')

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
expand() { printf '%s' "${1/#\~/$HOME}"; }

# Read manifest into parallel arrays: R_REPO R_SRC R_EX
load_manifest() {
  R_REPO=(); R_SRC=(); R_EX=()
  local line repo src ex
  while IFS= read -r line || [ -n "$line" ]; do
    [[ -z "${line// }" || "$line" == \#* ]] && continue
    IFS=$'\t' read -r repo src ex <<<"$line"
    [ -z "${repo:-}" ] && continue
    [ -z "${src:-}" ] && { printf 'warning: manifest line missing source: %s\n' "$repo" >&2; continue; }
    if [ -n "$ONLY" ] && [[ "$repo" != *"$ONLY"* ]]; then continue; fi
    R_REPO+=("$repo"); R_SRC+=("$(expand "$src")"); R_EX+=("${ex:-}")
  done < "$MANIFEST"
}

excludes_for() { # $1 = "ex:a,b" field -> echoes rsync args, one per line
  local f="${1#ex:}"
  [ -z "$1" ] && return 0
  local IFS=','; local g
  for g in $f; do printf -- '--exclude\n%s\n' "$g"; done
}

rsync_args() { # $1 = index -> sets RS array
  RS=(-a -c --copy-unsafe-links "${GLOBAL_EXCLUDES[@]}")
  local e; while IFS= read -r e; do RS+=("$e"); done < <(excludes_for "${R_EX[$1]}")
}

run_entries() { # $1 = 1 for dry-run, 0 to actually copy
  local dry="$1" i src dst changed=0 missing=0
  for i in "${!R_REPO[@]}"; do
    src="${R_SRC[$i]}"; dst="$REPO/${R_REPO[$i]}"
    if [ ! -e "$src" ]; then
      printf '  ??  %-46s (source missing: %s)\n' "${R_REPO[$i]}" "${src/#$HOME/\~}"
      missing=$((missing+1)); continue
    fi

    if [ -f "$src" ] && [ ! -d "$src" ]; then
      # Single file: exact content comparison, no rsync itemize quirks.
      if [ -e "$dst" ] && cmp -s "$src" "$dst"; then continue; fi
      changed=$((changed+1))
      if [ -e "$dst" ]; then printf '  ~   %s\n' "${R_REPO[$i]}"
      else printf '  +   %s (new)\n' "${R_REPO[$i]}"; fi
      if [ "$dry" -eq 0 ]; then mkdir -p "$(dirname "$dst")"; cp -p "$src" "$dst"; fi
      continue
    fi

    rsync_args "$i"
    RS+=(--delete)   # directories mirror exactly, so removals propagate
    src="${src%/}/"; dst="${dst%/}/"
    local out
    out="$(mkdir -p "$dst" && rsync "${RS[@]}" --itemize-changes --dry-run "$src" "$dst" 2>/dev/null \
           | grep -vE '^\.' )"
    if [ -n "$out" ]; then
      changed=$((changed+1))
      printf '  ~   %s\n' "${R_REPO[$i]}"
      printf '%s\n' "$out" | sed 's/^/        /'
      [ "$dry" -eq 0 ] && rsync "${RS[@]}" "$src" "$dst" >/dev/null
    fi
  done
  printf '\n%d entr%s with changes, %d missing source(s).\n' \
    "$changed" "$([ "$changed" -eq 1 ] && echo y || echo ies)" "$missing"
}

cmd_status() { load_manifest; echo "Drift (live -> repo):"; run_entries 1; }
cmd_pull()   { load_manifest; echo "Syncing live -> repo:"; run_entries 0; }

cmd_scan() {
  load_manifest
  echo "Candidates on this machine not covered by the manifest:"
  local c p found=0
  while IFS= read -r c || [ -n "$c" ]; do
    [[ -z "${c// }" || "$c" == \#* ]] && continue
    p="$(expand "$c")"
    [ -e "$p" ] || continue
    local covered=0 s
    for s in "${R_SRC[@]}"; do
      [[ "${s%/}" == "${p%/}" || "${s%/}" == "${p%/}"/* ]] && { covered=1; break; }
    done
    [ "$covered" -eq 1 ] && continue
    found=$((found+1))
    printf '  +   %-46s  (%s)\n' "$c" "$(du -sh "$p" 2>/dev/null | cut -f1)"
  done < "$CANDIDATES"
  [ "$found" -eq 0 ] && echo "  (none)"
  echo
  echo "Nothing above is synced. Add a line to .sync/manifest.tsv to start tracking one."
}

cmd_check() {
  echo "Scanning repo working tree for secrets:"
  local hits=0
  # Files that must never be committed, regardless of content.
  local banned
  banned="$(cd "$REPO" && git ls-files | grep -nE '(^|/)(hosts\.yml|settings\.local\.json|\.netrc|\.env|id_(rsa|ed25519)|.*\.pem|.*\.p12|credentials)$' || true)"
  if [ -n "$banned" ]; then hits=1; echo "  banned files tracked:"; printf '%s\n' "$banned" | sed 's/^/    /'; fi
  # Token-shaped strings.
  local pat='(gh[pousr]_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[abpsr]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|(api[_-]?key|secret|password|token)["'"'"':= ]+[A-Za-z0-9/+_-]{24,})'
  local grepout
  grepout="$(cd "$REPO" && git ls-files -z | xargs -0 grep -InEI "$pat" 2>/dev/null || true)"
  if [ -n "$grepout" ]; then hits=1; echo "  possible secrets:"; printf '%s\n' "$grepout" | cut -c1-160 | sed 's/^/    /'; fi
  [ "$hits" -eq 0 ] && echo "  clean." || { echo; echo "Review the above before committing."; return 1; }
}

main() {
  local cmd="${1:-status}"; shift || true
  while [ $# -gt 0 ]; do
    case "$1" in --only) ONLY="${2:-}"; shift 2;; *) die "unknown option: $1";; esac
  done
  [ -f "$MANIFEST" ] || die "no manifest at $MANIFEST"
  case "$cmd" in
    status) cmd_status;;
    pull)   cmd_pull;;
    scan)   cmd_scan;;
    check)  cmd_check;;
    *) die "usage: sync.sh {status|pull|scan|check} [--only PATTERN]";;
  esac
}
main "$@"
