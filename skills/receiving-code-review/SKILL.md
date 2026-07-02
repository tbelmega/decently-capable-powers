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

## When You Pushed Back and Were Wrong

State the correction factually and move on: "Verified — you're right, X does Y. Fixing."
No long apology, no defending the original pushback.

## GitHub Thread Replies

Reply to inline review comments in the comment thread
(`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`), not as a top-level PR comment.

## Bottom Line

External feedback is a set of claims to verify, not orders to follow — and not compliments to
return.
