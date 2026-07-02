# Operating guide
<!-- DCP:START — managed block; edit in the decently-capable-powers repo, then re-run install.sh -->

Always-on working defaults. Each is the essence (the fallback); where a fuller procedure exists,
a → line says which skill to load for depth. Loading is the model's judgment, not enforced.

## Before building
For non-trivial work the user hasn't already fully specified, turn the idea into an agreed design
before implementing. → When starting feature/creative work, load `brainstorming`.

## Scope
Build what was asked — the smallest change that fulfills the request. No unrequested features,
refactors, files, or "while I'm here" improvements; propose extras, don't build them.

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

## Isolation — ask the user, once per work-stream
Same rule as testing: ask the user once whether to work in an isolated branch/worktree or the
current checkout; don't re-ask per task.

## Context hygiene
Externalize durable state — plans, decisions, research, progress — to files as you go; long
sessions degrade and compaction can silently drop in-context constraints. When a session should
end or the work should move to another harness/model, write a handoff instead of pushing on.
→ To hand off cleanly, load `agent-handover`.

## Delegating to subagents
Delegate work that's compressible (large search, small result — codebase/web research, a test-fix
loop) or that would pollute the main context. Keep work that leans on the orchestrator's
accumulated big-picture context in the orchestrator — don't make a subagent rebuild it.

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
say so before proceeding rather than grinding through. → To pick harness/model/effort for a work
item, load `model-selection`.

<!-- DCP:END -->
