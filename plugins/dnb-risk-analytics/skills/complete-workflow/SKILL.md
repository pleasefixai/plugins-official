---
name: complete-workflow
description: Completes, closes, or finishes a pending workflow or evaluation for an entity in the portfolio. Use when the user asks to complete, close, or finish a workflow, evaluation, or screening.
---

# Complete Workflow

## Trigger Examples

- Complete workflow for Apple Inc.
- Please close my evaluation for Apple Inc.
- Finish the workflow for Apple Inc.

## Workflow

1. Resolve the entity first.
- If the user gave a DUNS, use it directly.
- If the user gave only a company name, use `RASearchTool` to resolve the company and obtain the DUNS.

2. If multiple company matches are found:
- Show the matching entities in a short table.
- Ask the user to choose the correct entity or provide the DUNS.

3. Check whether the correctly identified entity is present in the portfolio.
- After the company has been resolved by `RASearchTool`, use `RAPortfolioTool` to retrieve the portfolio record for the resolved DUNS.
- If portfolio records are returned, treat the selected company portfolio record as the first source of truth.
- If no portfolio record is found, notify the user that the company is not present in the portfolio.

4. Call `RAListScreeningsTool` to retrieve the list of workflows for the portfolio record.
- If you find a workflow with a workflow status = Pending, retrieve the `kaseIterationId` from it.
- If you don't find a workflow with a workflow status = Pending, notify the user that no pending workflows were found.

5. Use `kaseIterationId` from the `RAListScreeningsTool` and pass it to the `RACompleteEvaluationTool` tool.
- If `RACompleteEvaluationTool` returns a successful response, proceed to Step 6 to verify the completion.
- If any error is returned, retry up to a maximum of 3 tries. If an error is still returned, notify the user that you encountered an error and are unable to complete the workflow.

6. Verify the workflow was actually completed by calling `RAListScreeningsTool` again for the same DUNS.
- Check whether the workflow with the same `kaseIterationId` still has status = Pending.
- If it is no longer Pending: completion is confirmed. Notify the user that the workflow was successfully completed.
- If it is still Pending: the completion did not take effect despite the successful response. Notify the user that the 200 response was received but the workflow status did not update, and advise them to retry or complete the evaluation manually in the portal.

## Progress Display

Before executing each step, reprint the full stepper block below with the correct icon for each step:
- ✅ = completed
- ⏳ = in progress (current step)
- ⬜ = not yet started
- ❌ = failed / stopped

Also include the entity name as a subtitle above the stepper, e.g.: `> Completing workflow for **Apple Inc.**`

```
⬜ Step 1: Resolving Entity
⬜ Step 2: Retrieving Portfolio Record
⬜ Step 3: Fetching Workflows
⬜ Step 4: Completing Pending Workflow
⬜ Step 5: Verifying Completion
⬜ Step 6: Done
```

Reprint the full stepper at every step transition so the user can track progress. Use ❌ on any step that fails and stop further steps.

## Analysis Rules

- Only retrieve the `kaseIterationId` from `RAListScreeningsTool` if the workflow status = Pending.
- Do not use other tools unless the user explicitly asks for it.

## Missing Data Rules

- If `kaseIterationId` is missing, explicitly state: `Not Available`.
- Do not infer missing values.