---
name: model-selection
description: Use when choosing which harness, model, or reasoning effort to use for a piece of work, or when the current model is a poor fit for the task at hand
---

<!-- Evidence: docs/research/2026-07-02-model-failure-modes.md §3; revalidated by self-update.
     The user's personal roster lives in roster.local.md (gitignored, seeded from
     roster.template.md by install.sh). -->

# Model Selection

Match the tool to the task; usage budget is a first-class constraint.

## Roster

The user's roster (available harnesses/subscriptions, per-model sweet spots and watch-outs,
standing assignments, and any overrides of this skill's defaults) lives in `roster.local.md`
next to this file. **Load it now**; it is the ground truth this skill's patterns route against.

If `roster.local.md` is missing or still the unedited template: work with the current harness's
native models only, make no cross-harness recommendations, and tell the user once per session to
edit `skills/model-selection/roster.local.md` (install.sh seeds it from `roster.template.md`).

**No automated cross-harness delegation** (default, per ASSUMPTIONS.md A18; override in
`roster.local.md` if your cost structure differs): shelling out one harness's CLI from another
buys little over native cheap subagents and costs cold-start tokens on the other subscription
plus unsupervised-child machinery. Harness boundaries are human-mediated: hand off via
agent-handover; cross-model review happens on the PR, no bridge needed.

## Reasoning Effort

- Use the model and effort selected in the current roster. Do not carry effort settings
  between model versions or escalate a standing assignment without owner direction.
- The current Claude default is Opus 5.5 medium; the current GPT default is GPT-6.1 Sol
  medium. Higher effort is not a universal improvement. Evaluate quality and cost before
  proposing a different setting.

## Patterns

- **Plan and implement to fit:** use the roster's selected seat for planning and implementation.
  Match task scope to the available capability; report a capability limitation rather than
  silently selecting another model. A spec's implementation guidance records the exact route.
- **Cross-model review:** use the other model family to review the work. Follow the roster's
  standing assignment and the configured review mechanism. This is a judgment about a useful
  independent perspective, not proof that all systematic errors will be caught.
- **Arbitrage limits:** when one subscription's limit nears, hand the work off using
  agent-handover. Preserve the owner's work allocation and report an unavailable required seat.
- **Escalate, don't grind:** repeated capability failures justify asking for a different route
  or stepping back to design; they do not authorize silently changing the selected model.

## Subagent Routing (within a harness)

- Claude workers use Opus 5.5 medium; GPT workers use GPT-6.1 Sol medium, unless the current
  personal roster explicitly overrides those defaults.
- Pass an explicit model and effort where supported. Built-in model inheritance and aliases
  vary by harness; verify the resolved version rather than assuming an alias pins it.
- The roster's watch-outs follow the model into each dispatch. Inspect the returned work and
  verify the evidence appropriate to the task.
- Delegate for token efficiency, not wall-clock speed. Fresh contexts and conversation forks
  have different overhead. Default to fewer, larger dispatches; delegate compressible or
  context-polluting work only when the expected context benefit justifies its cost.

## For Agents

If the current work clearly fits a different roster entry better (wrong strength, wrong cost,
wrong harness), say so before proceeding rather than grinding through.
