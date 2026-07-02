# Working memory — handoff for the next session

Scratch/handoff notes for the `decently-capable-powers` project. Not user-facing docs; delete or
fold into README/CLAUDE once stable.

## Where things are
- **Project name:** `decently-capable-powers` (settled). This is the **git branch** name.
- **Worktree directory:** still `/home/thiemo/workspace/distinctly-adequate-powers` (kept for now).
- **Base:** obra `superpowers` v6.1.0 (`f268f7c`) + one attribution commit, then all the
  minimization work on top.
- **Remotes:** `origin` = `tbelmega/superpowers` (the fork), `upstream` = `obra/superpowers`.
- **Fork's `main`:** obra@`7e51643` + ~35 of Thiemo's commits. `git diff 7e51643..main -- <path>`
  isolates Thiemo's changes cleanly. The main worktree is the sibling `superpowers/` checkout.

## North star (the fork's thesis)
1. Leverage harness + model native capabilities (plan mode, todos, subagents, worktrees,
   code-review, planning, coding) — don't re-implement them.
2. Token efficiency is a first-class constraint. Cheap always-on guidance > per-step machinery.
3. Work with the model's grain — don't add friction that fights lab-trained behavior.
4. Right agent for the right job (see below)
 

## Model selection
The user has Claude, Codex and Cursor subscriptions at their disposal and wants to use the different usage limits efficiently. 
How can this project
(a) help the user develop their understanding which harness/model/reasoning efforts to use for different types of tasks (probably decision matric across dimensions)
(b) auto-update when new models drop
(c) build model-preselection into the brainstorming/spec, and/or AGENTS.md to escalate to the user when different model is advisable

## Architecture (decided)
- **Two layers.** `AGENTS.md` = always-on, cross-harness operating guide (source of truth;
  `CLAUDE.md` imports it via `@AGENTS.md`). It holds an *essence* per discipline + "→ load skill X"
  routing pointers. Skills = on-demand depth, invoked by judgment.
- **Hook + `using-superpowers` bootstrap: dropped.** Their routing/enforcement job moved into
  `AGENTS.md` (works in Claude Code, Codex, Cursor — not just Claude). This also fixes the
  over-triggering the hook caused on simple tasks.
- **Harness support:** Claude Code primary; Codex + Cursor by convention (they read `AGENTS.md`;
  skills are plain `SKILL.md` to symlink in). No per-harness packaging.

## Retained skills (7)
brainstorming, coding-standards, receiving-code-review, research, systematic-debugging,
test-driven-development, verification-before-completion. (All kept in current content form —
optimization is the next task.)

## Key findings from the main-vs-branch comparison (see docs/research/2026-07-02-…md)
- **`receiving-code-review` and `systematic-debugging`: unchanged on main** — branch versions are
  fine, nothing to port.
- **TDD on main has the crown-jewel additions** (NOT yet on this branch): mock-only-at-boundaries
  / never-mock-own-code, DRY→AHA + Rule of Three, refactoring-excluded-from-test-first,
  integration-first, run-current-test-file, trivial-test-first, non-deterministic→injectable,
  frontend testing section, hardcode-expected-results.
- **brainstorming on main grew into a design pipeline**: Claude Design handoff + `ux-brief.md`,
  planning-transition gate (one plan vs staged), spec Mermaid diagrams, project design-workflow
  override, incremental-draft spec (`Status: Draft`), `docs/superpowers/specs/`→`docs/specs/`.
- `coding-standards` + `research` are wholly Thiemo's; pulled to latest-main content.

## Open decisions / next-session TODO
1. **Skill content optimization (the main task).**
   - Port the TDD additions into this branch's TDD skill; decide TDD default behavior (we agreed:
     *opt-in per work-stream* — wording already drafted in `AGENTS.md`).
   - Review brainstorming: it's kept in original form. Decide which of main's pipeline pieces
     (Claude Design/UX brief, planning-transition gate, spec diagrams, project-workflow override)
     fit the minimalist thesis vs. are machinery to cut.
   - Review `coding-standards` and `research` content.
   - Decide whether to pull in `fresh-agent-handover` (wholly Thiemo's, on main, not yet pulled).
2. **Finalize the `AGENTS.md` code-quality essence** (currently provisional; TODO marker in file).
   Decide what lives in AGENTS.md vs. the `coding-standards` skill.
3. **Build the distribution/update mechanism** (`UPDATE.md`): one update-agent that refreshes the
   `AGENTS.md` managed block (between `DCP:START`/`DCP:END` markers) in a target project + delivers
   skills (symlink by default, copy fallback). Chosen approach; not built yet.
4. **Spec-carried guidance idea:** have brainstorming append an "Implementation guidance" section
   to each finalized spec (echoing AGENTS.md rules) so self-planned work carries the discipline.
5. **Branding/rename cleanup (pending):** plugin id is still `superpowers` in
   `.claude-plugin/plugin.json`; marketplace name is `superpowers-dev`; `.claude-plugin/*.json`
   still have `tbelmega/superpowers` URLs + personal gmail; `assets/` is still upstream branding.
   Now that the name is settled (`decently-capable-powers`), decide whether to rename the plugin id
   (affects the `superpowers:` skill namespace + install) and do one find-replace pass.

## Style note
The user liked the analysis-note writing style used in this session (crisp, verdict-first, bolded
labels, concrete). Reuse it for research notes and summaries.
