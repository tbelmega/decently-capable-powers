# Roster - your harnesses, models, and standing assignments

<!-- install.sh copies this file to roster.local.md; edit THAT copy, not this template.
     roster.local.md is gitignored - it never reaches git, but `git clean -xdf` will delete
     it, so keep it quick to reconstruct. Date your entries so the self-update skill knows
     what to re-verify. This template must never contain real subscription data. -->

| Tool | Sweet spot | Watch out |
|------|-----------|-----------|

<!-- One row per harness/subscription you actually hold, e.g.:
     | Opus 5 (Claude Code), medium-high effort - the workhorse | Planning, difficult implementation, multi-file refactors, debugging, review, orchestration, and meta/design; default for interactive and most unattended agent work | Longer output and more eager narration/delegation; inherited verification instructions can cause redundant work; thinking is on by default and billed as output |
     | Fable 5 (Claude Code) - the frontier exception | Only the hardest long-horizon autonomous work where Opus-level failure would be materially expensive; route by demonstrated capability need and failure cost, not duration alone | 2× Opus cost; slower; safety classifiers can reroute benign-adjacent security work; requires 30-day data retention |
     | Sonnet 5 (Claude Code) - the economical execution tier | Well-specified mechanical implementation, high-volume sweeps, exploration, and variants with cheap verification | Lower capability tail; retries erase savings; local over-engineering risk to verify |
     | Grok 4.5 (Grok Build) | Cheap agentic volume seat: near-frontier tool use, ~2× token-efficiency per task; high-volume, long-horizon tool-heavy loops on routine-to-moderate work | Not a frontier reasoner (trails Opus on the hardest SWE tiers); confident hallucination/arithmetic drift - verify its numbers and long-context facts |
     Columns: tool + harness + usable effort range; what to route to it; its failure modes.
     Opus/Fable/Sonnet/Grok tier characteristics above are generic model facts, so keep them; only
     your subscription/pricing specifics (which plans you hold, spend caps) must stay out. -->

## Parked

<!-- Subscriptions you've let lapse; keep their rows here so renewing is a copy-paste. -->

## Standing assignments

<!-- Fixed role→model assignments, e.g. "cross-model review: <model B> reviews <model A>-written PRs". -->

## Overrides

<!-- Published defaults you flip, with why. Known knobs:
     - A16 sequential-by-default delegation - flip if you have flat-rate parallel capacity
     - A18 no cross-harness delegation - flip if metered API pricing makes per-leaf routing pay -->
