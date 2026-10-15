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

"should" / "seems" / "probably" · satisfaction before verification ("Great!", "Done!") ·
committing or PRing without running the checks · trusting a subagent's success report ·
partial verification ("linter passed, so the build is fine") · a check modified in the same
turn it started passing · tired and wanting the work over.

## Completion Receipt

When about to claim work is complete, **close** with the always-on four-line receipt; it is the
last thing you print, below the prose, so the status is visible without scrolling.

```text
<WORK TYPE>: COMPLETE|INCOMPLETE - <one sentence: what this work was and what for>

VERIFICATION: PASSED|FAILED|NOT RUN - <one sentence: what was checked>

REVIEW: PASSED|REQUESTED|BLOCKED|NOT CONFIGURED|WAIVED|NOT RUN - <reviewer, rounds>

NEXT STEP/OPTIONS: <the next action, or the alternatives when it is the user's call>
```

That block is the template; print the receipt itself as plain paragraphs separated by blank
lines, never inside a code block. Markdown joins adjacent lines into one paragraph, and a code
block does not wrap the sentences.

- **Work type.** Name what was actually done, as specifically as fits: IMPLEMENTATION, FIX, SPEC,
  PLAN, RESEARCH, DOCS; TASK only when nothing narrower fits.
- **Context sentence.** Write it for a user who has just tabbed in from another thread and
  remembers nothing of this one: what the work was and what it was for, in plain words, with no
  ticket numbers, finding IDs, or other references they would have to look up.
- **Evidence.** After each sentence, attach compact evidence: the verification command and
  result; the review mechanism's current-HEAD status, reviewer, round, URL, or artifact.
- **Blocked review.** State the risk of landing now: what is unreviewed, what covers it anyway,
  how confident you are and why, and the impact if it is wrong.

`PASSED` means the configured terminal signal was freshly checked for the complete work.
`REQUESTED` means an asynchronous tool or human review is pending. `WAIVED` means the user
explicitly opted out. `NOT RUN` and `BLOCKED` are honest handoff states, never synonyms for
completion when review is required.

Example of a blocked handoff:

FIX: COMPLETE - Stopped the invoice export from dropping rows whose customer name contains a
comma, so finance gets complete monthly exports; `main` at `3f2a9c1`.

VERIFICATION: PASSED - typecheck plus the export and billing unit tests (412 passing), including
a new regression test for quoted names.

REVIEW: BLOCKED - round cap reached with the last fix (quoting the name column) unreviewed. The
new regression test covers it and the change is two lines, so confidence is high; if it is
wrong, affected rows still export but with a malformed name cell.

NEXT STEP/OPTIONS: land as-is (you waive the last review); approve one more review round; or
leave it unmerged.

`NEXT STEP/OPTIONS` states the single next action when the work is cleanly done, and enumerates
the real alternatives with their consequences when it is not, including doing nothing. Asking
for more of what you were already doing is never the only listed option. Before printing the
receipt, leave any tracked item accurate as of that moment, so the user can close the
conversation there without leaving a tracker stale.
