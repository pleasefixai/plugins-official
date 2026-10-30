---
name: kapa-gaps
description: Show what people ask that a Kapa project cannot answer, and what they ask most. Use when the user wants to find coverage gaps or decide what content to write next.
---

# Find where a Kapa project falls short

1. Call `list_coverage_gaps_periods` for the project, then `get_coverage_gaps`
   with the most recent period id to see what people asked that the content
   does not cover.
2. Do the same with `list_top_questions_periods` and `get_top_questions` for
   what people ask most.
3. Summarise both and suggest what content would close the biggest gaps.
