---
name: coding-standards
description: Use when writing or reviewing code, adding types, or documenting
---

<!-- personal: tuned to a TypeScript-first cloud/web stack. Swap the specifics for your own. -->

Any code you write **must** follow all rules below, to make the codebase consistent, readable, maintainable and reliable.
Only apply the rules to code sections that you are modifying anyway. 
If you come across opportunities where existing code can be improved with these rules, but doing so would cause wide spread changes outside of the scope of your current task, focus on your task instead and return a refactoring suggestion for later to the user or orchestrating agent. (Example: Renaming a global function, that would require updating many other files.)

## Type Safety

Types enforce contracts between caller and callee. Stricter typing reduces room for error and lessens the need for testing and documentation.

- **Strong, explicit types** — Declare explicit types for all function signatures.
- **Strict null checks** — Use non-nullable types by default. At boundaries, normalize optional fields so **presence** is checked with **`if (value)`** where that matches the domain (see **Truthiness and empty optional values** below); use explicit `null` / `undefined` checks only when the domain requires it (e.g. PATCH, or valid `0` / `""`).
- **Don't work around the type system** — No `any`, no non-null assertions, no unchecked type casts.
- Import library types if available, rather than defining custom types for input/output of libraries.
- Keep typing in sync with input validation at system boundaries.
- Aim for cross-service type safety, e.g. sharing the same type files between frontend and backend.
- Make use of generic types, union types and branded strings to strengthen typing.

### Evolving persisted and API-facing types

Types that mirror **stored documents** (JSON files, DB rows, export formats) or **long-lived HTTP responses** outlive a single deploy. Old data will not contain keys for fields added later.

- When adding a **new property** to an existing declaration, mark it **optional** (e.g. `projectId?: string | null`) **unless** you are explicitly shipping a **migration or backfill** that updates every existing record (or you version the schema and read old versions).
- **Omitted key** (`undefined` after parse) and **explicit `null`** are different; persisted data often omits optional fields. Decoders and callers must tolerate **missing** keys, not only `null`.
- Do **not** add a new required field to a persisted shape and assume “everyone will redeploy empty data”; that breaks real installs.

### Truthiness and empty optional values

Design types and normalization so that **presence vs absence** can be written as **`if (value)`** instead of **`if (value === null \|\| value === undefined)`**, unless there is a **documented, exceptional** reason.

- **Default rule:** Do **not** assign **different meanings** to different **falsy** values for the same concept (e.g. do not use `null` for “empty” and `undefined` for “something else” in normal domain code). Treat **all falsy values the same** for “no value / not set” so **`if (value)`** is the idiomatic guard.
- **PATCH / partial-update payloads** are the main **exception:** **`undefined`** means “omit / do not change this field”; **`null`** (or an explicit empty sentinel agreed in the contract) means “set to empty / clear.” Document that on the request type or route.
- **Counterexamples:** If **`0`**, **`""`**, or **`false`** are **valid domain values** (e.g. numeric zero, empty string that is distinct from missing), you cannot use truthiness alone — use explicit comparisons or separate types. The “`if (value)`” goal applies to **optional references, labels, and similar** where only “present vs absent” matters.

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
