# Final review layout

Use this only after the interview and initial draft are complete, during the finalization step
before asking for approval. Do not use it to choose interview questions, direct discovery, or
structure an early draft.

This is a reordering checklist, not a form. Keep only sections that are relevant; do not invent
content to fill a heading. Order the reviewer-facing front section by what the user most needs to
notice and judge, rather than by conversation chronology, implementation sequence, or a fixed
severity ranking.

```md
Status: Draft — not for implementation

# <Topic>

## Review summary
<!-- Write last. State what this builds and what it deliberately does not do. -->

## Decisions and assumptions requiring review
<!-- Include agent-made judgments, their rationale, and reversibility. -->

## Scope boundary
### This iteration
### Deferred aspects summary
<!-- Summarize the canonical ledger near the end; do not duplicate it here. -->
### Explicit non-goals

## Risks and failure modes

## Acceptance criteria and high-level workflow

## Implementation detail
<!-- Architecture, placement, data flow, errors, testing, and other implementer detail. -->

## Deferred aspects
<!-- Canonical ledger. For each entry: what, why, return condition, and intended fit. Omit when
     nothing is deferred. Follow project-defined tracking instructions when they exist. -->

## Implementation guidance
```

A reviewer who reads only the first quarter must encounter every decision, assumption, scope
boundary, deferral, exclusion, and risk on which they could reasonably object or redirect the
work. Before implementation, the guidance must call out the Deferred aspects ledger again.
