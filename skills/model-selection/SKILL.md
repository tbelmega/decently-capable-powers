---
name: model-selection
description: Use when choosing which harness, model, or reasoning effort to use for a piece of work, or when the current model is a poor fit for the task at hand
---

<!-- Evidence: ASSUMPTIONS.md A12-A18; revalidated by self-update. -->

# Model Selection

Match the tool to the task; usage budget is a first-class constraint.

## Roster

The user's roster (harnesses and subscriptions, per-model sweet spots and watch-outs, standing
assignments, default models and efforts, and overrides of this skill) lives in
`roster.local.md` next to this file. **Load it now**; it is the ground truth for every route
below. Use the model and effort it selects; don't carry effort settings between model versions,
and don't escalate a standing assignment without the owner's direction. Higher effort is not a
universal improvement.

If `roster.local.md` is missing or still the unedited template: use the current harness's native
models only, make no cross-harness recommendations, and tell the user once per session to edit
`skills/model-selection/roster.local.md` (install.sh seeds it from `roster.template.md`).

**No automated cross-harness delegation** by default (override in the roster if your cost
structure differs): shelling out one harness's CLI from another buys little over native
subagents and costs cold-start tokens plus unsupervised-child machinery. Cross a harness
boundary by agent-handover; cross-model review happens on the PR.

## Patterns

- **Plan and implement to fit:** use the roster's seat for planning and implementation. Report
  a capability limitation rather than silently selecting another model. A spec's implementation
  guidance records the exact route.
- **Cross-model review:** have the other model family review the work, per the roster's
  standing assignment and the configured review mechanism. It adds an independent perspective;
  it does not prove all systematic errors are caught.
- **Arbitrage limits:** when one subscription's limit nears, hand off with agent-handover.
  Preserve the owner's work allocation and report an unavailable required seat.
- **Escalate, don't grind:** repeated capability failures justify asking for a different route
  or stepping back to design, never silently changing the selected model.

## Subagents

- Pass an explicit model and effort from the roster where supported. Model inheritance and
  aliases vary by harness; verify the resolved version rather than assuming an alias pins it.
- The roster's watch-outs follow the model into each dispatch. Inspect the returned work and
  verify the evidence appropriate to the task.
- Fresh contexts and conversation forks have different overhead; weigh that when choosing how
  to delegate.
