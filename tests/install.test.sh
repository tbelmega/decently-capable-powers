#!/usr/bin/env bash
# tests/install.test.sh — regression coverage for install.sh's argument handling
# and skill linking.
#
# Every case runs a *copy* of the installer inside a temp fixture, with HOME
# pointed there too. Both halves matter: HOME isolation contains the config
# writes, and the copy contains seed_local_files, which writes *.local.md next to
# the installer it runs from — the real checkout, if the real installer were used.
#
# Portability: POSIX shell builtins, readlink without -f, and globs only. No GNU
# find extensions (-printf, -lname, -xtype) and no `readlink -f`, because install.sh
# supports macOS, whose BSD find and readlink lack them. Assertions stay inside the
# sandbox — nothing may depend on host state such as an existing /skills.
#
# Run: ./tests/install.test.sh   (exit 0 = all cases pass; failures are listed)

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

fail() { echo "  FAIL: $*"; failures=$((failures + 1)); }
ok() { echo "  ok: $*"; }
check() { # <description> <expected> <actual>
  if [ "$2" = "$3" ]; then ok "$1"; else fail "$1 — expected '$2', got '$3'"; fi
}

# A disposable fixture: the installer, the guide it manages, and the skills it
# links. $fixture/install.sh resolves REPO_DIR to the fixture, so every write the
# installer makes — links, managed blocks, seeded *.local.md — stays in $sandbox.
new_sandbox() {
  # Deriving paths from an empty $sandbox would compute /home and /repo and write
  # there, so a failed mktemp must abort before any path is built from it.
  sandbox="$(mktemp -d)" || { echo "FATAL: mktemp -d failed; refusing to run" >&2; exit 2; }
  if [ -z "$sandbox" ] || [ ! -d "$sandbox" ]; then
    echo "FATAL: mktemp -d produced no usable directory; refusing to run" >&2
    exit 2
  fi
  home="$sandbox/home"
  fixture="$sandbox/repo"
  mkdir -p "$home" "$fixture"
  cp "$REPO_DIR/install.sh" "$fixture/install.sh"
  cp "$REPO_DIR/AGENTS.md" "$fixture/AGENTS.md"
  cp -R "$REPO_DIR/skills" "$fixture/skills"
  install_sh="$fixture/install.sh"
  skill_count=0
  for d in "$fixture"/skills/*/; do [ -d "$d" ] && skill_count=$((skill_count + 1)); done
}

# Portable link inspection: readlink with no flags prints a symlink's stored
# target on both GNU and BSD; -L/-e distinguish link, live link, and dangling.
link_target() { if [ -L "$1" ]; then readlink "$1"; else echo "<not a link>"; fi; }

count_links_into_fixture() { # <skills dir> — links whose target is inside $fixture/skills
  local n=0 entry
  for entry in "$1"/*; do
    [ -L "$entry" ] || continue
    case "$(readlink "$entry")" in "$fixture/skills/"*) n=$((n + 1));; esac
  done
  echo "$n"
}

list_links() { # <skills dir> — "name target" per line, sorted
  local entry
  for entry in "$1"/*; do
    [ -L "$entry" ] || continue
    echo "$(basename "$entry") $(readlink "$entry")"
  done | sort
}

count_dangling() { # <skills dir>
  local n=0 entry
  for entry in "$1"/*; do
    if [ -L "$entry" ] && [ ! -e "$entry" ]; then n=$((n + 1)); fi
  done
  echo "$n"
}

echo "install.sh: rejects invalid arguments"
new_sandbox
out="$(HOME="$home" "$install_sh" --config-dir 2>&1)"; status=$?
check "missing value exits nonzero" "1" "$status"
case "$out" in *"requires a non-empty directory"*) ok "missing value names the flag";;
  *) fail "missing value message unexpected: $out";; esac
out="$(HOME="$home" "$install_sh" --config-dir "" 2>&1)"; status=$?
check "empty value exits nonzero" "1" "$status"
check "no default targets written on a rejected run" "0" "$([ -d "$home/.claude" ] && echo 1 || echo 0)"

# A forgotten value leaves the next option as $2. Run from inside the sandbox so a
# relative target ("--repair-links/skills") would be created here and be visible.
out="$(cd "$sandbox" && HOME="$home" "$install_sh" --config-dir --repair-links 2>&1)"; status=$?
check "option token as value exits nonzero" "1" "$status"
case "$out" in *"is not an option"*) ok "option-token rejection is explained";;
  *) fail "option-token message unexpected: $out";; esac
check "no default targets written on the rejected run" "0" "$([ -d "$home/.claude" ] && echo 1 || echo 0)"
check "no relative target directory created" "0" "$([ -e "$sandbox/--repair-links" ] && echo 1 || echo 0)"
# An unusable profile path must be caught before the default targets are written.
printf 'not a directory\n' > "$sandbox/a-file"
out="$(HOME="$home" "$install_sh" --config-dir "$sandbox/a-file" 2>&1)"; status=$?
check "config dir that is a file exits nonzero" "1" "$status"
case "$out" in *"is not a directory"*) ok "non-directory target is explained";;
  *) fail "non-directory message unexpected: $out";; esac
check "no default targets written for a non-directory target" "0" "$([ -d "$home/.claude" ] && echo 1 || echo 0)"
ln -s "$sandbox/nowhere" "$sandbox/dangling-profile"
out="$(HOME="$home" "$install_sh" --config-dir "$sandbox/dangling-profile" 2>&1)"; status=$?
check "dangling config dir exits nonzero" "1" "$status"
check "no default targets written for a dangling target" "0" "$([ -d "$home/.claude" ] && echo 1 || echo 0)"
printf 'not a directory\n' > "$sandbox/ancestor-file"
out="$(HOME="$home" "$install_sh" --config-dir "$sandbox/ancestor-file/child" 2>&1)"; status=$?
check "config dir under a file ancestor exits nonzero" "1" "$status"
check "no default targets written for a file ancestor" "0" "$([ -d "$home/.claude" ] && echo 1 || echo 0)"
mkdir -p "$sandbox/profile-bad-skills"; printf 'x\n' > "$sandbox/profile-bad-skills/skills"
out="$(HOME="$home" "$install_sh" --config-dir "$sandbox/profile-bad-skills" 2>&1)"; status=$?
check "config dir whose skills path is a file exits nonzero" "1" "$status"
check "no default targets written for an unusable skills path" "0" "$([ -d "$home/.claude" ] && echo 1 || echo 0)"

out="$(HOME="$home" "$install_sh" --bogus 2>&1)"; status=$?
check "unknown flag exits nonzero" "1" "$status"
case "$out" in *"usage: install.sh"*) ok "unknown flag prints usage";; *) fail "no usage line: $out";; esac
out="$(HOME="$home" "$install_sh" --config-dir "$home/.claude-x" --project "$sandbox" 2>&1)"; status=$?
check "--config-dir with --project exits nonzero" "1" "$status"
out="$(HOME="$home" "$install_sh" --repair-links --project "$sandbox" 2>&1)"; status=$?
check "--repair-links with --project exits nonzero" "1" "$status"
case "$out" in *"do nothing with --project"*) ok "conflict is explained";; *) fail "no conflict message: $out";; esac
rm -rf "$sandbox"

echo "install.sh: --project leaves the user-level config alone"
new_sandbox
mkdir -p "$sandbox/proj"
HOME="$home" "$install_sh" --project "$sandbox/proj" >/dev/null 2>&1
check "--project exits 0" "0" "$?"
check "AGENTS.md written" "1" "$([ -f "$sandbox/proj/AGENTS.md" ] && echo 1 || echo 0)"
check "CLAUDE.md imports it" "1" "$(grep -c '@AGENTS.md' "$sandbox/proj/CLAUDE.md")"
check "no user-level skills touched" "0" "$([ -d "$home/.claude" ] && echo 1 || echo 0)"
rm -rf "$sandbox"

echo "install.sh: links every skill into repeated --config-dir targets, including paths with spaces"
new_sandbox
spaced="$home/.claude-profile with spaces"
HOME="$home" "$install_sh" --config-dir "$spaced" --config-dir "$home/.claude-second" >/dev/null 2>&1
check "run exits 0" "0" "$?"
check "default ~/.claude linked" "$skill_count" "$(count_links_into_fixture "$home/.claude/skills")"
check "default ~/.agents linked" "$skill_count" "$(count_links_into_fixture "$home/.agents/skills")"
check "profile with spaces linked" "$skill_count" "$(count_links_into_fixture "$spaced/skills")"
check "second profile linked" "$skill_count" "$(count_links_into_fixture "$home/.claude-second/skills")"
check "personal config seeded inside the fixture, not the checkout" "1" \
  "$([ -f "$fixture/skills/model-selection/roster.local.md" ] && echo 1 || echo 0)"

echo "install.sh: a second run is idempotent"
before="$(list_links "$spaced/skills")"
out="$(HOME="$home" "$install_sh" --config-dir "$spaced" --config-dir "$home/.claude-second" 2>&1)"
check "rerun exits 0" "0" "$?"
check "no links changed" "$before" "$(list_links "$spaced/skills")"
case "$out" in *"$skill_count already current"*) ok "rerun reports links as current";;
  *) fail "rerun did not report current links";; esac
rm -rf "$sandbox"

echo "install.sh: leaves dangling links alone by default, names the flag that fixes them"
new_sandbox
profile="$home/.claude-drift"
mkdir -p "$profile/skills" "$sandbox/elsewhere/research"
ln -s "$sandbox/gone/skills/brainstorming" "$profile/skills/brainstorming"  # dangling: repo moved
ln -s "$sandbox/offline/skills/agent-handover" "$profile/skills/agent-handover"  # dangling: foreign, offline
ln -s "$sandbox/elsewhere/research" "$profile/skills/research"              # live: someone else's
out="$(HOME="$home" "$install_sh" --config-dir "$profile" 2>&1)"
check "default run exits 0" "0" "$?"
check "dangling link untouched by default" "$sandbox/gone/skills/brainstorming" "$(link_target "$profile/skills/brainstorming")"
check "dangling foreign link untouched by default" "$sandbox/offline/skills/agent-handover" "$(link_target "$profile/skills/agent-handover")"
case "$out" in *"rerun with --repair-links"*) ok "default run names the repair flag";;
  *) fail "default run did not name --repair-links";; esac
check "live foreign link untouched" "$sandbox/elsewhere/research" "$(link_target "$profile/skills/research")"

echo "install.sh: --repair-links repoints dangling links, still never live ones"
out="$(HOME="$home" "$install_sh" --config-dir "$profile" --repair-links 2>&1)"
check "repair run exits 0" "0" "$?"
check "dangling link repointed at this repo" "$fixture/skills/brainstorming" "$(link_target "$profile/skills/brainstorming")"
check "dangling foreign link also repointed under the explicit flag" "$fixture/skills/agent-handover" "$(link_target "$profile/skills/agent-handover")"
check "live foreign link still untouched" "$sandbox/elsewhere/research" "$(link_target "$profile/skills/research")"
case "$out" in *"is not a link to this repo — left untouched"*) ok "live foreign link is reported";;
  *) fail "live foreign link was not reported";; esac
case "$out" in *"was dangling: $sandbox/gone/skills/brainstorming"*)
    ok "repair reports the exact target it replaced";;
  *) fail "repair did not report the exact replaced target";; esac
check "no dangling links remain" "0" "$(count_dangling "$profile/skills")"
rm -rf "$sandbox"

echo
if [ "$failures" -eq 0 ]; then echo "All install.sh cases passed."; else echo "$failures check(s) failed."; fi
exit $((failures > 0))
