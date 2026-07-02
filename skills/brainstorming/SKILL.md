---
name: brainstorming
description: Use before any creative work — new features, components, behavior changes — to turn an idea into an agreed design before implementation
---

# Brainstorming Ideas Into Designs

Turn ideas into agreed designs through collaborative dialogue before any implementation.

**Hard gate:** no implementation — no code, no scaffolding, no file changes — until a design has
been presented and the user has approved it. This applies regardless of perceived simplicity:
"simple" projects are where unexamined assumptions waste the most work. For truly small work the
design can be a few sentences, but it gets presented and approved.

**Project override:** if the project defines its own design/spec workflow (in AGENTS.md,
CLAUDE.md, or docs), defer to it entirely.

## The Process

1. **Understand the context.** Current project state: files, docs, recent commits. If the
   territory is unfamiliar, map it first (research skill).
2. **Check scope.** A request describing multiple independent subsystems needs decomposition
   before detail questions: identify the pieces, how they relate, what order to build them —
   then brainstorm the first piece. Each sub-project gets its own spec → implementation cycle.
3. **Ask questions one at a time.** Purpose, constraints, success criteria. Prefer multiple
   choice when possible. One question per message; a topic that needs more becomes several
   questions.
4. **Draft the spec early.** Create `docs/specs/YYYY-MM-DD-<topic>.md` with
   `Status: Draft — not for implementation` and keep it current as decisions land. Don't let
   draft wording quietly turn assumptions into requirements the user never agreed to.
5. **Propose 2–3 approaches** with trade-offs. Lead with your recommendation and why.
6. **Present the design in sections** scaled to their complexity; confirm each section before
   moving on. Cover architecture, components, data flow, error handling, testing. Apply YAGNI
   ruthlessly — strike features the goal doesn't need.
7. **Finalize the spec.** Drop the Draft status. Self-review for placeholders, contradictions,
   ambiguity, and scope — fix inline. Add a Mermaid diagram only where a picture genuinely
   clarifies (entity relationships, non-obvious sequences, lifecycles). Append the
   implementation-guidance tail (below). Commit the spec.
8. **User review gate.** Ask the user to review the spec file before proceeding; make requested
   changes and re-review. Only continue on approval.
9. **Transition to implementation.** For multi-task work, use the harness's native planning
   (plan mode / task list) with the spec as the source of truth. For small work, implement
   directly.

## Design Principles

- Break the system into units with one clear purpose each, communicating through well-defined
  interfaces, understandable without reading their internals. If internals can't change without
  breaking consumers, the boundaries need work.
- In existing codebases: explore the current structure first and follow its patterns. Include
  targeted improvements where existing problems affect this work; don't propose unrelated
  refactoring.

## Implementation Guidance (spec tail)

End every finalized spec with a short section recording the agreed working decisions, so any
implementing agent — after compaction, a handoff, or in a different harness — still carries
them:

```md
## Implementation guidance
- TDD: <on/off and scope, as agreed with the user>
- Isolation: <worktree / branch / current checkout, as agreed>
- Verify: run <project's typecheck+test commands> before claiming any task done
- Scope: build only what this spec specifies — propose extras, don't build them
```
