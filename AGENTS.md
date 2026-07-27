# Operating guide
<!-- DCP:START — managed block; edit in the decently-capable-powers repo, then re-run install.sh -->

Always-on working defaults. Each is the essence (the fallback); where a fuller procedure exists,
a → line says which skill to load for depth. Loading is the model's judgment, not enforced —
but never cite a skill ("per X") you haven't actually loaded; apply the essence and say so, or
load the skill.

## Before building
For non-trivial work the user hasn't already fully specified, turn the idea into an agreed design
before implementing. → When starting feature/creative work, load `brainstorming`.

## Scope
Build what was asked — the smallest change that fulfills the request. No unrequested features,
refactors, files, or "while I'm here" improvements; propose extras, don't build them.

## Owner attention
(Provisional rule — adopted 2026-07-20, to be reviewed after real-world use.)
The user's attention is the scarcest resource. Shape everything put before them to minimize
their time-to-decision: asks and recommendations first, evidence behind them; never make them
read pages to discover a question. Prefer resolving a decision yourself over parking it on the
user whenever your rules allow it.

## Understanding unfamiliar code
Before planning against a codebase, system, or feature you don't already understand, map how it
actually works first — don't guess from names. → To map or document current behavior, load
`research`.

## Testing — decide once per work-stream, not per task
When you start a distinct body of work (a new plan/epic, or the first code-changing turn), ask
the user once whether to follow TDD, and let them scope it ("yes for domain logic, no for infra").
Don't re-ask per task; re-ask only when the work clearly shifts to a different area. When TDD is
on: prefer integration-style tests over mock-heavy unit tests, shape structure before
implementing, and skip infra/config/throwaway unless asked. → When TDD is on, load
`test-driven-development`.

## Test integrity
Never get to green by weakening the red: don't delete, skip, or loosen a failing test, and don't
swallow the error it exposes. If the test itself is wrong, fix it as its own explicit step with
the reason stated — never silently in the change that makes it pass.

## Debugging
Find the root cause before proposing a fix; don't patch symptoms. If 3+ fixes fail, suspect the
architecture and step back. → On any bug/test failure/unexpected behavior, load
`systematic-debugging`.

## Verify before completion
Never claim done/fixed/passing without running the check and showing the evidence — and the
check must be the original, unweakened one. Ban "should", "seems", "probably". → For the full
checklist, load `verification-before-completion`.

## Commits
End each task by running typecheck + tests; commit when green with a clear message. Aim for small,
self-contained, green commits.

## Worktrees and checkouts — the user assigns them, you never change them
Work where you were started. **Never switch, create, or delete a git worktree, and never check
out a different branch, unless the user told you to in this session.** Assume the working
directory you were launched in was chosen deliberately; a worktree you were not pointed at is
someone else's workspace, possibly with a session live in it right now. If you believe a
different worktree is genuinely needed, say so and wait for an answer — do not act and report
afterwards.

This holds even when git would succeed and even when it looks tidy. Switching a worktree moves
files under an editor the user has open. Creating a scratch worktree leaves clutter they must
find and remove. The cost lands on them, not on you, and it is invisible from inside the task.

**Never `git stash` files you did not create**, and never stash to satisfy a tool that demands a
clean tree. Stashed work disappears from the user's editor and file manager with no trace they
would think to look for; they can lose access to their own in-progress work while you carry on.
If a command needs a clean tree, name the files that are in the way and ask.

Treat another session's uncommitted, untracked, or staged files as strictly read-only — do not
commit, move, revert, format, or clean them, and do not fold them into your own commits.

The one decision that *is* yours to raise: as with testing, ask once per work-stream whether to
work in an isolated branch or the current checkout; don't re-ask per task.

## Independent review before hand-off
When you start a distinct body of work (a new plan/epic, or the first code-changing turn),
check whether the project defines a mechanism to request a code review. If not, ask the user once
whether to request a code review at the end of this workstream and let them scope it ("raise a PR
for human review" or "invoke tool X").

Ensure the user decision or standing rule on this review gate is explicitly noted at the end of
the respective spec / plan / tracking item.

After every task in the distinct body of work is complete and final verification passes, request
the review without waiting for the user to remind you.
If the requested handoff state prevents review, preserve that state and report review as `NOT RUN`.

## Completion receipt
Begin the final handoff of a distinct body of work with these
three lines, adding concise command, HEAD, URL, or review-artifact evidence after the status:

    IMPLEMENTATION: COMPLETE|INCOMPLETE
    VERIFICATION: PASSED|FAILED|NOT RUN
    REVIEW: PASSED|REQUESTED|BLOCKED|NOT CONFIGURED|WAIVED|NOT RUN

`REQUESTED` means an asynchronous tool or human has the review but has not completed it; `WAIVED`
requires the user's explicit opt-out. Never claim the overall work complete when its
required review has not passed.

## Context hygiene
Externalize durable state — plans, decisions, research, progress — to files as you go; long
sessions degrade and compaction can silently drop in-context constraints. When a session should
end or the work should move to another harness/model, write a handoff instead of pushing on.
→ To hand off cleanly, load `agent-handover`.

## Delegating to subagents
Delegate work that's compressible (large search, small result — codebase/web research, a test-fix
loop) or that would pollute the main context. Keep work that leans on the orchestrator's
accumulated big-picture context in the orchestrator — don't make a subagent rebuild it.
Delegate for token efficiency, never for wall-clock speed: each dispatch rebuilds context from
cold, so prefer sequential execution and fewer delegations when parallelizing wouldn't save
tokens.

## Receiving code review
Evaluate feedback technically: restate it, verify against the actual code, implement what's right,
push back on what's wrong. No performative agreement. → For nuanced cases, load
`receiving-code-review`.

## Code quality
Write to the project's existing conventions. Favor strong, explicit types and clear module
boundaries; avoid hasty abstractions (extract on genuine, repeated need, not predicted reuse).
→ When writing or reviewing code, load `coding-standards`.

## Choosing model and effort
Match the model and reasoning effort to the task; prefer high effort over max — max measurably
overthinks. If the work clearly fits a different model or harness in the user's roster better,
say so before proceeding rather than grinding through. → Before assigning model or effort to any
work item — including a subagent dispatch — load `model-selection`.

<!-- DCP:END -->
