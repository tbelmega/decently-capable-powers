---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, and to brainstorm before building
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, ignore this skill.
</SUBAGENT-STOP>

This plugin adds a small, curated set of skills. They exist because they change what you do at
decision points models tend to get wrong — not to re-teach things you already know. The harness
handles planning, task tracking, subagents, worktrees, and code review natively; lean on those.

## The Rule

**Invoke a relevant skill BEFORE acting on the task it applies to** — including before
clarifying questions, exploring the codebase, or writing code. Announce "Using [skill] to
[purpose]" and follow it. If it has a checklist, create a todo per item. If the skill turns out
wrong for the situation, you don't have to use it.

**Before building anything** — a feature, component, or behavior change — invoke `brainstorming`
first, and before entering plan mode. This is the one gate native skill discovery won't enforce
for you: models default to jumping into code, and this stops that.

## The skills

- **brainstorming** — before any creative/build work: turn the idea into an approved spec first.
- **systematic-debugging** — any bug, test failure, or unexpected behavior: root cause before fixes.
- **test-driven-development** — implementing a feature or bugfix: failing test first.
- **verification-before-completion** — before claiming anything is done/fixed/passing: run it, show evidence.
- **receiving-code-review** — when given review feedback: verify it, push back when it's wrong.

Process skills come first (they set the approach), then implementation follows.

## Red Flags

These thoughts mean STOP — you're rationalizing your way out of a skill:

| Thought | Reality |
|---------|---------|
| "This is too simple to need it" | Simple things become complex. Simple is where unexamined assumptions bite. |
| "Let me explore/gather context first" | The skill tells you HOW. Check first. |
| "I remember this skill" | Read the current version. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |

## User Instructions

User instructions (CLAUDE.md, AGENTS.md, direct requests) take precedence over skills, which in
turn override default behavior. Only skip a skill when your human partner has told you to.
