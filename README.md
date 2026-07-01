# Superpowers (minimalist fork)

A minimalist fork of [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent.

The original Superpowers is a complete software-development methodology for coding agents, built
from a large set of composable skills. This fork bets that **2026 models and harnesses have
absorbed most of that machinery** — native plan mode, task tracking, subagent dispatch,
worktrees, and code-review are all built in now. So it throws out everything that merely
re-implements a native capability and keeps only the skills that still change agent behavior at
the decision points models get wrong on their own.

See [`MINIMIZATION.md`](MINIMIZATION.md) for the full keep/drop reasoning, feature by feature.

## What's kept

Six skills, one SessionStart hook, Claude Code only:

- **brainstorming** — before any build work, turn the idea into an approved spec instead of
  jumping into code. The single highest-value habit, and the one native discovery won't enforce.
- **test-driven-development** — failing test first; if you wrote code first, delete it.
- **systematic-debugging** — find the root cause before proposing a fix; if 3+ fixes fail, the
  architecture is wrong — step back.
- **verification-before-completion** — no "done"/"fixed"/"passing" claim without running it and
  showing the evidence.
- **receiving-code-review** — evaluate feedback technically; verify it, push back when it's
  wrong, no performative agreement.
- **using-superpowers** — the bootstrap that makes the above auto-trigger.

Everything else (writing-plans, executing-plans, subagent-driven-development,
dispatching-parallel-agents, requesting-code-review, using-git-worktrees,
finishing-a-development-branch, writing-skills, the eval harness, the visual-companion server,
and support for six non-Claude harnesses) has been removed in favor of native harness features.

## How it works

The SessionStart hook injects the `using-superpowers` bootstrap so the skills trigger at the
right moments. When you start building something, `brainstorming` steps in first and refines the
idea into a spec through one-question-at-a-time dialogue; once you approve it, the spec is handed
to the harness's native plan mode. During implementation, the TDD, debugging, verification, and
code-review skills apply as their moments arrive.

## Installation

This is an experimental, Claude-Code-only fork. Install it as a local plugin marketplace:

```bash
/plugin marketplace add /path/to/this/checkout
/plugin install superpowers@superpowers-dev
```

## Sponsorship

If Superpowers has helped you do things that make money, consider
[sponsoring the original author's open-source work](https://github.com/sponsors/obra).

## Attribution & license

Superpowers was originally built by [Jesse Vincent](https://blog.fsck.com) and the folks at
[Prime Radiant](https://primeradiant.com). This minimalist fork is maintained by Thiemo Belmega.
Read [the original release announcement](https://blog.fsck.com/2025/10/09/superpowers/) and join
the [original project's community](https://discord.gg/35wsABTejz).

MIT License — see [LICENSE](LICENSE). Copyright © 2025 Jesse Vincent; portions © 2025 Thiemo Belmega.
