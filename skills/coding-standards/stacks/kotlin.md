# Kotlin - stack rules

<!-- Published base, loaded for Kotlin projects. Personal additions/overrides go in
     stacks/kotlin.local.md (gitignored, optional; wins over this file on conflict).
     Drafted by an agent 2026-07-04 mirroring the TypeScript base; reviewed and approved
     by the maintainer 2026-08-29, so these are held standards rather than a draft. -->

## Type safety

- **Non-nullable by default** - Push nullability to system boundaries; normalize there so
  domain code works with non-null types. Prefer `?.let`/`?:` handling at the boundary over
  threading `T?` through call chains.
- **No `!!`** (the non-null assertion), no unchecked casts (`as` without `?`/type check), no
  suppressed `UNCHECKED_CAST` without a documented reason at the cast site.
- Use **sealed classes/interfaces** for closed unions (the analog of TS union types) and
  exhaustive `when` over them, with no `else` branch that would swallow a future variant.
- Use **value classes** for domain identifiers (the analog of branded strings) - a `TenantId`
  should not be assignable from a bare `String`.
- Prefer **data classes** with `val` (immutability by default); `var` only with a reason.
- Import library types rather than redefining shapes for library input/output.

### Evolving persisted and API-facing types

Serialized shapes (kotlinx.serialization / Jackson / Room entities, long-lived HTTP responses)
outlive a single deploy. Old data will not contain keys for fields added later.

- When adding a **new property** to a persisted shape, give it a **default value** (or make it
  nullable with a default of `null`) **unless** a migration or backfill updates every existing
  record; otherwise deserialization of old records fails at runtime.
- **Missing key** and **explicit `null`** are different; configure and test the decoder's
  behavior for both (e.g. `coerceInputValues`, `explicitNulls` in kotlinx.serialization).
- Do **not** add a new required constructor parameter to a persisted data class and assume
  redeploys start from empty data; that breaks real installs.

## Documentation (KDoc)

- KDoc must not duplicate what the signature already says (types, nullability, parameter
  names): the signature carries the contract, comments carry the why.

## File naming

- Avoid generic file names like `Utils.kt`, `Helpers.kt`, `Manager.kt` that repeat across the
  codebase and degrade search and navigation. Name files after the domain concept they serve
  (e.g. `TenantProvisioning.kt`, `EmailValidation.kt`); one top-level abstraction per file
  where practical.
