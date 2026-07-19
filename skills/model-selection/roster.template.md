# Roster — your harnesses, models, and standing assignments

<!-- install.sh copies this file to roster.local.md; edit THAT copy, not this template.
     roster.local.md is gitignored — it never reaches git, but `git clean -xdf` will delete
     it, so keep it quick to reconstruct. Date your entries so the self-update skill knows
     what to re-verify. This template must never contain real subscription data. -->

| Tool | Sweet spot | Watch out |
|------|-----------|-----------|

<!-- One row per harness/subscription you actually hold, e.g.:
     | Opus 4.8 (Claude Code), mid–high effort — the workhorse | Planning, multi-file refactors, debugging, orchestration, meta/design; the default seat for essentially everything | Never max effort; sycophancy under pressure |
     | Fable 5 (Claude Code) — the expensive exception | A genuinely higher tier than Opus 4.8 (Anthropic's most capable model), not just faster output. Reach for it ONLY when the task justifies ~2× cost: long-horizon autonomous runs (minutes-to-hours, no human correction), first-shot builds from a complete spec, orchestrating long-lived async sub-agents, hardest ambiguity/debugging. Default to Opus; upgrade only when you watch Opus run out of steam on a long autonomous item. | 2× Opus cost; minutes-long turns; safety classifiers refuse benign-adjacent security work; over-prescriptive prompts hurt quality; not for bounded interactive reasoning (design/review) |
     | Sonnet 5 (Claude Code) | Day-to-day implementation when Opus limits matter | Over-engineering |
     | Grok 4.5 (Grok Build) | Cheap agentic volume seat: near-frontier tool use, ~2× token-efficiency per task; high-volume, long-horizon tool-heavy loops on routine-to-moderate work | Not a frontier reasoner (trails Opus on the hardest SWE tiers); confident hallucination/arithmetic drift — verify its numbers and long-context facts |
     Columns: tool + harness + usable effort range; what to route to it; its failure modes.
     Opus/Fable/Sonnet/Grok tier characteristics above are generic model facts — keep them; only
     your subscription/pricing specifics (which plans you hold, spend caps) must stay out. -->

## Parked

<!-- Subscriptions you've let lapse — keep their rows here so renewing is a copy-paste. -->

## Standing assignments

<!-- Fixed role→model assignments, e.g. "cross-model review: <model B> reviews <model A>-written PRs". -->

## Overrides

<!-- Published defaults you flip, with why. Known knobs:
     - A16 sequential-by-default delegation — flip if you have flat-rate parallel capacity
     - A18 no cross-harness delegation — flip if metered API pricing makes per-leaf routing pay -->
