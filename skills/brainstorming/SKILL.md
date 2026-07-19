---
name: brainstorming
description: Use when the user asks to brainstorm, or before feature-level work — new features, components, behavior changes — the user hasn't already fully specified; turns an idea into an agreed design before implementation
---

# Brainstorming Ideas Into Designs

Turn ideas into agreed designs through collaborative dialogue. Disambiguate purpose, scope, architecture, details.
And volunteer the design thinking the user didn't ask for. The role is active design partner, not requirements secretary.

**Gate:** once brainstorming has started for a piece of work, no implementation — no code, no
scaffolding, no file changes beyond the spec itself — until the design has been presented and the
user has approved it. Work the user requests outside a brainstorming session is governed by the
operating guide, not this gate.

**Project override:** if the project defines its own design/spec workflow (AGENTS.md, CLAUDE.md,
docs), defer to it entirely.

**Everything scales with the work** — number of questions, spec length, number of approaches,
presentation granularity. A small feature is a handful of questions and a one-screen spec,
reviewed in a single pass. The spec file itself is never skipped.

## The Process

1. **Understand the context.** Current project state: files, docs, recent commits. Unfamiliar
   territory: dispatch a subagent with the research skill; link its research note from the spec
   so discovered constraints and conventions survive handoff and compaction.
2. **Check scope.** A request describing multiple independent subsystems needs decomposition
   before detail questions: identify the pieces, how they relate, what order to build them —
   then brainstorm the first piece. Each sub-project gets its own spec → implementation cycle.
   **Choose the scope posture before detailed design:** classify the work as a new capability or
   an iteration of an existing feature or approved plan. For a new capability, recommend the
   smallest end-to-end first slice; polish, optional workflows, broad option sets, and
   speculative edge cases are later by default. For an iteration, preserve the established
   scope and prior commitments; do not use MVP reasoning to remove expected parts. If context
   does not make the classification clear, ask the user before narrowing scope.
3. **Clarify the goal.** While purpose and scope are still vague, questions beat proposals.
   Question discipline:
   - Ask only questions whose answers change the design. When the remaining ones wouldn't,
     stop interviewing.
   - Decide by default: if the answer is inferable from code, docs, or the user's demonstrated
     preferences — or the decision is a two-way door (cheap to reverse) — decide it, record it
     in the spec as an assumption, and move on. Ask only where being wrong is expensive.
   - State your recommended answer with every question, not only when proposing approaches.
   - Batch up to 4 questions per message (native multi-question prompts) only when they are
     mutually independent — no question's relevance or framing depends on another's answer —
     and close enough in topic that the user isn't context-switching. A dependent chain stays
     one question at a time.
4. **Draft the spec early.** Create `docs/specs/YYYY-MM-DD-<topic>.md` with
   `Status: Draft — not for implementation`. The file exists from the first settled decision
   onward, and decisions land in it in the same turn they're made — a decision that lives only
   in conversation context is one compaction or crash away from lost. Don't let draft wording
   quietly turn assumptions into requirements the user never agreed to. A draft may record
   questions that still need an answer, but is not approval-ready while any of them would
   materially change scope, behavior, ownership, acceptance criteria, or implementation cost.
   Do not use [review-layout.md](review-layout.md) to structure the interview or initial draft:
   it is a finalization-only tool, not a discovery template.
5. **Pivot to proposing.** Once purpose and rough scope are settled, stop interviewing and
   propose — a concrete draft surfaces the remaining requirements faster than abstract questions
   once there is a shape to react to. Offer 2–3 approaches where genuinely distinct trade-offs
   exist; lead with your recommendation and why.
6. **Volunteer what wasn't asked.** This is where the agent earns its keep:
   - *Premise:* is this feature the right solution to the underlying problem? Say so early if not.
   - *Pre-mortem:* how does this break — migrations, concurrency, data loss, security, backward
     compatibility, operational cost. Raise the failure modes the user didn't know to ask about.
   - *Opportunities:* existing code that already half-solves it; platform or harness capabilities
     that make a planned component unnecessary.
   - Before finalizing: name the ~3 most impactful things the spec is still not considering, and
     triage them with the user.
   - Before presenting: enumerate every design element not strictly entailed by the user's
     request and confirm each as build / defer / cut — additions live in the spec as labeled
     decisions, not prose the user is assumed to have absorbed.
7. **Present the design** in one pass. Walk through it section-by-section, confirming as you
   go, only when it is too large to review in one sitting.
8. **Finalize and gate.** Before asking for approval, ask every remaining material question
   directly, with a recommendation, and update the draft from the user's answer. Make
   low-impact, reversible decisions yourself when appropriate; label them as agent decisions
   in the spec so the user can object during review. Self-review for placeholders,
   contradictions, ambiguity, and scope —
   and check the design against the project's own design principles and conventions (from its
   docs and code patterns). If the spec has grown past one implementation cycle, propose
   splitting it: for a new capability, an MVP spec for immediate implementation plus follow-up
   specs for the rest; for an iteration, defer only separable work or work whose cost or risk
   warrants a new approval. Follow-ups become named extensions the MVP structure must
   accommodate. Add a Mermaid diagram only where a picture genuinely clarifies. Reconcile the
   `Deferred aspects` ledger: every deferred capability, question, polish item, or follow-up
   must be recorded there with its reason, return condition, and intended fit. Write the Review
   summary (below) from the finished body. Then, and only at this finalization
   stage, use [review-layout.md](review-layout.md) to reorder the whole spec for review. It is
   a checklist, not a form: retain only relevant sections and never invent content to fill a
   heading. Append the implementation-guidance tail (below). Ask the user to review; iterate. On approval
   — and only then — drop the Draft status and commit the spec.
9. **Transition to implementation.** For multi-task work, use the harness's native planning
   (plan mode / task list) with the spec as the source of truth, and turn the tail's Routing
   line into a concrete dispatch plan — what the orchestrator executes, what gets delegated at
   which model/effort, in what order — before writing code. Before implementation, call out the
   `Deferred aspects` ledger again in the implementation guidance and follow any project-defined
   tracking instructions for its entries. For small work, implement directly.

**Revising an approved spec** is a new approval, not an edit: present the delta — what changed,
and above all what new scope or cost it introduces — and get explicit sign-off on each addition
before marking the revision approved. Regenerate the Review summary; new [added] items are
called out as new.

## Review-facing front section

Every finalized spec opens with a **Review summary** written for a tired reviewer — plain words,
no architecture vocabulary. Write it last from the finished body, then put it first. Follow it
with the other reviewer-facing sections from [review-layout.md](review-layout.md). Order this
front section by what the user most needs to notice and judge, not by conversation chronology or
implementation sequence. A reviewer who reads only the first quarter must encounter every
decision, assumption, scope boundary, deferral, exclusion, and risk on which they could
reasonably object or redirect the work.

- What this builds, in ≤3 sentences.
- Every element that goes beyond what the user literally asked for, each tagged **[added]**
  with one line of why and its cost. If a simpler path to the stated goal exists and the spec
  doesn't take it, say so and why.
- What this deliberately does not do.

The body stays as detailed as the implementer needs, after the review-facing front section.
Regenerate the summary and reorder the spec on every revision — a summary written before the
body is a plan, not a summary, and one not refreshed after edits goes stale exactly where review
matters most. [added] tags live only here, not inline in body sections.

## What the spec covers

Purpose and acceptance criteria (verifiable checks the implementing agent can test against).
Architecture and placement: which existing modules are touched, new vs. modified files, the seams
created, which existing patterns to follow. Data flow, error handling, testing. Risks and
questions the user explicitly decided to defer (or, after the first mention, deferred questions)
belong in the `Deferred aspects` ledger below. Do not park unresolved material decisions there:
ask those before approval. Non-goals
and rejected alternatives, each with its why — features struck during
dialogue land here with the reason, so implementing agents don't reintroduce them and future
brainstorms don't relitigate. Sections scale with the work: a small feature may cover several of
these in a paragraph.

## Extensibility judgment

- For a new capability, the default is the simplest end-to-end design that meets the spec. For
  an iteration, the default is the established scope and prior commitments.
- For a new capability, extensions the project already names — roadmap docs, stated plans, the
  user's own expansion ideas — are design constraints, not current scope: keep them out of the
  first build, but shape the structure so they slot in cleanly later. For an iteration, prior
  approved commitments define the current scope; only additional roadmap work is deferred.
  Record deferred extensions with where they will plug in.
- For speculative extensibility, use judgment: identify the likely axes of change and keep them
  cheap — don't build them, but don't design them out. Ask the user only when the choice is
  expensive to reverse.

## Deferred aspects

When anything is deferred, end the spec with this ledger immediately before Implementation
guidance. It is the canonical durable record; summarize it in the review-facing scope boundary,
but do not maintain a competing list there. For each entry, state what is deferred, why, the
condition that brings it back into scope, and where it fits. On every revision, reconcile the
ledger before approval. If project instructions define a tracking system, also record or update
the follow-up there; this skill does not assume one. Omit this section when nothing is deferred.

## Implementation Guidance (spec tail)

End every finalized spec with this section, so any implementing agent — after compaction, a
handoff, or in a different harness — still carries the agreed working decisions and the path:

```md
## Implementation guidance
- TDD: <on/off and scope, as agreed with the user>
- Isolation: <worktree / branch / current checkout, as agreed>
- Verify: run <project's typecheck+test commands> before claiming any task done
- Review: <once after every task in this spec is complete and final verification passes;
  configured project mechanism or user choice, terminal signal, and clean-commit requirement>
- Scope: build only what this spec specifies — propose extras, don't build them
- Deferred aspects: <confirm the ledger was reconciled; point to it and any required tracker>
- Build order: <suggested sequence and why — e.g. riskiest interface first, thin vertical slice>
- Routing: <per work item: orchestrator or delegate, at what model/effort, and why — hard core
  needing the orchestrator's accumulated context vs. mechanical/compressible leaf — per the
  model-selection skill. Sequential by default; delegate for token efficiency, not speed>
- Orchestrator: <model/effort for the implementing session — the cheapest tier that still covers
  the hardest orchestrator-bound Routing item. The spec must be implementable by a fresh
  session; continuing the spec session is a cost call (fine while its context is still small),
  never a dependency — anything only the continued session knows belongs in the spec>
```
