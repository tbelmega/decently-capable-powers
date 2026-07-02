# decently-capable-powers

A minimalist fork of [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent.

The original Superpowers is a complete software-development methodology for coding agents, built
from a large set of composable skills, hooks, and multi-harness packaging. This fork strips most
of that away.

## North star

- **Leverage the harness and the model.** 2026 harnesses already do planning (plan mode), task
  tracking (todos), subagent dispatch, worktrees, and code review natively; 2026 models already
  plan and code well. Don't re-implement any of that. Keep only what changes agent behavior at the
  decision points models still get wrong on their own.
- **Aim for token efficiency.** Usage cost is a first-class constraint. Prefer cheap, always-on
  guidance over machinery that spends tokens per step. Length is a cost.
- **Work with the model's grain.** Guidance that contradicts how a model was trained tends to
  degrade it. Add discipline that fills a real gap, not friction that fights the model.

See [`MINIMIZATION.md`](MINIMIZATION.md) for the feature-by-feature keep/drop reasoning.

## What's here

Two layers:

**`AGENTS.md` — the always-on operating guide.** A short, cross-harness set of working defaults
(read by Claude Code, Codex, and Cursor): brainstorm before building, testing approach, green
commits, root-cause debugging, verify-before-done, subagent-delegation heuristic, receiving
review, code quality. Each is a one-line essence plus a "→ load skill X" pointer to the fuller
procedure. This is the reliable layer.

**Skills — invoked on demand for depth.** Seven, in `skills/`:

- **brainstorming** — turn an idea into an agreed, written spec before implementing.
- **test-driven-development** — failing test first; integration-style over mock-heavy.
- **systematic-debugging** — root cause before fixes; step back after repeated failures.
- **verification-before-completion** — evidence before any "done/fixed/passing" claim.
- **receiving-code-review** — evaluate feedback technically; push back when it's wrong.
- **coding-standards** — typing, boundaries, and code-quality conventions.
- **research** — map how a codebase/system works before planning.

No SessionStart hook, no `using-superpowers` bootstrap (their routing job moved into `AGENTS.md`),
and no per-harness plugin packaging.

## Harness support

Primary target is **Claude Code**. Kept compatible with **Codex** and **Cursor** by convention,
not packaging: they read `AGENTS.md`, and skills are plain `SKILL.md` files that can be symlinked
into a project or harness config. (A distribution/update mechanism for pulling these into working
projects is planned but not yet built.)

## Status

Experimental and in active reshaping. Skill *content* is still being reviewed and optimized; the
current focus is the shape (what exists and how it's delivered), not final wording.

## Attribution & license

Superpowers was originally built by [Jesse Vincent](https://blog.fsck.com) and the folks at
[Prime Radiant](https://primeradiant.com). Read
[the original release announcement](https://blog.fsck.com/2025/10/09/superpowers/). If Superpowers
has helped you do things that make money, consider
[sponsoring the original author's open-source work](https://github.com/sponsors/obra).

MIT License — see [LICENSE](LICENSE). Copyright © 2025 Jesse Vincent; portions © 2025 Thiemo Belmega.
