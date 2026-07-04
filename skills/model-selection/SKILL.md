---
name: model-selection
description: Use when choosing which harness, model, or reasoning effort to use for a piece of work, or when the current model is a poor fit for the task at hand
---

<!-- Evidence: docs/research/2026-07-02-model-failure-modes.md §3; revalidated by self-update.
     The user's personal roster lives in roster.local.md (gitignored, seeded from
     roster.template.md by install.sh). -->

# Model Selection

Match the tool to the task — usage budget is a first-class constraint.

## Roster

The user's roster — available harnesses/subscriptions, per-model sweet spots and watch-outs,
standing assignments, and any overrides of this skill's defaults — lives in `roster.local.md`
next to this file. **Load it now**; it is the ground truth this skill's patterns route against.

If `roster.local.md` is missing or still the unedited template: work with the current harness's
native models only, make no cross-harness recommendations, and tell the user once per session to
edit `skills/model-selection/roster.local.md` (install.sh seeds it from `roster.template.md`).

**No automated cross-harness delegation** (default — ASSUMPTIONS.md A18; override in
`roster.local.md` if your cost structure differs): shelling out one harness's CLI from another
buys little over native cheap subagents and costs cold-start tokens on the other subscription
plus unsupervised-child machinery. Harness boundaries are human-mediated: hand off via
agent-handover; cross-model review happens on the PR, no bridge needed.

## Reasoning Effort

- Default medium/high. Raise only for genuinely hard reasoning: architecture, gnarly debugging,
  wide-blast-radius refactors.
- **Max backfires** — overthinking and context exhaustion; Opus 4.8 measurably does better at
  high than max. Reserve xhigh/max for the hardest asynchronous single-shot tasks, if at all.
- Don't pay high effort for mechanical work: renames, boilerplate, formatting, config.

## Patterns

- **Plan high, implement cheap:** plan/design with the strongest reasoner (Opus high), implement
  from the spec with the cheaper fit (Sonnet, or subagents per Subagent Routing below). Dominant
  practitioner pattern, and it matches the spec-carried-guidance workflow (brainstorming skill).
  The cheap leg applies to the delegated leaves — an implementation's orchestrator can't
  delegate up, so give it the cheapest tier that still covers the hardest item it keeps.
- **Cross-model review:** have a different model review than the one that wrote the code —
  models are blind to their own systematic errors. If the roster names a standing reviewer,
  use it. (Judgment call, not research-verified.)
- **Arbitrage limits:** when one subscription's limit nears, hand the work off
  (agent-handover skill) instead of stopping or degrading.
- **Escalate, don't grind:** a task repeatedly failing at the current tier means step up in
  model/effort — or step back to design. Repetition without change burns budget for nothing.

## Subagent Routing (within a harness)

The roster routes across harnesses; a subagent dispatch routes *within* one — same economics,
one trap:

- **Built-in agents inherit the session's model** (Claude Code ≥ 2.1.198; Explore is capped at
  Opus on the Claude API, Plan and general-purpose inherit uncapped — ASSUMPTIONS.md A15). From
  an Opus session, an un-overridden Explore sweep runs on Opus.
- **Override per dispatch:** pass an explicit `model` (and effort where supported) matched to
  the work — haiku for reference sweeps and throwaway edits, sonnet for well-specified
  mechanical implementation. Inherit only when the subagent genuinely needs the session's tier.
- **The watch-out column follows the model into the dispatch:** review a Sonnet subagent's diff
  for over-engineering exactly as you would a Sonnet session's.
- **Delegate for token efficiency, never wall-clock speed** (default — A16; override in
  `roster.local.md` if you have flat-rate parallel capacity): each dispatch rebuilds context
  from cold. Default to sequential and fewer, bigger delegations; a piece earns a dispatch on
  its own merits (compressible, or context-polluting) — never to run alongside another.

## For Agents

If the current work clearly fits a different roster entry better (wrong strength, wrong cost,
wrong harness), say so before proceeding rather than grinding through.
