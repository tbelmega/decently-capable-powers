# Minimization analysis

An inventory of everything in the Superpowers plugin, with a keep/drop verdict and
reasoning for each piece. This fork's thesis: **2026 models and harnesses have absorbed
most of what Superpowers used to add on top. Keep only the pieces that still change agent
behavior in ways the model won't do on its own — drop everything that merely re-implements
a now-native capability or exists to maintain the upstream project.**
// NOTE the drawbacks of superpowers are: where it condradicts the agent behavior intended by the model producer/lab, it can degrade performance. AND: we are trying to be token/usage efficient now

## The lens

A modern coding harness (Claude Code, 2026) now does natively:

// NOTE: one specialty of my forked "plan writing" skill was that I required each task of each plan to end with a subtask "run typechecks, tests and commit if green with message <PRE DEFINED COMMIT MESSAGE>. leading to small, self-contained, guaranteed green commits. we can likely encourage that via AGENTS.md/CLAUDE.md? 
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

Verdict key: **KEEP** · **KEEP (trim)** · **DROP** · **DROP (decided)** = your pre-made call.

---

## Skills

### brainstorming — KEEP (trim) · *your decided keep*
The single most valuable thing Superpowers does: it stops the agent from jumping into code and
forces a one-question-at-a-time dialogue that teases out intent, constraints, and success
criteria, then gates on an approved design before any implementation. Models in 2026 are far
better but still default to "helpfully" scaffolding immediately; this hard gate is the antidote
and doesn't exist natively. **Trim:** the browser-based *visual companion* (a 1,700-line Node
server + HTML + start/stop shell scripts) is exactly the kind of heavy machinery this fork
exists to shed — it contradicts "rely on native capabilities" and is a maintenance liability.
Keep the dialogue-and-gate discipline; drop the visual server. (Flagged below as a sub-decision.)
// NOTE also we will optimize for a workflow that delegate visiual decisions to Claude Design

### test-driven-development — KEEP (trim)
The distinctive content is the **Iron Law** ("no production code without a failing test first;
if you wrote code first, *delete it*") and the long rationalization table that pre-empts every
excuse an agent invents to skip it. This is genuinely behavior-shaping: models default to
writing implementation first and tests after (or never). Native harnesses do not enforce
test-first. Worth keeping, but it can lose ~40% of its length — the point is made by the Iron
Law, red/green/refactor, and the rationalization table; the worked examples are padding.
// NOTE I'm not sure about this. maybe we can make TDD optional - require the model to ask the user wether it should follow TDD or not for a given task.
// I'm generally happy with the code outcome through TDD, but only after heavily steering towards integration-style testing over mock-heavy unit testing; and shaping the code structure before letting the agent write code (e.g. 3 tier architecture with certain patterns). I see agents apply TDD to not only application code, but e.g. infrastructure code in a way that doesn't help. let's experiment with this 

### systematic-debugging — KEEP (trim)
Two ideas here are worth their weight: "**no fixes without root-cause investigation first**"
(counters the model's instinct to patch the symptom) and the **Phase 4.5 escalation** ("3+
failed fixes means the architecture is wrong — stop iterating, step back"). Both are real
anti-patterns that strong models still fall into under pressure. `find-polluter.sh` (test
bisection) is a nice self-contained tool. **Trim:** drop the skill-testing fixtures that ride
along in this folder (`test-pressure-*.md`, `test-academic.md`, `CREATION-LOG.md`) — they
belong to the eval mechanism you're dropping.

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

### writing-plans — DROP
The mechanism (decompose into tasks, write ordered steps) is now native plan mode. The one
distinctive bit — the "**no placeholders / exact paths / type-consistency self-review**"
discipline — is worth a sentence, not a 174-line skill plus a reviewer-prompt file. Its whole
premise ("harness-native plan mode is an optional helper, not the source of truth") is the
*opposite* of this fork's thesis. Fold the anti-placeholder note into brainstorming's handoff
and let the harness own planning.
// NOTE what I liked about my modified plan-writing skill was the opportunity to review the plan, and have it structure tasks with checkboxes that I could observe being check off; if the model stalled, I had a place to restart the plan. on the other hand each "checking the checkbox" required a tool call which costs tokens

### executing-plans — DROP
"Load a plan and do the tasks in order, inline" is exactly default harness behavior. The only
residue of value is "stop when blocked, don't guess," which is a one-liner, not a skill.

### subagent-driven-development — DROP *(most debatable — see note)*
The largest, most elaborate skill (418 lines + three shell scripts + two prompt files). Its
genuinely clever ideas — file-based handoffs to keep the orchestrator's context clean, a
two-verdict (spec + quality) review gate, and a durable progress ledger that survives
compaction — are real. But this is precisely the orchestration you said you want to delegate to
the harness's native subagent/plan capabilities, and it's the heaviest machinery in the repo.
Keeping it contradicts the fork's thesis. I recommend dropping it and leaning on native Task
dispatch; if the two-verdict review gate proves missed, it can come back as a lightweight note
rather than a scripted framework. **This is the call most worth your review.**
// NOTE yes, drop. I want to leave orchestration mostly to the native agent behavior, engcouraging the use of subagents for tasks that require little context (e.g. codebase reseach, web research, running tests and fixing in a loop) while discouraging the use of subagent for tasks that require the subagent to build up a significant portion of the context that the orchestrating agent already has - big picture of the planned feature, completed changes, certain read code files and reasoning; I believe this would increase the usage cost and lead to worse implementation than letting the orchestrator implement. check me on this thought

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
worktree machinery, which this fork is removing. It solves a problem we're deleting.

### writing-skills — DROP *(your decided drop)*
The meta-skill for authoring/testing skills (689 lines + persuasion-principles,
anthropic-best-practices, render-graphs.js, testing-skills-with-subagents). With a tiny curated
skill set you're editing by hand, this is pure overhead. Goes with the eval mechanism.

### using-superpowers — KEEP (rewrite tiny)
This is the bootstrap that the SessionStart hook injects — the thing that makes skills
auto-trigger. Native skill discovery already surfaces skills from frontmatter, so the aggressive
version (the "1% chance = you MUST," the 12-row Red Flags rationalization table, per-harness
reference files) is overkill for a handful of skills. **Keep a slimmed version** whose only job
is to establish the one behavior native discovery won't: *brainstorm before you build*. Drop the
platform reference files (`references/{codex,pi,antigravity}-tools.md`).
// NOTE: I'm not sold on the hook. I tend to request brainstorming or debugging "with skills" explicitly, and get aannoyed when it acitvates superpower while I'm asking simple questions or give simple tasks
// the TDD and verify-before-completion can be useful to auto-activate, but I wonder if the model would discover and use them without a hook? maybe put reference in CLAUDE.md?

---

## Bootstrap & hooks

### SessionStart hook (session-start, hooks.json, run-hook.cmd) — KEEP (simplify)
Something has to load the bootstrap at session start, so keep a hook — but strip the tri-branch
platform detection (Cursor / Copilot / Codex JSON shapes) down to the Claude Code path only.
`run-hook.cmd` (Windows polyglot wrapper) and `session-start-codex` go with the dropped
platforms.

---

## Multi-harness support — DROP (all non-Claude)
`.codex-plugin/`, `.cursor-plugin/`, `.kimi-plugin/`, `.opencode/`, `.pi/`, `.agents/`,
`gemini-extension.json`, `GEMINI.md`, `docs/README.kimi.md`, `docs/README.opencode.md`,
`docs/porting-to-a-new-harness.md`, `scripts/sync-to-codex-plugin.sh` (466 lines),
`hooks/session-start-codex`, `hooks/hooks-cursor.json`, and the `references/*-tools.md` files.
Supporting seven harnesses is a large maintenance surface with no payoff for a personal,
experimental, Claude-Code-first fork. Pick one target (Claude Code) and delete the rest. This is
the single biggest bloat reduction and is squarely on-thesis.
// NOTE I do personally use Codex, Cursor and Claude side by side. I'd like to keep compatibility with these 3. should be easy though, Cursor and Codex read AGENTS.md and I tend to symlink a local checkout of these skills into the project or harness, so we don't have to deal with different marketplaces or plugin mechanisms. deleting the dot-folders if not a bad call - but: let's review the codex and cursor folders and see if there's anything we want to rescue into AGENTS.md or some other file

---

## Dev / release / project machinery — DROP (mostly)
- **`CLAUDE.md` / `AGENTS.md`** — 116 lines of *upstream contribution rules* (94% PR rejection
  rate, PR templates, "target the dev branch"). Irrelevant to a fork. Replace with a short
  fork-specific note or drop.
- **`RELEASE-NOTES.md`** (1,317 lines) — upstream's release history. Drop.
- **`.github/`** (PR template, issue templates, FUNDING) — upstream project process. Drop; the
  PR template is the one CLAUDE.md polices.
- **`scripts/sync-to-codex-plugin.sh`, `scripts/lint-shell.sh`, `.pre-commit-config.yaml`** —
  tied to dropped harnesses / shell-heavy machinery. Drop.
- **`scripts/bump-version.sh`, `.version-bump.json`, `package.json`** — keep only if you'll cut
  versioned releases; `package.json` currently points `main` at the dropped opencode plugin and
  declares a `pi` package — needs a rewrite or removal.
- **`CODE_OF_CONDUCT.md`** — cheap to keep, but upstream-flavored; your call. // NOTE drop

---

## docs/ — DROP (upstream dev history)
`docs/plans/*` and `docs/superpowers/{plans,specs}/*` are **obra's own development plans and
specs** (visual-companion hardening, codex compatibility, etc.), not user content — confusing to
inherit. Drop them. Keep the *directory convention* `docs/superpowers/specs/` since brainstorming
writes new specs there. `docs/testing.md` and `docs/windows/` go with the test/platform drops.

---

## Repo meta
  is renamed. Not urgent.
- **`LICENSE`** — KEEP (Jesse Vincent copyright is required attribution).
- **`README.md`** — rewrite for the minimal fork (already partially done).

---

## Summary table

| Piece | Verdict |
|---|---|
| brainstorming (dialogue + gate) | **KEEP (trim)** | // NOTE: this is the most valuable skill. don't trim yet, let me read it first in original form
| brainstorming visual companion server | **DROP** *(sub-decision)* |
| test-driven-development | **KEEP (trim)** |
| systematic-debugging | **KEEP (trim)** |
| verification-before-completion | **KEEP** |
| receiving-code-review | **KEEP** |
| using-superpowers (bootstrap) | **KEEP (slim)** |
| SessionStart hook | **KEEP (simplify to Claude-only)** |
| writing-plans | **DROP** |
| executing-plans | **DROP** |
| subagent-driven-development | **DROP** *(most debatable)* |
| dispatching-parallel-agents | **DROP** |
| requesting-code-review | **DROP** |
| using-git-worktrees | **DROP** |
| finishing-a-development-branch | **DROP** |
| writing-skills | **DROP (decided)** |
| tests/ + skill-eval fixtures | **DROP (decided)** |
| all non-Claude harness support | **DROP** |
| upstream dev/release machinery | **DROP** |
| upstream docs (plans/specs) | **DROP** |

**Net result:** from 14 skills to **6** (brainstorming, TDD, systematic-debugging,
verification-before-completion, receiving-code-review, using-superpowers), one simplified hook,
one harness, and no upstream project machinery.
