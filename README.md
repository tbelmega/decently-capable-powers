# decently-capable-powers

A minimalist fork of [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent —
rebuilt in July 2026 against verified, current harness and model behavior.

The original Superpowers is a complete software-development methodology for coding agents. This
fork strips it to the behavioral discipline that still changes what an agent does, verifies every
load-bearing assumption with dated research, and installs as user-level config for Claude Code,
OpenAI Codex, and Cursor.

## North star

- **Leverage the harness and the model.** 2026 harnesses do planning, task tracking, subagent
  dispatch, worktrees, code review, hooks, and persistent memory natively; 2026 models plan and
  code well. Don't re-implement any of that. Keep only what changes agent behavior at decision
  points models still get wrong on their own.
- **Aim for token efficiency.** Usage cost is a first-class constraint. Prefer cheap, always-on
  guidance over machinery that spends tokens per step. Length is a cost.
- **Work with the model's grain.** Guidance that contradicts how a model was trained tends to
  degrade it. Add discipline that fills a real gap, not friction that fights the model.
- **Evidence over vibes.** Every piece of guidance traces to a dated, sourced claim in
  [`ASSUMPTIONS.md`](ASSUMPTIONS.md). When a claim falls, the guidance it justifies changes —
  the `self-update` skill re-verifies the registry as models and harnesses move.

## What's here

**[`AGENTS.md`](AGENTS.md) — the always-on operating guide.** One essence per discipline, plus a
"→ load skill X" pointer to the fuller procedure. Read natively by Codex and Cursor; reaches
Claude Code via `CLAUDE.md`. This is the reliable layer — skills auto-trigger probabilistically,
essences are always in context. Final handoffs of distinct bodies of work end with a fixed
receipt — implementation, verification, independent review, and next step/options — so
completion state and the available exits are visible across harnesses without scrolling.

**`skills/` — ten, loaded on demand.** Each exists to counter a failure mode current models
measurably still have:

| Skill | Counters |
|-------|----------|
| brainstorming | building before the problem is understood and the design agreed |
| research | planning against code the agent only knows by name |
| test-driven-development | implementation-first work, mock-heavy tests |
| systematic-debugging | patching symptoms; not stepping back after repeated failures |
| verification-before-completion | unverified — or gamed — success claims |
| receiving-code-review | sycophantic caving to feedback |
| coding-standards | type/naming/abstraction drift |
| model-selection | wrong model or reasoning effort for the task |
| agent-handover | context rot; dead ends at usage limits |
| self-update | this project itself going stale |

Personal setup never lives in published skill text: your model roster and your stack's coding
rules go in gitignored `*.local.md` files seeded from checked-in templates at install (see
below).

**[`ASSUMPTIONS.md`](ASSUMPTIONS.md)** — the registry of empirical claims behind all of the
above, each with what it justifies, a last-verified date, and evidence in `docs/research/`.

## Install / update

```sh
git clone <this repo> && cd <repo> && ./install.sh
```

| Surface | Claude Code | Codex CLI | Cursor |
|---------|-------------|-----------|--------|
| Always-on guide | `~/.claude/CLAUDE.md` (managed block) | `~/.codex/AGENTS.md` (managed block) | Settings → Rules → User Rules (manual paste, prompted by the script) |
| Skills | `~/.claude/skills/` (symlinks) | `~/.agents/skills/` (symlinks) | reads both trees automatically |

Skills are symlinked, so repo edits are live immediately; the instruction blocks are marker-managed,
so **update = `git pull && ./install.sh`**. For a repo that wants checked-in, team-visible
guidance instead: `./install.sh --project <dir>`.

Running several Claude Code profiles (`CLAUDE_CONFIG_DIR=~/.claude-<name>`)? The managed guide
block reaches every profile whose `CLAUDE.md` already carries the marker, but skills need the
profile named: `./install.sh --config-dir ~/.claude-work --config-dir ~/.claude-personal`
links them there too, on top of the default targets. Without it, those profiles' skill links
are hand-made and no update ever refreshes them.

**One post-install step:** install.sh seeds `skills/model-selection/roster.local.md` from its
template — edit it with your harnesses/subscriptions, model sweet spots, and standing
assignments. It is gitignored (personal, never published) and reaches every harness through
the skill symlinks.

Coding standards are per-stack: published bases in `skills/coding-standards/stacks/`
(typescript.md, kotlin.md, …) load automatically for matching projects and update with
`git pull`. For personal additions or overrides, create a gitignored
`stacks/<stack>.local.md` next to the base — it wins on conflict and survives pulls.

## Keeping it current

Run the `self-update` skill quarterly or after major model/harness releases. It re-runs the
research that produced `docs/research/` (prompt templates ship inside the skill), diffs the
findings against `ASSUMPTIONS.md`, and proposes the guidance changes that follow — with the same
keep/drop bar the fork was built on.

## Status

Rebuilt 2026-07-02 (the `fable-powers` rebuild): decision log in
[`docs/mission-log.md`](docs/mission-log.md), original feature-by-feature keep/drop reasoning in
[`MINIMIZATION.md`](MINIMIZATION.md).

## Attribution & license

Superpowers was originally built by [Jesse Vincent](https://blog.fsck.com) and the folks at
[Prime Radiant](https://primeradiant.com). Read
[the original release announcement](https://blog.fsck.com/2025/10/09/superpowers/). If Superpowers
has helped you do things that make money, consider
[sponsoring the original author's open-source work](https://github.com/sponsors/obra).

MIT License — see [LICENSE](LICENSE). Copyright © 2025 Jesse Vincent; portions © 2025–2026
Thiemo Belmega.
