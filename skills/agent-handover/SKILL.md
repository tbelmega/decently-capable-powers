---
name: agent-handover
description: Use when a session should end and another agent should continue: context degraded, usage limit near, or the work is moving to a different harness or model
---

# Agent Handover

Prepare a compact handoff so the next agent starts cleanly without the conversation history.

1. Identify the source-of-truth artifacts: specs, plans, research notes, the diff itself.
2. **Persist what's missing first.** The best handoff is a repo where everything important is
   already in files (spec, decision log, `docs/research/`); the prompt should mostly point.
3. Decide the narrowest useful next objective, then write the prompt:

```md
Continue this work from the current repository state.

Objective: <what the next agent accomplishes now>
Current state: <done / remaining>
Source of truth: <files to trust first>
Next step: <first concrete action>
Constraints and risks: <working agreements that must hold (checkout, verify commands, scope,
  review mechanism); known traps and failed approaches>
Unpersisted context: <facts or decisions that exist only in this conversation>
```

## Quality Bar

- Make the next agent's first step obvious.
- Compress the session, don't narrate it or dump a transcript; prefer repository artifacts over
  chat summary.
- Name unresolved decisions, blockers, and tentative conclusions as such.
- Carry the working agreements explicitly; the next harness or model won't infer them from a
  clean repo.
- Hand over the minimum context needed to continue correctly, not a backlog of future ideas.
