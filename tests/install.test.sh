#!/usr/bin/env bash
# tests/install.test.sh — regression coverage for install.sh's argument handling
# and skill linking. Every case runs against an isolated HOME under a temp dir, so
# the suite never reads or writes the real user config.
#
# Run: ./tests/install.test.sh   (exit 0 = all cases pass; failures are listed)

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL="$REPO_DIR/install.sh"
SKILL_COUNT="$(find "$REPO_DIR/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
failures=0

fail() { echo "  FAIL: $*"; failures=$((failures + 1)); }
ok() { echo "  ok: $*"; }

check() { # check <description> <expected> <actual>
  if [ "$2" = "$3" ]; then ok "$1"; else fail "$1 — expected '$2', got '$3'"; fi
}

# Each case gets a fresh isolated HOME; $sandbox and $home are set for the body.
new_sandbox() {
  sandbox="$(mktemp -d)"
  home="$sandbox/home"
  mkdir -p "$home"
}

link_target() { readlink "$1" 2>/dev/null || echo "<not a link>"; }
count_links_into_repo() { # <skills dir>
  find "$1" -maxdepth 1 -type l -lname "$REPO_DIR/skills/*" 2>/dev/null | wc -l | tr -d ' '
}

echo "install.sh: rejects invalid arguments"
new_sandbox
out="$(HOME="$home" "$INSTALL" --config-dir 2>&1)"; status=$?
check "missing value exits nonzero" "1" "$status"
case "$out" in *"requires a non-empty directory"*) ok "missing value names the flag";;
  *) fail "missing value message unexpected: $out";; esac
out="$(HOME="$home" "$INSTALL" --config-dir "" 2>&1)"; status=$?
check "empty value exits nonzero" "1" "$status"
[ -e /skills ] && fail "empty value created /skills" || ok "empty value did not target /skills"
check "no default targets written on a rejected run" "0" "$([ -d "$home/.claude" ] && echo 1 || echo 0)"
out="$(HOME="$home" "$INSTALL" --bogus 2>&1)"; status=$?
check "unknown flag exits nonzero" "1" "$status"
case "$out" in *"usage: install.sh"*) ok "unknown flag prints usage";; *) fail "no usage line: $out";; esac
out="$(HOME="$home" "$INSTALL" --config-dir "$home/.claude-x" --project "$sandbox" 2>&1)"; status=$?
check "--config-dir with --project exits nonzero" "1" "$status"
case "$out" in *"does nothing with --project"*) ok "conflict is explained";; *) fail "no conflict message: $out";; esac
rm -rf "$sandbox"

echo "install.sh: --project leaves the user-level config alone"
new_sandbox
mkdir -p "$sandbox/proj"
HOME="$home" "$INSTALL" --project "$sandbox/proj" >/dev/null 2>&1
check "--project exits 0" "0" "$?"
check "AGENTS.md written" "1" "$([ -f "$sandbox/proj/AGENTS.md" ] && echo 1 || echo 0)"
check "CLAUDE.md imports it" "1" "$(grep -c '@AGENTS.md' "$sandbox/proj/CLAUDE.md")"
check "no user-level skills touched" "0" "$([ -d "$home/.claude" ] && echo 1 || echo 0)"
rm -rf "$sandbox"

echo "install.sh: links every skill into repeated --config-dir targets, including paths with spaces"
new_sandbox
spaced="$home/.claude-profile with spaces"
HOME="$home" "$INSTALL" --config-dir "$spaced" --config-dir "$home/.claude-second" >/dev/null 2>&1
check "run exits 0" "0" "$?"
check "default ~/.claude linked" "$SKILL_COUNT" "$(count_links_into_repo "$home/.claude/skills")"
check "default ~/.agents linked" "$SKILL_COUNT" "$(count_links_into_repo "$home/.agents/skills")"
check "profile with spaces linked" "$SKILL_COUNT" "$(count_links_into_repo "$spaced/skills")"
check "second profile linked" "$SKILL_COUNT" "$(count_links_into_repo "$home/.claude-second/skills")"

echo "install.sh: a second run is idempotent"
before="$(find "$spaced/skills" -maxdepth 1 -type l -printf '%f %l\n' | sort)"
out="$(HOME="$home" "$INSTALL" --config-dir "$spaced" --config-dir "$home/.claude-second" 2>&1)"
check "rerun exits 0" "0" "$?"
check "no links changed" "$before" "$(find "$spaced/skills" -maxdepth 1 -type l -printf '%f %l\n' | sort)"
case "$out" in *"$SKILL_COUNT already current"*) ok "rerun reports links as current";;
  *) fail "rerun did not report current links";; esac
rm -rf "$sandbox"

echo "install.sh: repairs dangling links, preserves live foreign ones"
new_sandbox
profile="$home/.claude-drift"
mkdir -p "$profile/skills" "$sandbox/elsewhere/research"
ln -s "$sandbox/gone/skills/brainstorming" "$profile/skills/brainstorming"   # dangling: repo moved
ln -s "$sandbox/elsewhere/research" "$profile/skills/research"               # live: someone else's
out="$(HOME="$home" "$INSTALL" --config-dir "$profile" 2>&1)"
check "run exits 0" "0" "$?"
check "dangling link repointed at this repo" "$REPO_DIR/skills/brainstorming" "$(link_target "$profile/skills/brainstorming")"
check "live foreign link untouched" "$sandbox/elsewhere/research" "$(link_target "$profile/skills/research")"
case "$out" in *"is not a link to this repo — left untouched"*) ok "foreign link is reported";;
  *) fail "foreign link was not reported";; esac
check "no dangling links remain" "0" "$(find "$profile/skills/" -maxdepth 1 -xtype l | wc -l | tr -d ' ')"
rm -rf "$sandbox"

echo
if [ "$failures" -eq 0 ]; then echo "All install.sh cases passed."; else echo "$failures check(s) failed."; fi
exit $((failures > 0))
