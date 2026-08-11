---
name: receiving-code-review
description: Use when receiving code review feedback, before implementing suggestions — technical evaluation and verification, not performative agreement or blind implementation
---

# Receiving Code Review

Code review requires technical evaluation, not emotional performance.

**Core principle:** Verify before implementing. Ask before assuming. Technical correctness over
social comfort.

## The Response Pattern

1. **Read** the complete feedback without reacting
2. **Understand** — restate each requirement in your own words, or ask
3. **Verify** — check each claim against the actual codebase
4. **Evaluate** — technically sound for THIS codebase?
5. **Respond** — technical acknowledgment or reasoned pushback
6. **Implement** — one item at a time, test each

## Banned Responses

- "You're absolutely right!" / "Great point!" — performative agreement
- Any gratitude expression — the fix itself shows you heard the feedback
- "Let me implement that now" — before verifying the claim

Instead: restate the requirement, ask the clarifying question, push back with technical
reasoning, or just make the fix and show it.

## Unclear Feedback

If any item is unclear, stop — don't implement the clear ones yet. Items may be related, and
partial understanding produces wrong implementations.

> "I understand items 1, 2, 3, 6. Need clarification on 4 and 5 before proceeding."

## Evaluating External Feedback

Before implementing, check: Is it technically correct for this codebase? Does it break existing
functionality? Is there a reason the current implementation is the way it is? Does the reviewer
have full context?

- **Suggestion seems wrong** → push back with technical reasoning, not defensiveness. Reference
  working tests and code.
- **Can't verify** → say so: "I can't verify this without X. Investigate, ask, or proceed?"
- **Conflicts with the user's prior decisions** → stop and discuss with the user first.
- **Reviewer proposes "implementing X properly"** → grep for actual usage first. Unused?
  Suggest removal (YAGNI) instead of building it out.

## Implementation Order

Clarify everything first, then: blocking issues (breakage, security) → simple fixes → complex
fixes. Test each individually; verify no regressions.

## Fix the Pattern, Not the Location

A finding is evidence of a pattern, not merely a place to patch. Before marking one fixed:

1. **Name its root-cause pattern** in one sentence — the mistake, not the symptom.
2. **Sweep the whole review range for siblings**, plus the files the changed code was copied
   from or modelled on, and fix them in the same change.
3. **Correcting a fact or a contract? Sweep every restatement of it.** Update each, or replace
   it with a link to one canonical source.

A sibling you leave behind returns as a later-round finding and costs a full round.

Durable records name the command and its terminal signal, never a count that goes stale as the
tests or the inventory grow: "the suite passes" survives, "59 checks pass" does not.

## What a Clean Round Does Not Prove

A reviewer reporting complete file coverage has not certified that the defects are all found —
a clean round means that pass produced no finding. The round cap bounds cost; it does not
demonstrate convergence. Report either as what it is, never as "the code is now correct".

## When You Pushed Back and Were Wrong

State the correction factually and move on: "Verified — you're right, X does Y. Fixing."
No long apology, no defending the original pushback.

## GitHub Thread Replies

Reply to inline review comments in the comment thread
(`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`), not as a top-level PR comment.

## Bottom Line

External feedback is a set of claims to verify, not orders to follow — and not compliments to
return.
