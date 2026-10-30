---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing; run the verification and read the output before making any claim
---

# Verification Before Completion

**Core principle:** Evidence before claims, always. Claiming completion without verification is
dishonesty, not efficiency.

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

Use fresh evidence for the final work state. A passing check from this turn remains evidence
until relevant changes, failures, or unresolved risk require another run.

## The Gate

Before claiming any status:

1. **Identify** the command that proves the claim
2. **Run** it, fresh and complete, unless current-state evidence already exists in this turn
3. **Read** the full output; check the exit code; count the failures
4. **Only then** state the claim, together with the evidence

Run checks appropriate to the change once. Repeat or broaden only after relevant changes,
failures, or unresolved risk. Do not add verifier subagents automatically.

## What Each Claim Requires

| Claim | Requires | Not sufficient |
|-------|----------|----------------|
| Tests pass | Test output: 0 failures | Previous run, "should pass" |
| Build succeeds | Build exit 0 | Linter passing |
| Bug fixed | Original symptom re-tested | Code changed, assumed fixed |
| Regression test works | Red-green verified: fails without the fix, passes with it | Test passes once |
| Subagent completed | Diff inspected, changes verified | The agent's own "success" report |
| Requirements met | Line-by-line check against the spec/plan | Tests passing |

## Evidence Must Be Honest

Running the command is not enough if the evidence was shaped to pass. Before claiming success,
confirm the check still checks the original thing:

- No test was deleted, skipped, or weakened to get to green - a failing test is information,
  not an obstacle.
- No assertion was loosened (`toBe` → `toBeTruthy`, exact → substring) to accommodate the code.
- Error handling wasn't added to swallow the failure the test was catching.

If the check had to change, say so explicitly and justify it; that's a spec change, not a fix.

## Red Flags

a claim worded to sound verified when it was not · satisfaction before verification ("Great!", "Done!") ·
committing or PRing without running the checks · trusting a subagent's success report ·
partial verification ("linter passed, so the build is fine") · a check modified in the same
turn it started passing · tired and wanting the work over.

## Completion Receipt

Close with the always-on guide's four-line receipt (`AGENTS.md` -> Review and completion
receipt); it defines the values and what each line says. Two points this check feeds:
`VERIFICATION: PASSED` only for a check you ran on the final state and read the output of, and
`REVIEW: PASSED` only for the mechanism's terminal signal freshly checked at the current HEAD.

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
