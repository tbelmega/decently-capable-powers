#!/usr/bin/env bash
# install.sh — deploy decently-capable-powers into user-level agent config.
#
# Default (no args): user-level install covering all three harnesses.
#   - Symlinks each skills/<name>/ into ~/.claude/skills/ (read by Claude Code
#     and Cursor) and ~/.agents/skills/ (read by Codex and Cursor). Cursor reads
#     both trees; identical names resolve to identical content, so the overlap
#     is harmless.
#   - Refreshes the DCP-markered operating-guide block in ~/.claude/CLAUDE.md
#     (Claude Code) and ~/.codex/AGENTS.md (Codex).
#   - Prints the one manual step for Cursor (no file-based global instructions;
#     paste into Settings → Rules).
#
# --project <dir>: refresh the managed block in <dir>/AGENTS.md and ensure
#   <dir>/CLAUDE.md imports it — for repos that want checked-in, team-visible
#   guidance instead of (or on top of) the user-level install.
#
# Idempotent — re-run after every change to this repo. Update = git pull + re-run.
# Load paths verified against official harness docs 2026-07-02 (ASSUMPTIONS.md
# A2/A3); the self-update skill re-verifies them.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUIDE="$REPO_DIR/AGENTS.md"
START_MARK='DCP:START'
END_MARK='DCP:END'

link_skills() {
  local target_root="$1"
  mkdir -p "$target_root"
  local linked=0 current=0
  for skill_dir in "$REPO_DIR"/skills/*/; do
    local name link
    name="$(basename "$skill_dir")"
    link="$target_root/$name"
    if [ -L "$link" ] && [ "$(readlink -f "$link")" = "$(readlink -f "$skill_dir")" ]; then
      current=$((current + 1))
    elif [ -e "$link" ] || [ -L "$link" ]; then
      echo "  ! $link exists and is not a link to this repo — left untouched"
    else
      ln -s "${skill_dir%/}" "$link"
      linked=$((linked + 1))
    fi
  done
  echo "  $target_root: $linked newly linked, $current already current"
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

if [ "${1:-}" = "--project" ]; then
  project_install "${2:?usage: install.sh --project <dir>}"
  exit 0
elif [ "${1:-}" != "" ]; then
  echo "usage: install.sh [--project <dir>]" >&2
  exit 1
fi

echo "Skills (symlinked; edits in the repo are live immediately):"
link_skills "$HOME/.claude/skills"
link_skills "$HOME/.agents/skills"

echo "Operating guide (managed block):"
refresh_block "$HOME/.claude/CLAUDE.md"
refresh_block "$HOME/.codex/AGENTS.md"

cat <<'EOF'

Cursor has no file-based global instructions — one manual step:
  paste the contents of this repo's AGENTS.md into
  Cursor → Settings → Rules → User Rules, and re-paste whenever the guide
  changes. (Skills reach Cursor automatically via the symlinks above.)

Done.
EOF
