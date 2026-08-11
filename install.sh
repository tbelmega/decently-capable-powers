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
# Above Linux's 40-hop and BSD's 32-hop resolution limits, so any chain the kernel itself
# would follow is still classified on its merits rather than cut short as indeterminate.
LINK_HOP_LIMIT=64

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

# present | absent | unknown for a path `test -e` said nothing about. `-e` answers false
# both for "not there" and for "an ancestor denies search permission", and repairing the
# second case would discard a link to live content. So walk the path top-down: while every
# ancestor so far is a searchable directory, a missing component is genuinely missing; the
# moment one cannot be looked inside, the verdict is unknown rather than absent. A regular
# file mid-path (ENOTDIR) is definitive too — nothing can exist below it.
target_state() {
  local target="$1" hops="${2:-0}" visited="${3:-}" cur rest component
  if [ -e "$target" ]; then printf 'present\n'; return; fi
  case "$target" in
    /*) cur=""; rest="${target#/}" ;;
    *) cur="."; rest="$target" ;;
  esac
  while [ -n "$rest" ]; do
    component="${rest%%/*}"
    if [ "$component" = "$rest" ]; then rest=""; else rest="${rest#*/}"; fi
    [ -n "$component" ] || continue
    cur="$cur/$component"
    if [ ! -e "$cur" ]; then
      # An existing symlink that does not resolve is not evidence of absence: its own
      # destination may merely be unreachable. Judge that destination by the same rules,
      # so a genuinely broken chain still ends in absent and a blocked one in unknown.
      if [ -L "$cur" ]; then
        # Only a component we have already followed proves a cycle. Chain length does not:
        # a long chain ending in a missing path is provably dangling and must stay
        # repairable, so the hop limit sits above what the kernel itself resolves.
        if printf '%s\n' "$visited" | grep -qxF -- "$cur"; then printf 'unknown:loop\n'; return; fi
        if [ "$hops" -ge "$LINK_HOP_LIMIT" ]; then printf 'unknown:depth\n'; return; fi
        target_state "$(link_destination "$cur")" "$((hops + 1))" "$visited
$cur"
        return
      fi
      printf 'absent\n'; return
    fi
    if [ -n "$rest" ]; then
      if [ ! -d "$cur" ]; then printf 'absent\n'; return; fi
      if [ ! -x "$cur" ]; then printf 'unknown:permission\n'; return; fi
    fi
  done
  printf 'present\n'
}

link_skills() {
  local target_root="$1"
  mkdir -p "$target_root"
  local linked=0 repaired=0 current=0
  for skill_dir in "$REPO_DIR"/skills/*/; do
    local name link previous state
    name="$(basename "$skill_dir")"
    link="$target_root/$name"
    # Only an unresolvable link needs classifying; a resolvable one is present by definition.
    state=""
    if [ -L "$link" ] && [ ! -e "$link" ]; then state="$(target_state "$(link_destination "$link")")"; fi
    if [ -L "$link" ] && [ -e "$link" ] &&
       [ "$(canonical_dir "$(link_destination "$link")")" = "$(canonical_dir "${skill_dir%/}")" ]; then
      current=$((current + 1))
    elif [ "${state%%:*}" = unknown ]; then
      # Not provably dangling, so replacing it could discard the only record of a live
      # target: this stays untouched even under --repair-links. Each cause needs its own
      # recovery step, so name the one that actually applies.
      echo "  ! $link (-> $(link_destination "$link")) cannot be resolved — left untouched"
      case "$state" in
        unknown:permission)
          echo "    a directory on that path denies search permission; its target may still be live" ;;
        unknown:loop)
          echo "    its symlink chain loops, so no target can be determined; repoint or remove it by hand" ;;
        unknown:depth)
          echo "    its symlink chain exceeds $LINK_HOP_LIMIT hops; repoint or remove it by hand" ;;
      esac
    elif [ "$state" = absent ] && [ "$repair_dangling" = true ]; then
      # Read the old destination before ln -sfn replaces it — afterwards it is gone,
      # and this line is the only record of where the link used to point.
      previous="$(link_destination "$link")"
      ln -sfn "${skill_dir%/}" "$link"
      echo "  ~ $link repointed at this repo (was dangling: $previous)"
      repaired=$((repaired + 1))
    elif [ "$state" = absent ]; then
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

# A supplied profile path must be proven usable *before* anything is linked.
# link_skills would otherwise fail at mkdir -p on a file or a dangling link — after
# the default targets had already been rewritten, leaving a partial install.
for extra_dir in ${extra_config_dirs[@]+"${extra_config_dirs[@]}"}; do
  if { [ -e "$extra_dir" ] || [ -L "$extra_dir" ]; } && [ ! -d "$extra_dir" ]; then
    echo "--config-dir $extra_dir exists but is not a directory" >&2
    exit 1
  fi
  if { [ -e "$extra_dir/skills" ] || [ -L "$extra_dir/skills" ]; } && [ ! -d "$extra_dir/skills" ]; then
    echo "--config-dir $extra_dir has a skills path that is not a directory" >&2
    exit 1
  fi
done

# Every skill target — default and supplied alike — must be proven creatable *and*
# writable before the first link, so no failure can leave some targets installed and
# others not. Inspecting a path is not enough: `mkdir -p` succeeds on a path that
# already exists read-only, and a path under a regular file fails only on the
# attempt. So attempt both, with the same symlink operation link_skills will use.
default_targets=("$HOME/.claude/skills" "$HOME/.agents/skills")
extra_targets=()
for extra_dir in ${extra_config_dirs[@]+"${extra_config_dirs[@]}"}; do
  extra_targets+=("$extra_dir/skills")
done
# Supplied targets are probed first: probing creates the directory, so validating a
# default before a bad profile path would leave that default behind on the failure.
for skill_target in ${extra_targets[@]+"${extra_targets[@]}"} "${default_targets[@]}"; do
  if ! mkdir -p "$skill_target" 2>/dev/null; then
    echo "$skill_target cannot be created — nothing was installed" >&2
    exit 1
  fi
  probe="$skill_target/.dcp-write-probe.$$"
  if ! ln -s /dev/null "$probe" 2>/dev/null; then
    echo "$skill_target is not writable — nothing was installed" >&2
    exit 1
  fi
  rm -f "$probe"
done

echo "Skills (symlinked; edits in the repo are live immediately):"
for skill_target in "${default_targets[@]}" ${extra_targets[@]+"${extra_targets[@]}"}; do
  link_skills "$skill_target"
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
