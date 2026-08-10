#!/usr/bin/env bash
# install.sh — deploy decently-capable-powers into user-level agent config.
#
# Default (no args): user-level install covering all four harnesses.
#   - Symlinks each skills/<name>/ into ~/.claude/skills/ (read by Claude Code
#     and Cursor) and ~/.agents/skills/ (read by Codex, Cursor, and Grok Build).
#     Cursor and Grok Build read both trees; identical names resolve to
#     identical content, so the overlap is harmless.
#   - Refreshes the DCP-markered operating-guide block in ~/.claude/CLAUDE.md
#     (Claude Code) and ~/.codex/AGENTS.md (Codex). Alternate Claude Code
#     profiles (CLAUDE_CONFIG_DIR=~/.claude-<name>) are refreshed too when
#     their CLAUDE.md already carries the marker — they opt in by having it.
#   - Grok Build needs no targets of its own: it reads ~/.agents/skills/
#     natively and loads ~/.claude/CLAUDE.md via its Claude compat, which is on
#     by default — a ~/.grok/AGENTS.md copy would double-load the guide
#     (ASSUMPTIONS.md A20).
#   - Prints the one manual step for Cursor (no file-based global instructions;
#     paste into Settings → Rules).
#
# --repair-links: repoint skill links that dangle — the shape drift takes when this
#   repo is moved or renamed. Off by default: a dangling target could equally be a
#   foreign checkout on an offline volume, and its path is unrecoverable once
#   overwritten. A default run reports each dangling link and names this flag.
#
# --config-dir <dir> (repeatable): also symlink the skills into <dir>/skills.
#   Use it for each extra Claude profile / CLAUDE_CONFIG_DIR you run — e.g. a
#   machine with several profiles wires them all in one invocation:
#     ./install.sh --config-dir ~/.claude-work --config-dir ~/.claude-personal
#   The default ~/.claude and ~/.agents targets are always linked as well. The
#   operating-guide block needs no such flag — alternate profiles opt into it by
#   already carrying the marker — but skills have no marker to opt in with, so
#   without this flag their links are hand-made and never refreshed.
#
# --project <dir>: refresh the managed block in <dir>/AGENTS.md and ensure
#   <dir>/CLAUDE.md imports it — for repos that want checked-in, team-visible
#   guidance instead of (or on top of) the user-level install.
#
# Idempotent — re-run after every change to this repo. Update = git pull + re-run.
# Load paths verified against official harness docs 2026-07-02, Grok Build
# 2026-07-19 (ASSUMPTIONS.md A2/A3/A20); the self-update skill re-verifies them.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUIDE="$REPO_DIR/AGENTS.md"
START_MARK='DCP:START'
END_MARK='DCP:END'

# Canonical path of an existing directory, without readlink -f — BSD readlink (macOS)
# has no such option. `cd -P` + `pwd -P` is POSIX and resolves symlinked parents the
# same way; an unresolvable path (a dangling target) falls back to the literal string,
# which then simply fails the equality test below.
canonical_dir() {
  local path="$1"
  ( cd -P "$path" 2>/dev/null && pwd -P ) || printf '%s\n' "$path"
}

# The stored target of a symlink, made absolute against the link's own directory
# so a relative link compares correctly.
link_destination() {
  local link="$1" target
  target="$(readlink "$link")"
  case "$target" in
    /*) printf '%s\n' "$target" ;;
    *) printf '%s/%s\n' "$(dirname "$link")" "$target" ;;
  esac
}

link_skills() {
  local target_root="$1"
  mkdir -p "$target_root"
  local linked=0 repaired=0 current=0
  for skill_dir in "$REPO_DIR"/skills/*/; do
    local name link previous
    name="$(basename "$skill_dir")"
    link="$target_root/$name"
    if [ -L "$link" ] && [ -e "$link" ] &&
       [ "$(canonical_dir "$(link_destination "$link")")" = "$(canonical_dir "${skill_dir%/}")" ]; then
      current=$((current + 1))
    elif [ -L "$link" ] && [ ! -e "$link" ] && [ "$repair_dangling" = true ]; then
      # Read the old destination before ln -sfn replaces it — afterwards it is gone,
      # and this line is the only record of where the link used to point.
      previous="$(link_destination "$link")"
      ln -sfn "${skill_dir%/}" "$link"
      echo "  ~ $link repointed at this repo (was dangling: $previous)"
      repaired=$((repaired + 1))
    elif [ -L "$link" ] && [ ! -e "$link" ]; then
      # A dangling target carries no provenance: it may be this repo under a
      # previous path, or a foreign checkout on a volume that is merely offline.
      # Guessing would silently discard the latter, so name the fix instead.
      echo "  ! $link is dangling (-> $(link_destination "$link")) and its skill is unloadable"
      echo "    rerun with --repair-links to point it at this repo"
    elif [ -e "$link" ] || [ -L "$link" ]; then
      echo "  ! $link exists and is not a link to this repo — left untouched"
    else
      ln -s "${skill_dir%/}" "$link"
      linked=$((linked + 1))
    fi
  done
  echo "  $target_root: $linked newly linked, $repaired repaired, $current already current"
}

# Seed gitignored personal config: for every skills/*/<base>.template.md,
# copy it to <base>.local.md if that doesn't exist yet. The local file is
# personal (subscriptions, roster, stack) and never committed.
seed_local_files() {
  local seeded=0
  for tpl in "$REPO_DIR"/skills/*/*.template.md; do
    [ -e "$tpl" ] || continue
    local local_file="${tpl%.template.md}.local.md"
    if [ ! -e "$local_file" ]; then
      cp "$tpl" "$local_file"
      echo "  seeded ${local_file#"$REPO_DIR"/} — edit it with your own setup"
      seeded=$((seeded + 1))
    fi
  done
  if [ "$seeded" -eq 0 ]; then echo "  all local files already present"; fi
}

# Replace (or append) the marker-delimited operating-guide block in $1.
refresh_block() {
  local target="$1"
  mkdir -p "$(dirname "$target")"
  local block tmp
  block="$(mktemp)"
  awk -v s="$START_MARK" -v e="$END_MARK" \
    'index($0,s){f=1} f{print} index($0,e){f=0}' "$GUIDE" > "$block"
  if [ -f "$target" ] && grep -q "$START_MARK" "$target"; then
    tmp="$(mktemp)"
    awk -v s="$START_MARK" -v e="$END_MARK" -v bf="$block" '
      index($0,s) {while ((getline l < bf) > 0) print l; close(bf); f=1; next}
      index($0,e) {f=0; next}
      !f {print}
    ' "$target" > "$tmp"
    mv "$tmp" "$target"
    echo "  refreshed managed block in $target"
  else
    {
      if [ -s "$target" ]; then echo ""; fi
      echo "# Operating guide"
      cat "$block"
    } >> "$target"
    echo "  appended managed block to $target"
  fi
  rm -f "$block"
}

project_install() {
  local dir="$1"
  [ -d "$dir" ] || { echo "No such directory: $dir" >&2; exit 1; }
  refresh_block "$dir/AGENTS.md"
  if [ ! -f "$dir/CLAUDE.md" ] || ! grep -q '@AGENTS.md' "$dir/CLAUDE.md"; then
    printf '\n@AGENTS.md\n' >> "$dir/CLAUDE.md"
    echo "  ensured @AGENTS.md import in $dir/CLAUDE.md"
  fi
}

USAGE='usage: install.sh [--config-dir <dir>]... [--repair-links] | --project <dir>'

# Pull optional --config-dir values out of the args; everything else (notably
# --project and its argument) passes through unchanged. The parallel boolean
# avoids ${#array[@]} on an empty array, which is unbound under `set -u` in the
# bash 3.2 that macOS still ships.
extra_config_dirs=()
have_extra_config_dirs=false
repair_dangling=false
passthrough_args=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --repair-links)
      repair_dangling=true
      shift
      ;;
    --config-dir)
      # A missing value, an empty one (an unset profile variable), or a following
      # option token all mean no directory was given. Accepting any of them sends
      # link_skills at /skills or a relative "-flag/skills" — and only *after* the
      # default targets were written. Reject here, before anything is touched, so a
      # bad invocation is all-or-nothing.
      case "${2:-}" in
        "" | -*)
          echo "--config-dir requires a non-empty directory argument that is not an option" >&2
          echo "$USAGE" >&2
          exit 1
          ;;
      esac
      extra_config_dirs+=("$2")
      have_extra_config_dirs=true
      shift 2
      ;;
    *)
      passthrough_args+=("$1")
      shift
      ;;
  esac
done
set -- ${passthrough_args[@]+"${passthrough_args[@]}"}

if [ "${1:-}" = "--project" ]; then
  if [ "$have_extra_config_dirs" = true ] || [ "$repair_dangling" = true ]; then
    echo "--config-dir and --repair-links belong to the user-level install and do nothing with --project" >&2
    echo "$USAGE" >&2
    exit 1
  fi
  project_install "${2:?usage: install.sh --project <dir>}"
  exit 0
elif [ "${1:-}" != "" ]; then
  echo "$USAGE" >&2
  exit 1
fi

echo "Skills (symlinked; edits in the repo are live immediately):"
link_skills "$HOME/.claude/skills"
link_skills "$HOME/.agents/skills"
for extra_dir in ${extra_config_dirs[@]+"${extra_config_dirs[@]}"}; do
  link_skills "$extra_dir/skills"
done

echo "Personal config (gitignored *.local.md, reaches all harnesses via the symlinks):"
seed_local_files

echo "Operating guide (managed block):"
refresh_block "$HOME/.claude/CLAUDE.md"
# Alternate profiles opt in by already carrying the marker; never seed them here.
for alt_claude_md in "$HOME"/.claude-*/CLAUDE.md; do
  if [ -f "$alt_claude_md" ] && grep -q "$START_MARK" "$alt_claude_md"; then
    refresh_block "$alt_claude_md"
  fi
done
refresh_block "$HOME/.codex/AGENTS.md"

cat <<'EOF'

Cursor has no file-based global instructions — one manual step:
  paste the contents of this repo's AGENTS.md into
  Cursor → Settings → Rules → User Rules, and re-paste whenever the guide
  changes. (Skills reach Cursor automatically via the symlinks above.)

Done.
EOF
