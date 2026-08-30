# TypeScript - stack rules

<!-- Published base, loaded for TypeScript projects. Personal additions/overrides go in
     stacks/typescript.local.md (gitignored, optional; wins over this file on conflict). -->

## Type safety

- **Strict null checks** - Use non-nullable types by default. At boundaries, normalize optional
  fields so **presence** is checked with **`if (value)`** where that matches the domain (see
  **Truthiness and empty optional values** below); use explicit `null` / `undefined` checks only
  when the domain requires it (e.g. PATCH, or valid `0` / `""`).
- **No `any`, no non-null assertions, no unchecked type casts.**
- Make use of generic types, union types and branded strings to strengthen typing.
- Aim for cross-service type safety, e.g. sharing the same type files between frontend and
  backend.

### Discriminating unions

- Prefer an **explicit discriminated union**: give every member a shared discriminant property
  with a distinct literal value, then narrow on that property.
- When an existing API or persisted-data contract must remain a **structural union**, centralize
  the structural check in a named type guard instead of repeating property-name string literals
  at call sites.
- TypeScript trusts a user-defined type predicate without proving its implementation. Use a
  property-presence guard only when the runtime contract guarantees that the checked property is
  **required and present** on the guarded member and **absent from every other member**. Make its
  name compiler-checked as **declared-exclusive against every other member**. For a binary union,
  for example, use `"bookingStatus" satisfies Exclude<keyof Confirmation, keyof Pending>`; a
  larger union must check all remaining members, not just one. This checks spelling and declared
  exclusivity, not runtime presence or absence. Do not cast the result.
- A property-presence guard narrows a value already typed as the closed union; it does **not**
  validate untrusted external data. Validate external response shapes at the system boundary
  when the runtime contract is not otherwise guaranteed.

### Evolving persisted and API-facing types

Types that mirror **stored documents** (JSON files, DB rows, export formats) or **long-lived
HTTP responses** outlive a single deploy. Old data will not contain keys for fields added later.

- When adding a new property to an existing declaration, mark it **optional** (e.g.
  `projectId?: string | null`) unless you are explicitly shipping a migration or backfill that
  updates every existing record (or you version the schema and read old versions).
- **Omitted key** (`undefined` after parse) and **explicit `null`** are different; persisted
  data often omits optional fields. Decoders and callers must tolerate missing keys, not only
  `null`.
- Do **not** add a new required field to a persisted shape and assume "everyone will redeploy
  empty data"; that breaks real installs.

### Truthiness and empty optional values

Design types and normalization so that presence vs absence can be written as `if (value)`
instead of `if (value === null || value === undefined)`, unless there is a documented,
exceptional reason.

- **Default rule:** do not assign different meanings to different falsy values for the same
  concept (e.g. `null` for "empty" and `undefined` for "something else" in normal domain code).
  Treat all falsy values the same for "no value / not set", so `if (value)` is the idiomatic
  guard.
- **PATCH / partial-update payloads** are the main exception: `undefined` means "omit / do not
  change this field"; `null` (or an explicit empty sentinel agreed in the contract) means "set
  to empty / clear." Document that on the request type or route.
- **Counterexamples:** where `0`, `""`, or `false` are valid domain values (numeric zero, an
  empty string distinct from missing), truthiness alone will not do; use explicit comparisons
  or separate types. The `if (value)` goal applies to optional references, labels, and similar,
  where only "present vs absent" matters.

## Documentation (JSDoc)

- JSDoc must not duplicate TypeScript type signatures - types carry the contract; comments
  carry the why.

## File naming

- Avoid generic file names like `handler.ts`, `utils.ts`, `service.ts` that repeat across the
  codebase and degrade search and tab navigation. Prefer domain-specific names (e.g.
  `create-tenant.handler.ts`, `email-validation.utils.ts`).
