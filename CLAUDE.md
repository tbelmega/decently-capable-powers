# Contributor guidelines

Operating guidance (the always-on working defaults) is the source of truth in @AGENTS.md — it
applies when working in this repo too. This file adds only the fork's design principles and
repo-specific notes.

This is a minimalist fork of [obra/superpowers](https://github.com/obra/superpowers) by
Jesse Vincent. The thesis: 2026 models and harnesses have absorbed most of what the original
plugin added, so this fork keeps only the skills that still shape agent behavior in ways the
model won't do on its own, and leans on native harness capabilities for everything else. See
`MINIMIZATION.md` for the reasoning behind what was kept and dropped.

## Design principles

- **Native-first.** Before adding a skill or hook, ask whether the harness already does this
  (plan mode, todos, subagent dispatch, worktrees, code-review). If so, don't re-implement it.
- **Work with the model's grain.** Where guidance contradicts the behavior the model's lab
  trained into it, it tends to *degrade* performance, not improve it. Add discipline that fills
  a genuine gap, not friction that fights the model.
- **Token-efficient.** Usage cost is a first-class constraint. Prefer guidance that costs
  nothing at runtime (short always-on instructions) over machinery that spends tokens per step
  (extra tool calls, checkbox bookkeeping, subagent context rebuilds). Length is a cost.
- **Skills are behavioral discipline, not tutorials.** A skill earns its place only if it
  changes what the agent does at a decision point the model tends to get wrong (coding before
  understanding, skipping the failing test, patching symptoms, claiming unverified success,
  caving to review feedback). If it just explains a concept the model already knows, cut it.
- **Zero heavy machinery.** No servers, no multi-harness sync scripts, no eval harness. Keep
  the surface small enough to read and edit by hand.
- **Multi-harness by convention, not packaging.** Primary target is Claude Code. Kept
  compatible with Codex and Cursor by keeping operating guidance in `AGENTS.md` (which both
  read) and skills as plain `SKILL.md` files that can be symlinked in — no per-harness plugin
  manifests or marketplaces to maintain.

## Working in this repo

- Skills live in `skills/<name>/SKILL.md` with `name` + `description` frontmatter.
- `AGENTS.md` is the always-on operating guide: an essence per discipline plus "→ load skill X"
  pointers. It carries the routing/enforcement that a SessionStart hook + bootstrap used to do,
  but as cross-harness text. Edit its managed block (between the `DCP:` markers) here.
- Keep skill content tight — length is a cost. Prefer one sharp rule over three examples.
- Research notes go in `docs/research/`; brainstorming specs in `docs/specs/`.
