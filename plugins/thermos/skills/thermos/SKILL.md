---
name: thermos
description: "Run both thermo-nuclear review passes, then synthesize their findings. Use for thermos, double thermo review, or combined bug/security and code-quality branch audits."
disable-model-invocation: true
---

# Thermos

Run the two thermo review passes one after the other, then synthesize their results.

## Workflow

1. Determine the review scope from the user request, PR, current branch, or relevant changed files.
2. Gather the diff (`git diff <base>...HEAD`, default base `main`) and any file/context excerpts needed to evaluate the change without guessing, including the full contents of changed files.
3. Run the bugs-and-security pass first, with fresh eyes, against only the changed code:
   - Follow the `thermos:thermo-nuclear-review` skill exactly. If that skill is not available, still act as a security- and correctness-focused diff-scoped reviewer with the same rigor: bugs, breakages, security, devex regressions, feature-flag leaks, and other branch-audit risks. Trace cross-package side effects; do not report pre-existing issues in untouched code; never present issues with unfinished research when you can verify in-repo.
   - After the audit, if there is a PR for this branch and you have medium-or-higher findings, use `gh` or `glab` to read the PR/MR discussion. Validate, dedupe, and attribute sourced items.
4. Run the code-quality pass on the same scoped diff/file context:
   - Follow the `thermos:thermo-nuclear-code-quality-review` skill as the complete rubric. If that skill is not available, fall back to a harsh maintainability audit aligned with its intent: maintainability, structure, file-size growth past ~1k lines, spaghetti and ad-hoc branching growth, abstractions, explicit types and boundaries, canonical layers, and codebase-health risks.
5. Keep each pass's findings prioritized, with file references and evidence.
6. After both passes, synthesize the results with findings first, deduplicated across the two passes. Weight overlapping findings more heavily, resolve disagreements with your own judgment, and keep summaries brief.

If the individual pass results are already visible to the user, do not restate them wholesale. Surface the unified verdict, the highest-signal findings, and any remaining uncertainty.
