# Refresh model routing and current harness assumptions

Status: Approved. Owner approved the self-update corrections and directed the model routing
migration on 2026-10-01.

## Intent and scope

Use GPT-6.1 Sol medium for all GPT routing and Opus 5.5 medium for all Claude routing,
including prior economical, frontier, ordinary review, confirmation review and worker roles.
Keep work allocation, checkout ownership, permission boundaries and review requirements.

Update the model-selection skill, roster template, private active roster, and registry rows
A12/A13 together. Correct current Claude instruction discovery, qualify observed Grok
compatibility, and retain the existing installer targets. Reconcile the README's evidence
language with the registry's distinction between primary evidence and maintainer preferences.

Keep verification evidence and original unweakened checks. Run appropriate checks once and
repeat only for relevant changes, failures or unresolved risk; do not add automatic verifier
workers. Keep older research and specifications as historical evidence.

Local harness profiles identified in this work use the exact requested model and medium effort.
DCL reviewer configuration is a separate configuration change governed by task-tracking's
meta-worktree rule; its persona overrides must migrate together with its default reviewer.
No historical benchmark claim is re-attributed to a successor merely by renaming a model.
No fleet-wide rollout or model-comparison experiment is included.

## Acceptance

- Active DCP Claude/GPT routes all name the requested model and medium effort.
- Native Claude AGENTS.md support is described conditionally and compatibility imports remain.
- Verification requirements remain intact while duplicate-check scaffolding is bounded.
- Registry evidence dates distinguish source review from controlled model evaluation.
- Installer integration coverage passes and generated local instructions match canonical text.
- Configured independent review passes for the final DCP change.

## Implementation guidance

- TDD: prose and configuration only; no implementation code or new mirrored tests.
- Isolation: assigned current DCP checkout; no branch or worktree switch.
- Verify: git diff --check, shell syntax checks, existing installer integration suite,
  route/JSON assertions and generated managed-section checks. No TypeScript typecheck exists.
- Review: configured DCL implementation review after the final DCP commit; governance mode
  covers changed instruction paths. DCL configuration requires its own review in meta.
- Distribution: private roster remains gitignored; install.sh refreshes this machine's managed
  instructions, not fleet clones or external DCL configuration.

## Evidence

- https://code.claude.com/docs/en/memory#agentsmd
- https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5
- https://openai.com/index/introducing-gpt-6-1-sol/
- https://claude.com/product/design
