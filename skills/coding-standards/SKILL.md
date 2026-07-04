---
name: coding-standards
description: Use when writing or reviewing code, adding types, or documenting
---

<!-- Stack-specific rules live in stack.local.md (gitignored, seeded from stack.template.md
     by install.sh — the template is a complete worked example for a TypeScript-first stack). -->

Any code you write **must** follow the rules below plus the stack-specific rules in
`stack.local.md` next to this file — **load it now**. If it is missing, or still the unedited
template on a project whose stack doesn't match it, apply only the generic rules here plus the
project's own conventions, and tell the user once per session to edit
`skills/coding-standards/stack.local.md` (install.sh seeds it from `stack.template.md`).

Only apply the rules to code sections that you are modifying anyway.
If you come across opportunities where existing code can be improved with these rules, but doing
so would cause wide spread changes outside of the scope of your current task, focus on your task
instead and return a refactoring suggestion for later to the user or orchestrating agent.
(Example: Renaming a global function, that would require updating many other files.)

## Type Safety

Types enforce contracts between caller and callee. Stricter typing reduces room for error and
lessens the need for testing and documentation.

- **Strong, explicit types** — Declare explicit types for all function signatures.
- **Don't work around the type system** — No untyped escape hatches, no unchecked casts, no
  asserting away nullability; the stack file names the concrete offenders for your language.
- Import library types if available, rather than defining custom types for input/output of
  libraries.
- Keep typing in sync with input validation at system boundaries.
- Types that mirror **persisted data or long-lived APIs** outlive a single deploy: a new field
  must tolerate records written before it existed (optional until a migration or backfill
  ships) — the stack file has the full mechanics.

## Comments and Documentation

### When to Comment

- **Explain purpose** — Why the code exists, not what it does
- **Provide context** — Business logic, edge cases, or non-obvious behavior
- **Document complexity** — Algorithms, workarounds, or non-standard patterns
- **Clarify intent** — When the code might be misunderstood

### When NOT to Comment

- **Don't state the obvious** — Avoid comments that just restate what the code clearly shows
- **Don't repeat function/variable names** — Function names should be self-documenting
- **Don't repeat type information** — Doc comments should not duplicate what the type
  signature already says
- **Don't document trivial logic** — Simple, straightforward code doesn't need comments

## Naming Conventions

- **Self-documenting names** — Names should convey purpose; no abbreviations or acronyms
- **Consistent style** — Follow existing codebase conventions (camelCase, PascalCase, etc.)
- **Avoid generic names** — `data`, `info`, `handler` only when context makes them clear.
  **Never** `helper` or `manager`.
- **Avoid generic file names** — Names that repeat across the codebase degrade search and tab
  navigation; prefer domain-specific names. The stack file has your language's examples.
