# Assumptions registry

The empirical claims this project's guidance rests on. Each row names the claim, the guidance it
justifies, when it was last verified, and where the evidence lives. The `self-update` skill
re-verifies rows and bumps dates. **A refuted row means the guidance it justifies must change** —
that's the point of keeping this table.

| # | Claim | Justifies | Verified | Evidence |
|---|-------|-----------|----------|----------|
| A1 | Harnesses natively cover planning, task tracking, parallel subagents, worktrees, code review, hooks, and persistent memory | Dropping obra's plan/execute/subagent/worktree/review skills; re-implementing none of it | 2026-07-02 | [harness note](docs/research/2026-07-02-harness-capabilities.md) |
| A2 | All three harnesses read agentskills.io `SKILL.md` with description-based auto-trigger; shared paths `~/.agents/skills/` (Codex, Cursor) and `~/.claude/skills/` (Claude Code, Cursor) | One skills tree serving all harnesses; install.sh symlink targets | 2026-07-02 | harness note |
| A3 | Claude Code reads CLAUDE.md, not AGENTS.md; Codex reads a global `~/.codex/AGENTS.md`; Cursor has no file-based global instructions (Settings UI only) | install.sh instruction targets; the `@AGENTS.md` import; the Cursor paste step | 2026-07-02 | harness note |
| A4 | Models don't reliably self-invoke discipline — plan modes are opt-in, skill auto-triggering is probabilistic | The always-on essence layer existing at all (two-layer architecture) | 2026-07-02 | [failure-modes note](docs/research/2026-07-02-model-failure-modes.md) §1.1 |
| A5 | Coding-before-understanding persists in current models | brainstorming and research skills | 2026-07-02 | failure-modes §1.1 |
| A6 | Reward hacking (test deletion/weakening, gamed evidence) is prevalent and *worse* in the newest models | Test-integrity essence; anti-hacking content in TDD and verification | 2026-07-02 | failure-modes §1.2 |
| A7 | Symptom-patching over root cause persists | systematic-debugging skill | 2026-07-02 | failure-modes §1.3 |
| A8 | Unverified success claims: largely trained away in Claude, persist in GPT-5.5 | verification-before-completion kept, but slim (cross-harness need) | 2026-07-02 | failure-modes §1.4 |
| A9 | Sycophancy persists, possibly regressed in newest models | receiving-code-review skill | 2026-07-02 | failure-modes §1.5 |
| A10 | Over-engineering / unrequested scope is a measured failure mode of this generation | Scope essence in AGENTS.md | 2026-07-02 | failure-modes §2 |
| A11 | Long sessions degrade; compaction can silently drop in-context constraints | Context-hygiene essence; agent-handover skill; spec implementation-guidance tails | 2026-07-02 | failure-modes §2 |
| A12 | Max reasoning effort backfires (high beats max); effort should match the task | Effort rules in model-selection; model-choice essence | 2026-07-02 | failure-modes §3 |
| A13 | Per-model fit: Opus = planning/debugging/multi-file; GPT-5.5 = terminal/single-file; Composer = rote edits w/ scope bleed; GLM 5.2 degrades >64k context | model-selection roster table | 2026-07-02 | failure-modes §3 (blog-grade evidence) |
