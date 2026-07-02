---
name: research
description: Use when you need to map how a codebase, system, or feature currently works before planning or implementing against it — or when asked to document current behavior in depth
---

# Research

Research is a deep-read workflow for understanding current behavior before planning or implementation.

Before starting research, check `docs/research/` for documents about the topic or closely related topics. If any exist, defer the research workflow: read them first, summarize what they cover and their dates for the user, then offer to (1) stop researching and answer the user's questions from the existing documents, (2) verify the documents against the current code and update them if necessary, or (3) proceed with the full research workflow.

## Requirements

- Clarify the scope if the request is ambiguous.
- Read every relevant file, not just entry points.
- Trace data flow end-to-end.
- Read callsites, not just definitions.
- Capture conventions, hidden coupling, surprising behavior, risks, and any bugs found.
- If the goal is bug hunting, keep reading until all likely bugs in scope are documented.

## Artifact

- Write the findings to `docs/research/YYYY-MM-DD-<topic>.md`.
- Treat the document as the review surface, not the chat summary.
- Include scope, key findings, how the system works, important files, conventions, risks, bugs if relevant, and open questions.

## Handoff

- Share the document path when the research write-up is ready.
- Ask the user to review the document before planning.
