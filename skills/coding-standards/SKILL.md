---
name: coding-standards
description: Use when writing or reviewing code, adding types, or documenting
---

Any code you write **must** follow all rules below, to make the codebase consistent, readable, maintainable and reliable.
Only apply the rules to code sections that you are modifying anyway. 
If you come across opportunities where existing code can be improved with these rules, but doing so would cause wide spread changes outside of the scope of your current task, focus on your task instead and return a refactoring suggestion for later to the user or orchestrating agent. (Example: Renaming a global function, that would require updating many other files.)

## Type Safety

Types enforce contracts between caller and callee. Stricter typing reduces room for error and lessens the need for testing and documentation.

- **Strong, explicit types** — Declare explicit types for all function signatures.
- **Strict null checks** — Use non-nullable types by default. Handle `null` and `undefined` explicitly.
- **Don't work around the type system** — No `any`, no non-null assertions, no unchecked type casts.
- Import library types if available, rather than defining custom types for input/output of libraries.
- Keep typing in sync with input validation at system boundaries.
- Aim for cross-service type safety, e.g. sharing the same type files between frontend and backend.
- Make use of generic types, union types and branded strings to strengthen typing.

## Comments and Documentation

### When to Comment

- **Explain purpose** — Why the code exists, not what it does
- **Provide context** — Business logic, edge cases, or non-obvious behavior
- **Document complexity** — Algorithms, workarounds, or non-standard patterns
- **Clarify intent** — When the code might be misunderstood

### When NOT to Comment

- **Don't state the obvious** — Avoid comments that just restate what the code clearly shows
- **Don't repeat function/variable names** — Function names should be self-documenting
- **Don't repeat type information** — JSDoc should not duplicate TypeScript type signatures
- **Don't document trivial logic** — Simple, straightforward code doesn't need comments

## Naming Conventions

- **Self-documenting names** — Names should convey purpose; no abbreviations or acronyms
- **Consistent style** — Follow existing codebase conventions (camelCase, PascalCase, etc.)
- **Avoid generic names** — `data`, `info`, `handler` only when context makes them clear. **Never** `helper` or `manager`.
- **Avoid generic file names** — Names like `handler.ts`, `utils.ts`, `service.ts` that repeat across the codebase degrade search and tab navigation. Prefer domain-specific names (e.g. `create-tenant.handler.ts`, `email-validation.utils.ts`).
