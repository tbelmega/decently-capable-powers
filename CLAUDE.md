# Contributor guidelines

This is a minimalist fork of [obra/superpowers](https://github.com/obra/superpowers) by
Jesse Vincent. The thesis: 2026 models and harnesses have absorbed most of what the original
plugin added, so this fork keeps only the skills that still shape agent behavior in ways the
model won't do on its own, and leans on native harness capabilities for everything else. See
`MINIMIZATION.md` for the reasoning behind what was kept and dropped.

## Design principles

- **Native-first.** Before adding a skill or hook, ask whether the harness already does this
  (plan mode, todos, subagent dispatch, worktrees, code-review). If so, don't re-implement it.
- **Skills are behavioral discipline, not tutorials.** A skill earns its place only if it
  changes what the agent does at a decision point the model tends to get wrong (coding before
  understanding, skipping the failing test, patching symptoms, claiming unverified success,
  caving to review feedback). If it just explains a concept the model already knows, cut it.
- **Zero heavy machinery.** No servers, no multi-harness sync scripts, no eval harness. Keep
  the surface small enough to read and edit by hand.
- **Single target.** This fork supports Claude Code only.

## Working in this repo

- Skills live in `skills/<name>/SKILL.md` with `name` + `description` frontmatter.
- The `SessionStart` hook (`hooks/`) injects the `using-superpowers` bootstrap so skills
  auto-trigger.
- Keep skill content tight — length is a cost. Prefer one sharp rule over three examples.
