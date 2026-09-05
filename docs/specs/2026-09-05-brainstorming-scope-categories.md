# Define brainstorming scope categories

Status: Approved by Thiemo in the attended session on 2026-09-05.

Replace the ambiguous spec label "Non-goals" with three explicit categories in the
brainstorming skill and its final review layout:

- Deferred scope may guide a choice implementation already requires toward an equally simple
  option that leaves future extensibility open. Spend no extra effort preparing for it.
- Out of scope receives no reasoning or implementation now and implies no decision about
  future desirability.
- Prohibited outcomes must be actively prevented and covered by verifiable acceptance criteria.

Only current scope authorizes implementation, even when an extra feature appears free.
Align existing extensibility instructions with these definitions and use "Deferred scope"
consistently for the canonical ledger. Keep rejected alternatives distinct from prohibited
outcomes. When an existing spec is revised, classify ambiguous entries from recorded intent
or clarify it; this change does not migrate historical specs.

## Acceptance criteria

The skill and review layout use the three categories consistently. Neither requires advance
engineering for deferred or speculative extensions. The ledger allows intended fit to remain
undesigned. A valid generated spec does not use "Non-goals" as a heading or category.

## Implementation guidance

- Documentation only; current checkout, existing checks, no new tests (agent defaults presented
  in the attended session).
- Verify with the skill validator, installer test suite, and diff inspection. No typecheck
  exists for this Markdown and shell repository.
- Review with the configured DCL reviewer after the final implementation commit; declare the
  brainstorming skill as a governance rewrite.
- This short approval record lives with the implementation in the assigned DCP checkout;
  no task-tracking policy/spec checkout is changed.
