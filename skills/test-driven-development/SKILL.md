---
name: test-driven-development
description: Use when the work-stream follows TDD (per the operating guide's once-per-work-stream decision) — before writing any implementation code
---

# Test-Driven Development (TDD)

Write the test first. Watch it fail. Write minimal code to pass.

**Core principle:** If you didn't watch the test fail, you don't know if it tests the right thing.

## When to Use

New features, bug fixes, behavior changes — whenever TDD is on for the work-stream.

**Exceptions (ask first):** throwaway prototypes, generated code, configuration files.

**Refactoring is excluded from test-first.** When refactoring code that is already tested (e.g.
extracting a method from a service covered by integration tests), do **not** write new tests
against the refactored code. Run the existing tests before and after the change to confirm
behavior is unchanged.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Wrote code before the test? Delete it. Start over. Don't keep it as "reference", don't "adapt"
it while writing tests — delete means delete.

## The Cycle

RED (write failing test) → verify it fails correctly → GREEN (minimal code) → verify it passes →
REFACTOR (stay green) → next test.

### RED — Write Failing Test

One minimal test, one behavior, clear name. Use real code. **Mock only at system boundaries**
(3rd-party services, external APIs) — never the project's own code.

```typescript
// Good: tests real behavior
test('retries failed operations 3 times', async () => {
  let attempts = 0;
  const operation = () => { attempts++; if (attempts < 3) throw new Error('fail'); return 'success'; };
  expect(await retryOperation(operation)).toBe('success');
  expect(attempts).toBe(3);
});

// Bad: tests mock, not code
test('retry works', () => { expect(mock).toHaveBeenCalledTimes(3); });
```

### Verify RED — mandatory

Run only the **current test file** during TDD for fast feedback (e.g.
`npm test path/to/current.test.ts`). Full suite when the task is done.

Confirm: test fails (not errors), failure message is the expected one, fails because the feature
is missing. Test passes? Fix the test. Test errors? Fix the error, re-run.

### GREEN — Minimal Code

Simplest code to pass. No extra features, no refactoring other code.

**Complex change?** Start with a trivial test (e.g. endpoint returns 200). Make it pass. Extend
the test, implement. Repeat. Don't write one large test up front.

### Verify GREEN — mandatory

Confirm: test passes, other tests pass, output pristine. Test fails? Fix the code, not the test.

**Never make green by weakening the red.** Deleting a failing test, skipping it, loosening its
assertions, or catching the error it exposes is reward hacking, not progress. If the test itself
is genuinely wrong, say so explicitly and fix it as its own step — with the reason stated —
never silently in the same change that makes it pass.

### REFACTOR — After Green Only

Improve names and structure while keeping tests green. Don't add behavior.

Apply AHA (Avoid Hasty Abstractions) and the Rule of Three:

- One or two occurrences: prefer clear concrete code while the shared shape is uncertain.
- Third occurrence: evaluate whether the pattern and ownership are genuinely shared; abstract
  when that evidence is present. The third occurrence triggers judgment, not automatic
  extraction — it is often useful to write the third concrete case first, then refactor with all
  three examples visible.
- Abstract earlier only when a domain contract, architectural boundary, or correctness invariant
  already requires one shared implementation. Do not abstract for predicted reuse.
- Similar-looking code may remain separate when the cases change independently.

## Good Tests

| Quality | Good | Bad |
|---------|------|-----|
| Minimal | One thing | "and" in name = split |
| Clear | Name describes behavior | `test('test1')` |
| Real | Tests code behavior | Tests mock behavior |
| Structure | Setup → call → verify (follow codebase: ARRANGE/ACT/ASSERT or GIVEN/WHEN/THEN) | Setup hidden in beforeEach |
| Expectations | Hardcode expected results | Duplicate calculation logic in test |

**Never duplicate calculation logic in tests.** Fixed inputs, known outputs. Calculating
expectations in the test makes prod and test share the same bug.

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Passing immediately proves nothing. |
| "Tests after achieve same goals" | Tests-after = "what does this do?" Tests-first = "what should this do?" |
| "Already manually tested" | Ad-hoc ≠ systematic. No record, can't re-run. |
| "Deleting X hours is wasteful" | Sunk cost. Keeping unverified code is debt. |
| "Need to explore first" | Fine — throw away the exploration, start with TDD. |
| "This is different because..." | Rationalization. Start over. |

## Red Flags — stop and start over

Code before test · test passes immediately · can't explain why the test failed · "keep as
reference" / "adapt existing code" · "tests after achieve the same purpose" · "TDD is dogmatic,
I'm being pragmatic".

## Verification Checklist

- [ ] Every new function has a test
- [ ] Watched each test fail before implementing, for the expected reason
- [ ] Minimal code to pass
- [ ] All tests pass, output pristine
- [ ] Tests use real code (mocks only at system boundaries)

Can't check all boxes? You skipped TDD.

## When Stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write the wished-for API. Assertion first. Ask. |
| Test too complicated | Design too complicated. Simplify the interface. |
| Must mock everything | Code too coupled. Dependency injection. |
| Non-deterministic code (Date, random, uuid) | Wrap in an injectable (Clock, etc.), fixed impl in tests |
| Test setup huge | Extract helpers. Still complex? Simplify the design. |

## Bug Fixes

Write a failing test reproducing the bug first, then fix. Never fix a bug without a test.

## Frontend Testing

Frontend tests tend to be slower and flakier than backend. Extract logic to pure functions (unit
test those). Use condition-based waiting (`waitFor`, `findBy`) instead of fixed timeouts. Mock at
boundaries (API, timers). This guidance is less battle-tested than backend — refine with
experience.

## Testing Anti-Patterns

When adding mocks or test utilities, read [testing-anti-patterns.md](testing-anti-patterns.md):
never mock project code, never test mock behavior, no test-only methods in production, mirror
real APIs completely, hardcode expected results.
