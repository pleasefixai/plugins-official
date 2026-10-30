---
name: kapa-check
description: Check what a Kapa project holds and whether it answers questions. Use when the user wants to see their sources and ingestion status, or diagnose thin or wrong answers.
---

# Check a Kapa project

1. Call `list_sources` for the project and show what it holds and where each
   source has got to.
2. Ask the user for a question their content should answer, call
   `search_project_knowledge` with it, and show what comes back.
3. If the answer is thin or wrong, say what would cause that rather than
   declaring success.
