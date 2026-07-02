---
name: self-update
description: Use quarterly, after major model or harness releases, or when this project's guidance feels stale — re-runs the capability and failure-mode research, revalidates ASSUMPTIONS.md, and modernizes the project
---

# Self-Update

This project's guidance rests on dated empirical claims, registered in `ASSUMPTIONS.md`. This
skill re-verifies them with fresh research and updates whatever no longer holds. Run it from a
checkout of this repo, on a branch.

## Procedure

1. **Read the current state.** `ASSUMPTIONS.md`, `AGENTS.md`, `README.md`, and the newest notes
   in `docs/research/`.
2. **Refresh the research prompts.** [research-prompts.md](research-prompts.md) holds the two
   templates (harness capabilities; model failure modes). Update their parameter blocks: today's
   date, the user's current harnesses, models, and subscriptions — ask if unclear.
3. **Run the research.** Dispatch each prompt to a subagent with live web access (or run
   inline). Prefer official docs over blog posts; date every claim; flag thin or anecdotal
   evidence as such. Write dated notes to `docs/research/`.
4. **Diff findings against ASSUMPTIONS.md.** For each row: **confirmed** → bump the verified
   date; **weakened/refuted** → list the guidance it justifies and propose the change; **new**
   finding (a fresh failure mode without guidance, or a native capability that makes existing
   guidance redundant) → propose an addition or removal.
5. **Propose, then apply.** Present the change list to the user — or record it in a decision
   log when running autonomously. Apply agreed changes across skills, AGENTS.md essences, the
   model-selection roster, and install.sh paths. Removed guidance is recorded with reasoning,
   never silently dropped.
6. **Close the loop.** Update ASSUMPTIONS.md dates and evidence links. Re-run `install.sh` so
   deployed copies pick up the changes. Commit in small green steps.

## Judgment Rules

- The bar for guidance staying is unchanged: it must change agent behavior at a decision point
  current models still get wrong on their own. "Models/harnesses now do this reliably" = drop.
- Prefer deleting to adding. Every addition must name the failure mode it corrects and cite
  evidence; every essence line in AGENTS.md is a permanent per-session token cost.
- If a harness absorbed a skill's job, drop the skill and keep at most an essence line.
- Distribution paths in install.sh must match the harness findings exactly — verify against the
  fresh research, don't assume last quarter's paths.
- Watch the trend, not just the snapshot: a flaw that weakened two reviews in a row is a
  candidate for slimming even before it's fully "fixed".
