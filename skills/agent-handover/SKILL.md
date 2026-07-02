---
name: agent-handover
description: Use when a session should end and another agent should continue — context degraded, usage limit near, or the work is moving to a different harness or model
---

# Agent Handover

Prepare a compact handoff so the next agent starts cleanly without the full conversation history.

## Use When

- Context pressure is high or the session has degraded — long sessions rot, and compaction can
  silently drop constraints.
- A usage limit is near and the work should continue on a different harness or model
  (Claude Code ↔ Codex ↔ Cursor).
- Important state exists only in chat, and the next agent shouldn't have to rebuild it.

## Workflow

1. Identify the source-of-truth artifacts: specs, plans, research notes, the diff itself.
2. Separate persisted state from conversation-only state.
3. **Persist what's missing first.** The best handoff is a repo where everything important is
   already in files (spec, decision log, `docs/research/`); the prompt should mostly point.
4. Decide the narrowest useful next objective for the new agent.
5. Write the handoff prompt.

## Handoff Prompt Shape

```md
Continue this work from the current repository state.

Objective: <what the next agent accomplishes now>
Current state: <done / remaining>
Source of truth: <files to trust first>
Next step: <first concrete action>
Constraints and risks: <working agreements that must hold — TDD on/off, isolation,
  verify commands, scope; known traps and failed approaches>
Unpersisted context: <facts or decisions that exist only in this conversation>
```

## Quality Bar

- Make the next agent's first step obvious.
- Compress the session, don't narrate it. Prefer repository artifacts over chat summary.
- Name unresolved decisions, blockers, and tentative conclusions as such.
- Carry the working agreements explicitly — the next harness or model won't infer them from a
  clean repo.

## Common Mistakes

- Dumping a transcript instead of compressing it.
- Omitting the first concrete next step.
- Treating the handoff as a backlog of future ideas instead of the minimum context needed to
  continue correctly.
