---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging

Find the root cause before attempting any fix, however simple or urgent the bug looks; a
symptom patch masks the real issue and sets the pattern for every later attempt.

## 1. Investigate

1. **Read the error completely:** stack trace, line numbers, error codes.
2. **Reproduce reliably.** Not reproducible: gather more data, don't guess.
3. **Check recent changes:** diff, commits, dependencies, config, environment.
4. **Multi-component systems:** log what enters and exits each boundary, run once, find where
   it breaks, then investigate that component.
5. **Trace a bad value back** through its callers to where it originates, and fix it there.
   When reading the code is not enough, log with a stack trace just before the failing
   operation.

## 2. Compare

Find similar working code in the same codebase, read it completely, and list every difference,
however small; don't assume one cannot matter.

## 3. Hypothesize and test

State one hypothesis ("X is the root cause because Y"), make the smallest change that tests it,
and check. If it fails, form a new hypothesis instead of stacking fixes. If you don't understand
something, say so and investigate.

## 4. Fix

1. Create the failing test case first, and watch it fail for the reason you diagnosed.
2. Implement one fix at the root cause. No "while I'm here" improvements.
3. Verify: the test passes, no other test broke, the original symptom is gone.

## After three failed fixes, step back

If each fix reveals a new problem elsewhere, or fixes keep needing bigger refactoring, stop: the
pattern itself is likely wrong. Question the architecture with the user before fix number four.

## When there truly is no root cause

Genuinely environmental, timing-dependent or external: document what you investigated, add
appropriate handling (retry, timeout, clear error) and logging for next time. Most "no root
cause" cases are an incomplete investigation.

## Tool

`find-polluter.sh` in this directory runs the matching test files one at a time and stops at
the first that leaves unwanted files or state behind (it runs `npm test`; adapt the command
to the project).
