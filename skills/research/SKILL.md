---
name: research
description: Use when asked to map out or document in depth how a codebase, system, or feature currently works before planning or implementation
---

# Research

Research is a deep-read workflow for understanding current behavior before planning or implementation.

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
