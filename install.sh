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

link_skills() {
  local target_root="$1"
  mkdir -p "$target_root"
  local linked=0 repaired=0 current=0
  for skill_dir in "$REPO_DIR"/skills/*/; do
    local name link
    name="$(basename "$skill_dir")"
    link="$target_root/$name"
    if [ -L "$link" ] && [ "$(readlink -f "$link")" = "$(readlink -f "$skill_dir")" ]; then
      current=$((current + 1))
    elif [ -L "$link" ] && [ ! -e "$link" ]; then
      # Dangling: the target is gone, most often this repo under its previous path
      # or name. Repointing clobbers no live content, and it is the only way a
      # rerun repairs a profile that drifted — a link left as-is stays unloadable.
      ln -sfn "${skill_dir%/}" "$link"
      repaired=$((repaired + 1))
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

# Pull optional --config-dir values out of the args; everything else (notably
# --project and its argument) passes through unchanged. The parallel boolean
# avoids ${#array[@]} on an empty array, which is unbound under `set -u` in the
# bash 3.2 that macOS still ships.
extra_config_dirs=()
have_extra_config_dirs=false
passthrough_args=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --config-dir)
      # An empty value is a mistake, not a target: it would send link_skills at
      # /skills. Reject it here, before the default targets are touched, so a
      # bad invocation is all-or-nothing rather than half-applied.
      if [ "$#" -lt 2 ] || [ -z "$2" ]; then
        echo "--config-dir requires a non-empty directory argument" >&2
        exit 1
      fi
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

USAGE='usage: install.sh [--config-dir <dir>]... | --project <dir>'

if [ "${1:-}" = "--project" ]; then
  if [ "$have_extra_config_dirs" = true ]; then
    echo "--config-dir belongs to the user-level install and does nothing with --project" >&2
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
