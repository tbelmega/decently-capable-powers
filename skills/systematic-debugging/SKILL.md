---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging

**Core principle:** Find the root cause before attempting any fix. Symptom patches waste time
and mask real issues.

## The Iron Law

```
NO FIXES WITHOUT ROOT-CAUSE INVESTIGATION FIRST
```

Applies to every technical issue — test failures, production bugs, build failures, performance,
integration. Especially under time pressure: systematic is faster than guess-and-check
thrashing. Simple-seeming bugs have root causes too.

## Phase 1 — Root-Cause Investigation

1. **Read the error completely** — stack trace, line numbers, error codes. It often contains
   the answer.
2. **Reproduce reliably.** Not reproducible → gather more data, don't guess.
3. **Check recent changes** — diff, commits, new dependencies, config, environment.
4. **Multi-component systems:** instrument every boundary (log what enters and exits each
   layer), run once, find WHERE it breaks — then investigate that component.
5. **Trace bad values backward** to their origin; fix at the source, not where the symptom
   appears. Full technique: [root-cause-tracing.md](root-cause-tracing.md).

## Phase 2 — Pattern Analysis

Find similar working code in the same codebase. Compare against reference implementations by
reading them completely, not skimming. List every difference, however small — don't assume
"that can't matter". Understand the dependencies, config, and assumptions involved.

## Phase 3 — Hypothesis and Testing

State one specific hypothesis ("X is the root cause because Y") → make the smallest possible
change that tests it → verify. Didn't work? Form a new hypothesis — don't stack more fixes on
top. Don't understand something? Say so and investigate; don't pretend.

## Phase 4 — Implementation

1. Create the failing test case first (the test-driven-development skill applies).
2. Implement one fix, addressing the root cause. No "while I'm here" improvements.
3. Verify: test passes, no other tests broken, original symptom gone.

## Phase 4.5 — 3+ Failed Fixes = Architecture Problem

If each fix reveals a new problem somewhere else, or fixes keep requiring bigger refactoring:
**stop**. This is not a failed hypothesis — the pattern itself is likely wrong. Question the
architecture with the user before attempting fix #4.

## Red Flags — return to Phase 1

"Quick fix for now, investigate later" · "just try changing X" · multiple changes at once ·
"it's probably X" · proposing fixes before tracing data flow · "one more fix attempt" after 2+
failures.

| Excuse | Reality |
|--------|---------|
| "Issue is simple, skip the process" | Simple issues have root causes too; the process is fast for them. |
| "Emergency — no time for process" | Systematic is faster than thrashing. |
| "Just try this first, then investigate" | The first fix sets the pattern. Do it right from the start. |
| "Multiple fixes at once saves time" | Can't isolate what worked; creates new bugs. |
| "One more attempt" (after 2+ failures) | 3+ failures = architectural problem. Step back. |

## When Investigation Truly Finds No Root Cause

Genuinely environmental, timing-dependent, or external → document what you investigated,
implement appropriate handling (retry, timeout, clear error), add logging for next time. But
most "no root cause" cases are incomplete investigation.

## Supporting Techniques (this directory)

- [root-cause-tracing.md](root-cause-tracing.md) — trace bugs backward through the call stack
- [defense-in-depth.md](defense-in-depth.md) — validate at multiple layers once the root cause is found
- [condition-based-waiting.md](condition-based-waiting.md) — replace arbitrary timeouts with condition polling
- `find-polluter.sh` — bisect test-order pollution
