---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing; run the verification and read the output before making any claim
---

# Verification Before Completion

Evidence before claims. Before stating any status: identify the command that proves it, run it
on the final state (a passing run from this turn counts until a relevant change, failure or
open risk needs another), read the full output and exit code, then state the claim with its
evidence.

## What Each Claim Requires

| Claim | Requires | Not sufficient |
|-------|----------|----------------|
| Tests pass | Test output: 0 failures | Previous run, "should pass" |
| Build succeeds | Build exit 0 | Linter passing |
| Bug fixed | Original symptom re-tested | Code changed, assumed fixed |
| Regression test works | Red-green verified: fails without the fix, passes with it | Test passes once |
| Subagent completed | Diff inspected, changes verified | The agent's own "success" report |
| Procedure followed | The artifacts it leaves (files, commits, signals) | A report that it was followed |
| Requirements met | Line-by-line check against the spec/plan | Tests passing |

## Evidence Must Be Honest

Running the command is not enough if the evidence was shaped to pass. Confirm the check still
checks the original thing:

- No test was deleted, skipped, or weakened to get to green; a failing test is information,
  not an obstacle.
- No assertion was loosened (`toBe` to `toBeTruthy`, exact to substring) to accommodate the
  code.
- No error handling was added to swallow the failure the test was catching.

If the check had to change, say so and justify it; that is a spec change, not a fix. A check
modified in the same turn it started passing deserves a second look.

## Completion Receipt

Close with the always-on guide's four-line receipt (`AGENTS.md` -> Review and completion
receipt). `VERIFICATION: PASSED` only for a check you ran on the final state and read the output
of; `REVIEW: PASSED` only for the mechanism's terminal signal freshly checked at the current
HEAD.

Example of a handoff whose review hit its cap:

FIX: READY TO MERGE - Stopped the invoice export from dropping rows whose customer name contains
a comma, so finance gets complete monthly exports; branch `fix/export-quoting` at `3f2a9c1`.

VERIFICATION: PASSED - typecheck plus the export and billing unit tests (412 passing), including
a new regression test for quoted names.

REVIEW: BLOCKED - round cap reached with the last fix (quoting the name column) unreviewed. The
new regression test covers it and the change is two lines, so confidence is high; if it is
wrong, affected rows still export but with a malformed name cell.

NEXT STEP/OPTIONS: merge as-is (you waive the last review); approve one more review round; or
leave it unmerged.
