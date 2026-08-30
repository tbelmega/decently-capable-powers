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

If you haven't run the verification command in this turn, you cannot claim it passes.

## The Gate

Before claiming any status:

1. **Identify** the command that proves the claim
2. **Run** it, fresh and complete
3. **Read** the full output; check the exit code; count the failures
4. **Only then** state the claim, together with the evidence

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

"should" / "seems" / "probably" · satisfaction before verification ("Great!", "Done!") ·
committing or PRing without running the checks · trusting a subagent's success report ·
partial verification ("linter passed, so the build is fine") · a check modified in the same
turn it started passing · tired and wanting the work over.

## Completion Receipt

When about to claim work is complete, **close** with the always-on four-line receipt; it is the
last thing you print, below the prose, so the status is visible without scrolling.

```text
IMPLEMENTATION: COMPLETE|INCOMPLETE
VERIFICATION: PASSED|FAILED|NOT RUN
REVIEW: PASSED|REQUESTED|BLOCKED|NOT CONFIGURED|WAIVED|NOT RUN
NEXT STEP/OPTIONS: <the next action, or the alternatives when it is the user's call>
```

Attach compact evidence to each applicable line: the verification command and result; and the
review mechanism's current-HEAD status, reviewer, round, URL, or artifact. `PASSED` means the
configured terminal signal was freshly checked for the complete work. `REQUESTED`
means an asynchronous tool or human review is pending. `WAIVED` means the user explicitly opted
out. `NOT RUN` and `BLOCKED` are honest handoff states, never synonyms for completion when review
is required.

`NEXT STEP/OPTIONS` states the single next action when the work is cleanly done, and enumerates
the real alternatives with their consequences when it is not, including doing nothing. Asking
for more of what you were already doing is never the only listed option. Before printing the
receipt, leave any tracked item accurate as of that moment, so the user can close the
conversation there without leaving a tracker stale.
