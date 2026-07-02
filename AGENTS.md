# Operating guide
<!-- DAP:START — managed block; edit in the distinctly-adequate-powers repo, then run its UPDATE.md -->

Always-on working defaults. Each is the essence (the fallback); where a fuller procedure exists,
a → line says which skill to load for depth. Loading is the model's judgment, not enforced.

## Before building
For non-trivial work the user hasn't already fully specified, turn the idea into an agreed design
before implementing. → When starting feature/creative work, load `brainstorming`.

## Testing — decide once per work-stream, not per task
When you start a distinct body of work (a new plan/epic, or the first code-changing turn), ask
the user once whether to follow TDD, and let them scope it ("yes for domain logic, no for infra").
Don't re-ask per task; re-ask only when the work clearly shifts to a different area. When TDD is
on: prefer integration-style tests over mock-heavy unit tests, shape structure before
implementing, and skip infra/config/throwaway unless asked. → When TDD is on, load
`test-driven-development`.

## Debugging
Find the root cause before proposing a fix; don't patch symptoms. If 3+ fixes fail, suspect the
architecture and step back. → On any bug/test failure/unexpected behavior, load
`systematic-debugging`.

## Verify before completion
Never claim done/fixed/passing without running the check and showing the evidence. Ban "should",
"seems", "probably". → For the full checklist, load `verification-before-completion`.

## Commits
End each task by running typecheck + tests; commit when green with a clear message. Aim for small,
self-contained, green commits.

## Isolation — ask the user, once per work-stream
Same rule as testing: ask the user once whether to work in an isolated branch/worktree or the
current checkout; don't re-ask per task.

## Delegating to subagents
Delegate work that's compressible (large search, small result — codebase/web research, a test-fix
loop) or that would pollute the main context. Keep work that leans on the orchestrator's
accumulated big-picture context in the orchestrator — don't make a subagent rebuild it.

## Receiving code review
Evaluate feedback technically: restate it, verify against the actual code, implement what's right,
push back on what's wrong. No performative agreement. → For nuanced cases, load
`receiving-code-review`.

## Code quality
<!-- TODO(code-quality): fill from repo discussion — architecture boundaries (3-tier?), preferred
patterns / anti-patterns, file-size & module-boundary rules. Left blank until defined rather than
guessed. -->

<!-- DAP:END -->
