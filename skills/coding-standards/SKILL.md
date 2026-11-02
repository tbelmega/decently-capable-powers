---
name: coding-standards
description: Use when writing or reviewing code, adding types, or documenting
---

<!-- Per-stack rules live in stacks/<stack>.md (published bases) with optional gitignored
     stacks/<stack>.local.md personal deltas. -->

Any code you write **must** follow the rules below plus the stack rules for the project at
hand: identify the project's stack(s) from its manifest/build files (e.g. `package.json` →
typescript, `build.gradle.kts` → kotlin), then for each match **load `stacks/<stack>.md`**
next to this file, plus `stacks/<stack>.local.md` if it exists (the user's personal delta;
it wins where the two conflict). A multi-stack repo loads every matching pair. If no base in
`stacks/` matches the project, apply the generic rules here plus the project's own
conventions, and propose adding a `stacks/<stack>.md`, once, not per task.

Only apply the rules to code sections that you are modifying anyway.
Where existing code could be improved by them but fixing it would spread changes well outside
your current task, stay on the task and hand the user or orchestrating agent a refactoring
suggestion for later.
(Example: Renaming a global function, that would require updating many other files.)

## Type Safety

Types enforce contracts between caller and callee. Stricter typing reduces room for error and
lessens the need for testing and documentation.

- **Strong, explicit types** - Declare explicit types for all function signatures.
- **Don't work around the type system** - No untyped escape hatches, no unchecked casts, no
  asserting away nullability; the stack files name the concrete offenders per language.
- Import library types if available, rather than defining custom types for input/output of
  libraries.
- Keep typing in sync with input validation at system boundaries.
- Types that mirror **persisted data or long-lived APIs** outlive a single deploy: a new field
  must tolerate records written before it existed (optional until a migration or backfill
  ships); the stack files have the full mechanics.

## Guards and Validation

Before writing a guard, enumerate the input and source states it can face and the verdict for
each, including the states where it cannot tell, which are their own verdict and never a
silent pass or fail. Designing that table up front is what keeps failure behavior from being
discovered one cell at a time in review; a state you never named is one the guard answers by
accident.

## Comments and Documentation

Comment why the code exists and what is non-obvious (business rules, edge cases, workarounds,
algorithms), not what the code or its types already say.

**Don't anchor comments to the work that produced them.** Specs, plans, tickets, prompts, review
findings, phase and task numbers are transient; a reader a year from now cannot resolve them,
and the comment outlives them. State the constraint itself, not its provenance. A durable
external reference (upstream bug, RFC, standard) is fine when it explains behavior the code
cannot.

## Tests

- Mock only at system boundaries; prefer integration-style tests through real collaborators.
- Hardcode expected results; never recompute them with the production logic under test.
- No test-only methods or branches in production code.
- Make time, randomness and generated IDs injectable where a test needs to control them.
- Wait on conditions, not fixed sleeps, and treat a flaky test as a bug.
- Refactoring already-tested code needs no new tests: run the existing ones before and after.

## Naming Conventions

- **Self-documenting names** - Names should convey purpose; no unclear abbreviations (common
  ones such as `id`, `url`, `http` are fine)
- **Consistent style** - Follow existing codebase conventions (camelCase, PascalCase, etc.)
- **Avoid generic names** - `data`, `info`, `handler` only when context makes them clear.
  **Never** `helper` or `manager`.
- **Avoid generic file names** - Names that repeat across the codebase degrade search and tab
  navigation; prefer domain-specific names. The stack files have per-language examples.
