# Minimization analysis

An inventory of everything in the Superpowers plugin, with a keep/drop verdict and
reasoning for each piece. This fork's thesis: **2026 models and harnesses have absorbed
most of what Superpowers used to add on top. Keep only the pieces that still change agent
behavior in ways the model won't do on its own — drop everything that merely re-implements
a now-native capability or exists to maintain the upstream project.**

> **Historical document.** This is the original minimization analysis that produced the 7-skill
> fork. On 2026-07-02 the project was rebuilt on top of it (the `fable-powers` rebuild): all
> verdicts below were re-verified against live research, three skills were added
> (`agent-handover`, `model-selection`, `self-update`), and the deferred content work was
> executed. Current reasoning lives in `docs/mission-log.md` and `ASSUMPTIONS.md`.

## Status — 2026-07-02

What was actually executed (this section is authoritative where it differs from the per-feature
analysis below, which is the original reasoning):

- **Dropped:** all non-Claude harness support; upstream project/release machinery; upstream dev
  plans/specs; tests + skill-eval fixtures; `writing-skills`; the native-redundant skills
  (`writing-plans`, `executing-plans`, `subagent-driven-development`, `dispatching-parallel-agents`,
  `requesting-code-review`, `using-git-worktrees`, `finishing-a-development-branch`); the
  brainstorming visual-companion server; the SessionStart hook; the `using-superpowers` bootstrap;
  and `CODE_OF_CONDUCT.md`.
- **Added from the fork's `main`:** `coding-standards` (code quality) and `research`.
- **Architecture shift since this analysis:** the hook + bootstrap's job (making skills fire and
  routing to them) moved into an always-on, cross-harness `AGENTS.md` — essence per discipline +
  "→ load skill" pointers. See `AGENTS.md` and `MEMORY.md`.
- **Retained skills (7):** brainstorming, coding-standards, receiving-code-review, research,
  systematic-debugging, test-driven-development, verification-before-completion.
- **Deferred to a later session:** trimming/optimizing skill *content* (brainstorming kept in
  original form for now; TDD content changes pending; the code-quality essence in `AGENTS.md` is
  provisional).

## The lens

A modern coding harness (Claude Code, 2026) now does natively:

- **Plan mode** + `TodoWrite` task tracking (was: writing-plans / executing-plans)
- **Task / subagent dispatch**, including parallel dispatch (was: subagent-driven-development / dispatching-parallel-agents)
- **`EnterWorktree`** and native isolation (was: using-git-worktrees)
- **`/code-review`** and branch-finish flows (was: requesting-code-review / finishing-a-development-branch)
- **Native skill discovery** from `SKILL.md` frontmatter (was: the SessionStart injection + using-superpowers bootstrap)
- Strong native planning, decomposition, and coding.

What a model still does *not* do reliably on its own is **behavioral discipline**: refusing to
code before it understands the problem, writing the test first, chasing root cause instead of
patching symptoms, not claiming success it hasn't verified, and not caving to review feedback
just to be agreeable. That residue is what earns a place here.

Verdict key: **KEEP** · **KEEP (trim)** · **DROP** · **DROP (decided)** = pre-made call.

---

## Skills

### brainstorming — KEEP (trim deferred) · *decided keep*
The single most valuable thing Superpowers does: it stops the agent from jumping into code and
forces a one-question-at-a-time dialogue that teases out intent, constraints, and success
criteria, then gates on an approved design before any implementation. Models in 2026 are far
better but still default to "helpfully" scaffolding immediately; this hard gate is the antidote
and doesn't exist natively. The browser-based *visual companion* server was dropped (heavy
machinery, off-thesis). Trimming the skill prose is **deferred** — kept in original form for now,
pending review.

### test-driven-development — KEEP (content changes deferred)
The distinctive content is the **Iron Law** ("no production code without a failing test first;
if you wrote code first, *delete it*") and the long rationalization table that pre-empts every
excuse an agent invents to skip it. This is genuinely behavior-shaping: models default to
writing implementation first and tests after (or never). Native harnesses do not enforce
test-first. The fork's `main` also carries valuable additions (mock-only-at-boundaries, AHA,
refactoring-excluded-from-test-first, integration-first) — see the 2026-07-02 research note.
Porting those and trimming padding are deferred.

### systematic-debugging — KEEP
Two ideas here are worth their weight: "**no fixes without root-cause investigation first**"
(counters the model's instinct to patch the symptom) and the **Phase 4.5 escalation** ("3+
failed fixes means the architecture is wrong — stop iterating, step back"). Both are real
anti-patterns that strong models still fall into under pressure. `find-polluter.sh` (test
bisection) is a nice self-contained tool. The skill-eval fixtures that rode along in this folder
(`test-pressure-*.md`, `test-academic.md`, `CREATION-LOG.md`) were dropped with the eval mechanism.

### verification-before-completion — KEEP
Cheapest, highest-leverage keeper: pure discipline, zero machinery. "No completion claims
without fresh verification evidence" directly targets the model's optimism bias — the "should
pass," "seems to work," "this fixes it" reflex. Nothing native enforces this. A page of text
that measurably reduces false "done" claims is a bargain.

### receiving-code-review — KEEP
Low redundancy, and it counters a specific model failure mode native harnesses *don't* address:
sycophancy. It bans performative agreement ("You're absolutely right!"), requires restating and
verifying each point against the actual codebase, and legitimizes technical pushback when a
reviewer is wrong. As models get more agreeable this gets *more* useful, not less.

### coding-standards — KEEP (added from fork main)
Code-quality / typing / documentation discipline authored on the fork: strong explicit types, no
`any`/casts, boundary type-sync, cross-service type sharing, `if (value)` truthiness
normalization, and rules for evolving persisted & API-facing types. Not in obra. Review/rethink
pending.

### research — KEEP (added from fork main)
A deep-read workflow for mapping how a codebase/system/feature actually works before planning,
including a "check `docs/research/` first" step. Not in obra. Review/rethink pending.

### writing-plans — DROP
The mechanism (decompose into tasks, write ordered steps) is now native plan mode. The one
distinctive bit — the "**no placeholders / exact paths / type-consistency self-review**"
discipline — is worth a sentence, not a 174-line skill plus a reviewer-prompt file. Its whole
premise ("harness-native plan mode is an optional helper, not the source of truth") is the
*opposite* of this fork's thesis. The green-commit discipline it carried moved to `AGENTS.md`.

### executing-plans — DROP
"Load a plan and do the tasks in order, inline" is exactly default harness behavior. The only
residue of value is "stop when blocked, don't guess," which is a one-liner, not a skill.

### subagent-driven-development — DROP *(was the most debatable — confirmed)*
The largest, most elaborate skill (418 lines + three shell scripts + two prompt files). Its
genuinely clever ideas — file-based handoffs to keep the orchestrator's context clean, a
two-verdict (spec + quality) review gate, and a durable progress ledger that survives
compaction — are real. But this is precisely the orchestration to delegate to the harness's
native subagent/plan capabilities, and it's the heaviest machinery in the repo. Dropped; the
subagent-usage heuristic (delegate compressible/pollution-prone work, keep big-context work in
the orchestrator) moved to `AGENTS.md`.

### dispatching-parallel-agents — DROP
Parallel subagent dispatch is native. The lone insight ("group independent failures, one agent
per domain, check they didn't touch the same files") is a good habit but doesn't need a
185-line skill to convey.

### requesting-code-review — DROP
Superseded by the harness's native `/code-review`. The `code-reviewer.md` template is a decent
artifact but duplicates tooling you already have in the harness's skill list.

### using-git-worktrees — DROP
The skill *itself* says "defer to native worktree tools first." With `EnterWorktree` native,
this is almost entirely obsolete; the remaining safety checks (submodule guard, gitignore
verification) are edge cases the harness handles.

### finishing-a-development-branch — DROP
Native branch-finish/PR flows cover the menu (merge / PR / keep / discard). Its most bespoke
logic — provenance-aware worktree cleanup — mostly exists to clean up after *Superpowers' own*
worktree machinery, which this fork removed. It solves a problem we deleted.

### writing-skills — DROP *(decided)*
The meta-skill for authoring/testing skills (689 lines + persuasion-principles,
anthropic-best-practices, render-graphs.js, testing-skills-with-subagents). With a tiny curated
skill set edited by hand, this is pure overhead. Went with the eval mechanism.

### using-superpowers — DROP (superseded by AGENTS.md routing)
This was the bootstrap the SessionStart hook injected to force skill auto-triggering. Rather than
keep a Claude-only, aggressively-worded bootstrap, its job — routing to skills and enforcing
brainstorm-before-build — moved into the always-on, cross-harness `AGENTS.md` (essence + "→ load
skill" pointers). Dropped.

---

## Bootstrap & hooks

### SessionStart hook — DROP (routing moved to AGENTS.md)
The hook existed to compensate for probabilistic skill auto-triggering. With the discipline and
routing now always-on in `AGENTS.md` (read by Claude, Codex, and Cursor), the hook is redundant —
and dropping it removes the over-triggering it caused on simple tasks. `run-hook.cmd` (Windows
polyglot wrapper) and `session-start-codex` went with the dropped platforms.

---

## Multi-harness support — DROP (all non-Claude)
`.codex-plugin/`, `.cursor-plugin/`, `.kimi-plugin/`, `.opencode/`, `.pi/`, `.agents/`,
`gemini-extension.json`, `GEMINI.md`, `docs/README.kimi.md`, `docs/README.opencode.md`,
`docs/porting-to-a-new-harness.md`, `scripts/sync-to-codex-plugin.sh` (466 lines),
`hooks/session-start-codex`, `hooks/hooks-cursor.json`, and the `references/*-tools.md` files.
Supporting seven harnesses is a large maintenance surface with no payoff for a personal,
experimental fork. Compatibility with Codex and Cursor is instead achieved by convention:
operating guidance in `AGENTS.md` (which both read) + plain `SKILL.md` files that can be symlinked
in — no per-harness packaging.

---

## Dev / release / project machinery — DROP (mostly)
- **`CLAUDE.md` / `AGENTS.md`** — the upstream contribution rules (94% PR rejection rate, PR
  templates, "target the dev branch") were replaced with fork-appropriate content: `AGENTS.md` is
  now the operating guide (source of truth) and `CLAUDE.md` holds the fork's design principles.
- **`RELEASE-NOTES.md`** (1,317 lines) — upstream's release history. Dropped.
- **`.github/`** (PR template, issue templates, FUNDING) — upstream project process. Dropped.
- **`scripts/sync-to-codex-plugin.sh`, `scripts/lint-shell.sh`, `.pre-commit-config.yaml`** —
  tied to dropped harnesses / shell-heavy machinery. Dropped.
- **`scripts/bump-version.sh`, `.version-bump.json`, `package.json`** — dropped (pointed at the
  removed opencode/pi packaging).
- **`CODE_OF_CONDUCT.md`** — dropped (upstream-flavored).

---

## docs/ — DROP (upstream dev history)
`docs/plans/*` and `docs/superpowers/{plans,specs}/*` were **obra's own development plans and
specs** (visual-companion hardening, codex compatibility, etc.), not user content — dropped. The
spec directory convention is now `docs/specs/` (where brainstorming writes new specs), and
research notes live in `docs/research/`. `docs/testing.md` and `docs/windows/` went with the
test/platform drops.

---

## Repo meta
- **`assets/`** (app-icon.png, superpowers-small.svg) — branding; drop or replace once the fork
  is renamed. Not urgent.
- **`LICENSE`** — KEEP (Jesse Vincent copyright is required attribution).
- **`README.md`** — rewritten for the minimal fork.

---

## Summary table

| Piece | Verdict |
|---|---|
| brainstorming (dialogue + gate) | **KEEP** (trim deferred) |
| brainstorming visual companion server | **DROP** |
| test-driven-development | **KEEP** (content changes deferred) |
| systematic-debugging | **KEEP** |
| verification-before-completion | **KEEP** |
| receiving-code-review | **KEEP** |
| coding-standards | **KEEP** (added from main) |
| research | **KEEP** (added from main) |
| using-superpowers (bootstrap) | **DROP** (→ AGENTS.md) |
| SessionStart hook | **DROP** (→ AGENTS.md) |
| writing-plans | **DROP** |
| executing-plans | **DROP** |
| subagent-driven-development | **DROP** |
| dispatching-parallel-agents | **DROP** |
| requesting-code-review | **DROP** |
| using-git-worktrees | **DROP** |
| finishing-a-development-branch | **DROP** |
| writing-skills | **DROP (decided)** |
| tests/ + skill-eval fixtures | **DROP (decided)** |
| all non-Claude harness support | **DROP** |
| upstream dev/release machinery | **DROP** |
| upstream docs (plans/specs) | **DROP** |

**Net result:** from 14 skills to **7** (brainstorming, coding-standards, receiving-code-review,
research, systematic-debugging, test-driven-development, verification-before-completion), no hook,
no bootstrap, one harness, and no upstream project machinery. Enforcement and routing moved to an
always-on `AGENTS.md`.
