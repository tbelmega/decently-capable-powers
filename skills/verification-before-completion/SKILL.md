---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing — run the verification and read the output before making any claim
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
2. **Run** it — fresh and complete
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

- No test was deleted, skipped, or weakened to get to green — a failing test is information,
  not an obstacle.
- No assertion was loosened (`toBe` → `toBeTruthy`, exact → substring) to accommodate the code.
- Error handling wasn't added to swallow the failure the test was catching.

If the check had to change, say so explicitly and justify it — that's a spec change, not a fix.

## Red Flags

"should" / "seems" / "probably" · satisfaction before verification ("Great!", "Done!") ·
committing or PRing without running the checks · trusting a subagent's success report ·
partial verification ("linter passed, so the build is fine") · a check modified in the same
turn it started passing · tired and wanting the work over.

## Bottom Line

Run the command. Read the output. Then claim the result — with the evidence.
