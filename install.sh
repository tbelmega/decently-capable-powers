#!/usr/bin/env bash
# install.sh — deploy decently-capable-powers into user-level agent config.
#
# Default (no args): user-level install covering all four harnesses.
#   - Symlinks each skills/<name>/ into ~/.claude/skills/ (read by Claude Code
#     and Cursor) and ~/.agents/skills/ (read by Codex, Cursor, and Grok Build).
#     Cursor and Grok Build read both trees; identical names resolve to
#     identical content, so the overlap is harmless.
#   - Refreshes the operating-guide section (a <DECENTLY-CAPABLE-POWERS> tag pair
#     inside the shared <GENERATED> wrapper) in ~/.claude/CLAUDE.md (Claude Code)
#     and ~/.codex/AGENTS.md (Codex), migrating legacy DCP:START/END markers.
#     Every alternate Claude Code profile (CLAUDE_CONFIG_DIR=~/.claude-<name>)
#     is targeted like the default profile: its CLAUDE.md gets the section,
#     created if absent.
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
#   operating-guide section needs no such flag — every ~/.claude-* profile is
#   targeted automatically — but skills carry no such convention, so without
#   this flag their links are hand-made and never refreshed.
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
# Tag grammar shared with decently-coordinated-loops (agreed 2026-08-23): one outer
# <GENERATED> wrapper per config file holds one inner section per tool. A tag counts
# only when it is the entire trimmed line, and only as part of a nearest open/close
# pair — a prose mention of a tag elsewhere in the file is inert. Malformed or
# ambiguous tags fail closed: the file is reported and left untouched.
GEN_OPEN='<GENERATED>'
GEN_CLOSE='</GENERATED>'
SEC_OPEN='<DECENTLY-CAPABLE-POWERS>'
SEC_CLOSE='</DECENTLY-CAPABLE-POWERS>'
# Legacy markers, recognised for migration only: configs written before the tag
# grammar carry them. Matched as exact trimmed lines — the byte-for-byte forms the
# old installer wrote (verified as the only forms in the wild, 2026-08-23) — so a
# prose comment that merely starts like a marker is never treated as one.
LEGACY_START_LINE='<!-- DCP:START — managed block; edit in the decently-capable-powers repo, then re-run install.sh -->'
LEGACY_END_LINE='<!-- DCP:END -->'
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

# A symlink's identity, independent of how the path was spelled: its parent canonicalised,
# plus its own name. `./loop-a`, `alias/../loop-a` and `/abs/loop-a` are one link, and cycle
# detection has to see them as one — comparing the raw strings would let an aliased loop
# spin until the hop limit and be misreported as an over-long chain.
link_identity() {
  local link="$1"
  printf '%s/%s\n' "$(canonical_dir "$(dirname "$link")")" "$(basename "$link")"
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
        local identity
        identity="$(link_identity "$cur")"
        if printf '%s\n' "$visited" | grep -qxF -- "$identity"; then printf 'unknown:loop\n'; return; fi
        if [ "$hops" -ge "$LINK_HOP_LIMIT" ]; then printf 'unknown:depth\n'; return; fi
        target_state "$(link_destination "$cur")" "$((hops + 1))" "$visited
$identity"
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

# The guide section — the <DECENTLY-CAPABLE-POWERS>..</DECENTLY-CAPABLE-POWERS>
# region of this repo's AGENTS.md, tags included — written to $1. Aborts the install
# when the source is malformed (a missing, duplicated, orphaned, or misordered tag):
# every target would inherit the defect.
extract_section() {
  local out="$1"
  awk -v so="$SEC_OPEN" -v sc="$SEC_CLOSE" '
    function trim(s) { sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
    { t = trim($0); line[NR] = $0; n = NR
      if (t == so) { opens++; if (opens == 1) start = NR }
      else if (t == sc) { closes++; if (closes == 1) end = NR } }
    END {
      if (opens != 1 || closes != 1 || end < start) exit 1
      for (i = start; i <= end; i++) print line[i]
    }
  ' "$GUIDE" > "$out" || {
    echo "$GUIDE has no well-formed $SEC_OPEN section — nothing was installed" >&2
    exit 1
  }
}

# Both installers (this one and decently-coordinated-loops) rewrite the same config
# files with a read-modify-write; without mutual exclusion, concurrent runs could each
# read a one-section wrapper and the last writer would drop the other's newly written
# section. The lock is a `<target>.lock` directory — mkdir is atomic on POSIX —
# shared by protocol with the DCL seeder. A lock older than five minutes is treated
# as abandoned by a killed run and stolen. DCP_LOCK_TRIES caps the 0.2s-spaced
# attempts (test hook; default ~10s).
acquire_lock() {
  local lock="$1" tries="${DCP_LOCK_TRIES:-50}" i=0
  while ! mkdir "$lock" 2>/dev/null; do
    i=$((i + 1))
    if [ "$i" -ge "$tries" ]; then return 1; fi
    if [ -d "$lock" ] && [ -n "$(find "$lock" -maxdepth 0 -mmin +5 2>/dev/null)" ]; then
      rmdir "$lock" 2>/dev/null || true
      continue
    fi
    sleep 0.2
  done
  return 0
}

# Follow a symlink chain to its final path. A config symlink is a deliberate sharing
# arrangement: the referent must be edited in place, never the link replaced. Fails
# (empty output) past the hop limit — a loop.
resolve_target() {
  local t="$1" hops=0
  while [ -L "$t" ]; do
    hops=$((hops + 1))
    if [ "$hops" -gt "$LINK_HOP_LIMIT" ]; then return 1; fi
    t="$(link_destination "$t")"
  done
  printf '%s\n' "$t"
}

# Upsert the guide section into $1's <GENERATED> wrapper: replace an existing
# section in place, insert a missing one into the wrapper (created if absent), and
# migrate a legacy DCP:START/END block into the tag grammar. Sibling sections and
# everything outside the tags are preserved byte for byte, line endings and a
# missing final newline included; the one deliberate write outside the tags is the
# separator added when appending to a file that never carried the guide. Malformed
# or ambiguous tags — an orphan tag at either level, a section outside the wrapper,
# duplicated markers — skip the file with a report; the run continues for the other
# targets. A symlinked target has its referent edited in place, and the whole
# read-modify-write runs under the cross-installer lock.
refresh_block() {
  local target="$1" resolved
  if ! resolved="$(resolve_target "$target")"; then
    echo "  ! $target: symlink chain exceeds $LINK_HOP_LIMIT hops — left untouched"
    return 0
  fi
  mkdir -p "$(dirname "$resolved")"
  if ! acquire_lock "$target.lock"; then
    echo "  ! $target: could not acquire $target.lock — another installer holds it; re-run"
    return 0
  fi
  local block tmp status hadnl
  block="$(mktemp)"
  extract_section "$block"
  if [ ! -f "$resolved" ]; then
    {
      echo "# Operating guide"
      echo "$GEN_OPEN"
      cat "$block"
      echo "$GEN_CLOSE"
    } > "$resolved"
    echo "  created managed section in $target"
    rm -f "$block"
    rmdir "$target.lock" 2>/dev/null || true
    return 0
  fi
  # Replacement is staged beside the referent so the final mv is an atomic rename on
  # the same filesystem, never a copy-and-delete across TMPDIR.
  tmp="$(mktemp "$(dirname "$resolved")/.dcp-refresh.XXXXXX")"
  hadnl=1
  if [ -s "$resolved" ] && [ -n "$(tail -c1 "$resolved")" ]; then hadnl=0; fi
  status=0
  awk -v go="$GEN_OPEN" -v gc="$GEN_CLOSE" -v so="$SEC_OPEN" -v sc="$SEC_CLOSE" \
      -v ls="$LEGACY_START_LINE" -v le="$LEGACY_END_LINE" -v bf="$block" -v hadnl="$hadnl" '
    function trim(s) { sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
    function skip(reason) { print "SKIP " reason > "/dev/stderr"; exit 3 }
    function emit(s) { out[++m] = s }
    function section() { while ((getline l < bf) > 0) emit(l); close(bf) }
    { line[NR] = $0; n = NR }
    END {
      # Wrapper pairs: nearest open/close, exact trimmed lines only. Any orphan tag
      # is far more likely wreckage of a damaged block than prose — fail closed.
      gopen = 0; gpairs = 0
      for (i = 1; i <= n; i++) {
        t = trim(line[i])
        if (t == go) {
          if (gopen) skip(go " opened again before it was closed")
          gopen = i
        } else if (t == gc) {
          if (!gopen) skip(gc " without a matching " go)
          gpairs++; gO = gopen; gC = i; gopen = 0
          if (gpairs > 1) skip("more than one " go " block")
        }
      }
      if (gopen) skip(go " is never closed")
      # Own section pair, scanned across the whole file: an orphan tag or a section
      # outside the wrapper fails closed instead of being written around.
      sO = 0; sC = 0; sopen = 0; spairs = 0
      for (i = 1; i <= n; i++) {
        t = trim(line[i])
        if (t == so) {
          if (sopen) skip(so " opened again before it was closed")
          sopen = i
        } else if (t == sc) {
          if (!sopen) skip(sc " without a matching " so)
          spairs++; sO = sopen; sC = i; sopen = 0
          if (spairs > 1) skip("more than one " so " section")
        }
      }
      if (sopen) skip(so " is never closed")
      if (spairs == 1 && !gpairs) skip(so " section outside any " go " wrapper")
      if (spairs == 1 && (sO < gO || sC > gC)) skip(so " section outside the " go " wrapper")
      # Legacy region: exact historical marker lines only (a prose comment that
      # merely starts like one is not a marker). Duplicated markers are ambiguous;
      # a lone start never delimited a block for the old installer either.
      lstarts = 0; lends = 0; lO = 0; lC = 0
      for (i = 1; i <= n; i++) {
        t = trim(line[i])
        if (t == ls) { lstarts++; lO = lO ? lO : i }
        else if (t == le) { lends++; lC = lC ? lC : i }
      }
      if (lstarts > 1) skip("more than one legacy DCP:START marker")
      if (lends > 1) skip("more than one legacy DCP:END marker")
      if (lstarts != 1 || lends != 1 || lC < lO) { lO = 0; lC = 0 }

      endnl = hadnl
      if (gpairs == 1) {
        for (i = 1; i <= n; i++) {
          if (sO && i == sO) { section(); i = sC; continue }
          if (!sO && i == gC) section()
          if (lO && i == lO) { i = lC; continue }
          emit(line[i])
        }
        verdict = lO ? "MIGRATED" : (sO ? "REPLACED" : "APPENDED")
      } else if (lO) {
        for (i = 1; i <= n; i++) {
          if (i == lO) { emit(go); section(); emit(gc); i = lC; continue }
          emit(line[i])
        }
        verdict = "MIGRATED"
      } else {
        for (i = 1; i <= n; i++) emit(line[i])
        if (trim(line[n]) != "") emit("")
        emit("# Operating guide")
        emit(go); section(); emit(gc)
        verdict = "APPENDED"; endnl = 1
      }
      for (j = 1; j <= m; j++) printf "%s%s", out[j], (j < m || endnl) ? "\n" : ""
      print verdict > "/dev/stderr"
      exit 0
    }
  ' "$resolved" > "$tmp" 2> "$tmp.status" || status=$?
  if [ "$status" -eq 3 ]; then
    echo "  ! $target: $(sed 's/^SKIP //' "$tmp.status") — left untouched; fix the tags and re-run"
    rm -f "$tmp"
  elif [ "$status" -ne 0 ]; then
    echo "  ! $target: refresh failed (awk exit $status) — left untouched" >&2
    rm -f "$tmp"
  else
    mv "$tmp" "$resolved"
    case "$(cat "$tmp.status")" in
      MIGRATED) echo "  migrated legacy markers to the managed section in $target" ;;
      REPLACED) echo "  refreshed managed section in $target" ;;
      APPENDED) echo "  appended managed section to $target" ;;
    esac
  fi
  rm -f "$block" "$tmp.status"
  rmdir "$target.lock" 2>/dev/null || true
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

echo "Operating guide (managed section):"
refresh_block "$HOME/.claude/CLAUDE.md"
# Every alternate profile directory is targeted like the default one (owner ruling
# 2026-08-23; previously profiles opted in by already carrying the marker). The
# trailing-slash glob matches directories only, and an unmatched glob stays literal,
# which the -d test filters out.
for alt_profile in "$HOME"/.claude-*/; do
  [ -d "$alt_profile" ] || continue
  refresh_block "${alt_profile%/}/CLAUDE.md"
done
refresh_block "$HOME/.codex/AGENTS.md"

cat <<'EOF'

Cursor has no file-based global instructions — one manual step:
  paste the contents of this repo's AGENTS.md into
  Cursor → Settings → Rules → User Rules, and re-paste whenever the guide
  changes. (Skills reach Cursor automatically via the symlinks above.)

Done.
EOF
