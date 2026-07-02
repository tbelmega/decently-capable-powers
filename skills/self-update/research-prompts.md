# Research prompt templates

Two prompts, each for one subagent with live web access (WebSearch/WebFetch). Fill the parameter
block, then dispatch verbatim. These are the prompts that produced the 2026-07-02 research notes;
keep their structure, update their parameters.

## Parameters (update before each run)

- `{DATE}` — today's date
- `{HARNESSES}` — harnesses in daily use (2026-07: Claude Code, OpenAI Codex CLI, Cursor)
- `{MODELS}` — model roster with typical effort (2026-07: Opus 4.8 mid–xhigh, Sonnet 5,
  GPT-5.5 low–high, Cursor Composer, GLM 5.2 via Cursor)
- `{REPO}` — absolute path to the checkout being updated

## Prompt 1 — harness capabilities

> You are doing live web research for a project that maintains agent operating guidance (skills
> + always-on instructions) across coding-agent harnesses. Research the CURRENT state ({DATE})
> of: {HARNESSES}. Use WebSearch and WebFetch extensively; prefer official docs over blog posts,
> and note the freshness of each source.
>
> For each harness: (1) NATIVE CAPABILITIES today — planning, task tracking, subagent dispatch
> (parallel?), worktrees, code review, hooks, background/async agents, orchestration.
> (2) GUIDANCE SURFACES — skills or equivalent, load paths, frontmatter requirements, whether
> they auto-trigger by description. (3) USER-LEVEL (GLOBAL) CONFIG — exactly where user-scope
> instructions and skills live; does it support both global instructions AND global skills? Cite
> the doc page for every load-path claim. (4) AGENTS.md support — which read it natively, at
> which locations, precedence rules. (5) MEMORY — native persistent memory across sessions?
>
> Also verify or refute every row of {REPO}/ASSUMPTIONS.md that cites the harness-capabilities
> research.
>
> WRITE findings as a structured markdown note to
> {REPO}/docs/research/{DATE}-harness-capabilities.md — verdict-first, bolded labels, concrete
> paths and citation URLs, freshness caveats where docs were thin, under ~200 lines. RETURN only
> a 10–15 line summary: (a) anything contradicting ASSUMPTIONS.md, (b) exact user-level config
> surfaces per harness, (c) surprising new native capabilities guidance should exploit or stop
> re-implementing.

## Prompt 2 — model failure modes

> You are doing live web research on the PERSISTENT FAILURE MODES of current-generation ({DATE})
> coding models/agents, to decide which behavioral guidance still earns a place in an
> agent-guidance project. Models in scope: {MODELS}. Sources: official model/system cards,
> release notes, harness release notes, credible practitioner writeups, fresh academic evals.
>
> The project's standing thesis: capability gaps closed; temperament flaws persist and need
> guidance. Read {REPO}/ASSUMPTIONS.md for the currently-assumed flaw list (coding before
> understanding, test-integrity/reward hacking, symptom-patching, unverified success claims,
> sycophancy, over-engineering, context rot, effort miscalibration).
>
> Investigate: (1) For each assumed flaw — evidence it PERSISTS, is FIXED/trained away, or is
> HANDLED BY HARNESSES natively. (2) NEW failure modes of this generation worth guidance, and
> how the named models fail DIFFERENTLY from each other. (3) Model-choice implications: which
> model class suits which task type; reasoning-effort tradeoffs.
>
> WRITE findings to {REPO}/docs/research/{DATE}-model-failure-modes.md — verdict-first, per-claim
> evidence with URLs, explicit "evidence thin/anecdotal" flags, under ~180 lines. RETURN only
> ~12 lines: per-flaw one-line verdicts with confidence, the most important NEW failure modes,
> and the single most decision-relevant model-choice insight.
