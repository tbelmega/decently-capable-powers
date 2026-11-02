---
name: receiving-code-review
description: Use when receiving code review feedback, before implementing suggestions: technical evaluation and verification, not performative agreement or blind implementation
---

# Receiving Code Review

Review feedback gets technical evaluation, not emotional performance: read all of it, restate
each requirement, verify each claim against the actual codebase, then respond with a technical
acknowledgment or reasoned pushback, and implement one item at a time, testing each.

No performative agreement ("You're absolutely right!", "Great point!"), no thanks, no "let me
implement that now" before verifying. Restate, ask, push back, or just make the fix and show it.

## Unclear Feedback

Where someone can answer, clarify unclear items before implementing any: items may be related,
and partial understanding produces wrong implementations ("I understand 1, 2, 3 and 6; I need
clarification on 4 and 5."). With no one to ask, disposition the unclear item per the active
review orchestrator, stating your reading of it.

## Evaluating Feedback

Is it correct for this codebase? Does it break existing behavior? Is there a reason the code is
the way it is? Does the reviewer have full context?

- **Wrong:** push back with technical reasoning, citing working tests and code.
- **Can't verify:** say so: "I can't verify this without X. Investigate, ask, or proceed?"
- **Conflicts with the user's prior decisions:** discuss with the user first.
- **"Implement X properly":** grep for actual usage first; if unused, suggest removal instead.

## Fix the Pattern, Not the Location

A finding is evidence of a pattern, not merely a place to patch. Before marking one fixed:

1. **Name its root-cause pattern** in one sentence: the mistake, not the symptom.
2. **Sweep the whole review range for siblings**, plus the files the changed code was copied
   from or modelled on, and identify them before choosing the finding's disposition.
3. **Correcting a fact or a contract? Sweep every restatement of it.** Update each, or replace
   it with a link to one canonical source.

When an active review orchestrator provides a durable finding-disposition and follow-up workflow,
follow its scope decision about whether a confirmed sibling is fixed here or delegated. Without
one, fix confirmed sibling occurrences in the same change. A sibling that is neither fixed nor
durably delegated returns as a later-round finding and costs a full round.

Durable records name the command and its terminal signal, never a count that goes stale as the
tests or the inventory grow: "the suite passes" survives, "59 checks pass" does not.

## What a Clean Round Does Not Prove

A reviewer reporting complete file coverage has not certified that the defects are all found:
a clean round means that pass produced no finding. The round cap bounds cost; it does not
demonstrate convergence. Report either as what it is, never as "the code is now correct".

## When Your Pushback Was Wrong

State the correction factually and move on: "Verified, you're right: X does Y. Fixing." No long
apology, no defending the original pushback.

## GitHub Thread Replies

Reply to inline review comments in the comment thread
(`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`), not as a top-level PR comment.
