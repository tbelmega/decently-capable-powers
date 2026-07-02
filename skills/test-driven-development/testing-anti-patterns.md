# Testing Anti-Patterns

**Load when:** writing or changing tests, adding mocks, or tempted to add test-only methods to production code.

## Overview

Test real behavior, not mock behavior. Mocks isolate; they are not the thing being tested.

**Core principle:** Test what the code does, not what the mocks do.

## Iron Laws

```
1. NEVER mock project's own code — only at system boundaries (3rd party, external APIs)
2. NEVER test mock behavior
3. NEVER add test-only methods to production classes
4. NEVER mock without understanding dependencies
5. NEVER duplicate calculation logic in tests — hardcode expected results
```

## Anti-Pattern 1: Testing Mock Behavior

**Violation:** Asserting on mock elements (e.g. `getByTestId('sidebar-mock')`). Verifies mock exists, not component behavior.

**Fix:** Test real component or unmock it. If mocking for isolation, assert on real behavior, not mock presence.

**Gate:** Before asserting on any mock element — Am I testing real behavior or mock existence? If mock existence → delete assertion or unmock.

## Anti-Pattern 2: Test-Only Methods in Production

**Violation:** Methods like `destroy()` only used in tests. Pollutes production class, violates YAGNI.

**Fix:** Move to test utilities. Session has no `destroy()`; test-utils provide `cleanupSession(session)`.

**Gate:** Before adding method to production class — Is this only used by tests? If yes → don't add. Put in test utilities. Does this class own the resource lifecycle? If no → wrong class.

## Anti-Pattern 3: Mocking Without Understanding

**Violation:** Mocking high-level method that has side effects the test depends on. Test passes for wrong reason or fails mysteriously.

**Fix:** Understand dependency chain. Mock at lowest level (the slow/external operation). Or use test doubles that preserve necessary behavior.

**Gate:** Before mocking — What side effects does the real method have? Does this test depend on any? If depends on side effects → mock lower level, not the method test depends on. If unsure → run with real implementation first, observe, then add minimal mock.

## Anti-Pattern 4: Incomplete Mocks

**Violation:** Partial mock with only fields you think you need. Downstream code may use omitted fields; silent failures.

**Fix:** Mirror real API completely. Include all fields real response contains.

**Gate:** Before creating mock response — What fields does real API return? Include all. Partial mocks fail silently.

## Anti-Pattern 5: Tests as Afterthought

**Violation:** Implementation complete, no tests, "ready for testing."

**Fix:** TDD. Write failing test → implement → refactor. Tests are part of implementation.

## Anti-Pattern 6: Mocking Project Code

**Violation:** Mocking your own services, repositories, or internal modules. Test passes when mock is present, fails with real code.

**Fix:** Mock only at system boundaries—3rd party APIs, external services, databases (use test doubles or in-memory implementations). Use real project code everywhere else.

## Anti-Pattern 7: Duplicating Calculation Logic in Tests

**Violation:** Test calculates expected result using same logic as production (e.g. `expect(result).toBe(complexFormula(input))`). Both share same bug = test worthless.

**Fix:** Hardcode expected results. Fixed inputs, known outputs. Verify against literal values.

## Non-Deterministic Code (Date, Random, UUID)

**Problem:** `new Date()`, `Math.random()`, `uuid.v4()` in production code make tests flaky or hard to assert.

**Fix:** Wrap in injectable abstractions (e.g. `Clock`, `Random`, `IdGenerator`). Inject into production code. In tests, use fixed implementations (`FixedClock`, `SeededRandom`, deterministic ID generator). The real implementation (e.g. `SystemClock`) can be tested with property-based tests.

**Pattern:** Interface → `SystemClock` (prod) / `FixedClock` (tests). Never call `new Date()` directly in business logic.

## When Mocks Become Too Complex

**Signs:** Mock setup longer than test logic; mocking everything; mocks missing methods; test breaks when mock changes.

**Action:** Consider integration tests with real components. Often simpler than complex mocks.

## Frontend Testing

Frontend tests tend to run slower and be flakier than backend. Same principles apply; some adjustments:

- **Extract logic** — Validation, formatting, state transforms as pure functions. Unit test without React. Fast, deterministic.
- **Test behavior** — Query by role/label (React Testing Library). Avoid testing implementation details.
- **Mock at boundaries** — API (MSW), timers, Clock. Not internal components.
- **Condition-based waiting** — `waitFor`, `findBy` instead of `setTimeout`. Wait for conditions, not fixed delays.
- **Testing Trophy** — Broad base: type checks. Upper middle: integration-style tests. Fewer fine-grained unit tests in the lower middle. Small E2E crown at top.
- **Flaky = bug** — Fix race conditions and waiting, don't paper over with retries.

Refine based on your stack and experience.

## Quick Reference

| Anti-Pattern | Fix |
|--------------|-----|
| Mock project code | Mock only at system boundaries |
| Duplicate calculation in test | Hardcode expected results |
| Non-deterministic code (Date, random, uuid) | Wrap in injectable, use fixed impl in tests |
| Assert on mock elements | Test real component or unmock |
| Test-only methods in production | Move to test utilities |
| Mock without understanding | Understand dependencies first, mock minimally |
| Incomplete mocks | Mirror real API completely |
| Tests as afterthought | TDD — tests first |
| Over-complex mocks | Consider integration tests |

## Red Flags

- Mocking project's own code
- Test calculates expected result (same logic as prod)
- Assertion checks for `*-mock` test IDs
- Methods only called in test files
- Mock setup >50% of test
- Test fails when you remove mock
- Can't explain why mock is needed
- Mocking "just to be safe"

## TDD Prevents These

Write test first → forces thinking about what you're testing. Watch it fail → confirms test tests real behavior. Minimal implementation → no test-only creep. Real dependencies first → see what test needs before mocking.

**If you're testing mock behavior, you violated TDD** — you added mocks without watching test fail against real code first.
