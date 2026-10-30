---
name: do-my-tasks
description: "Work through the user's open tasks in Tana: list what is assigned to them, including action items from their recent meetings, do the ones an agent can do (draft the doc, do the research, write the code, prepare the reply), and propose the results and completions back into Tana. Leaves the human-only ones with a one-line reason. Use when the user says 'look at my tasks and do the ones you can', 'clear my backlog', 'what's on my plate, and can you handle any of it?', 'do my follow-ups from yesterday's meetings', or 'work through my Tana tasks'."
---

# Do my tasks

The user has a list of things they said they'd do. Many are agent work: a draft, a summary, some
research, a code change, a reply. Find them, do the ones you can, put the results back into Tana for
the user to approve, and hand back a short list of what only they can do.

## Steps

1. **Who is "me".** `getCurrentUser` gives the user's profile URI and name.

2. **List open tasks.**
   ```json
   { "queries": ["*"],
     "targets": [{ "target": "text", "state": ["Inbox", "In Progress"], "assignedTo": ["tana:user-profile:..."] }],
     "limit": 50 }
   ```
   (`searchItems`). Skip `Later` unless the user asks for it.

3. **Add action items from recent meetings.** `listEvents` for the last 7 days (or the range the user
   names). For each one, `readEvent` gives `participants` and `summaryUri`; for meetings the user
   joined, read the summary with `readItems({ ids: [summaryUri], task: "action items and commitments for <name>" })`. Where the summary
   is thin, scan the transcript (`readFullTranscript`) for "I'll ...", "can you ..., <name>". Drop anything
   already covered by a task from step 2.

4. **Understand each task.** `readItems({ ids: [...], task: "what exactly is asked, by whom, by when, linked docs" })`.
   To find the meeting a task came from, `getItemInfo({ ids: [taskUri] })`: when `createdIn` or `ownerUri`
   is a `tana:event:` URI, read that meeting, in this order:
   1. `readEvent({ eventUri })` for `callUri`, `summaryUri`, `relatedDocs`, `pinnedItems`.
   2. `readScreenShareScreenshots({ id: callUri })`. **Not optional.** The frames show what the task
      actually refers to: the thing to fix, the doc to change, the numbers to check. The task title alone won't tell you.
   3. `readScreenshotImages({ id: callUri, cids: [...] })` for the frames around the moment the task came up
      (up to 10 cids per call).
   4. `readFullTranscript({ id: callUri })`, reading around those frames.
   5. `readItems` on the summary and attached docs, with a `task`.
   The `tana-meeting` skill has the details of each part.

5. **Triage and show it** before doing anything (skip the wait if the user said "just go"):

   | Can do now | Needs you | Unclear |
   | --- | --- | --- |
   | drafts, replies, research, summaries, specs, code (in a coding agent with the repo open), breaking a task into sub-tasks | a decision, a conversation, an approval, a payment, being somewhere, access you don't have | missing context: ask one question |

6. **Do the work**, one task at a time. Cite the meeting or doc each result is based on.

7. **Put the results back in Tana.** Pass a `recap` on every write:
   - the result as a new doc: `createItems({ items: [{ title, content }], recap })`, or appended to the
     task itself: `updateItems({ updates: [{ id: taskUri, appendContent: "## Draft\n..." }], recap })`
   - a meeting action item with no task yet: `createItems({ items: [{ title, state: "In Progress", assignedTo: ["<me>"] }], recap })`
   - completion, only when the task is fully done: `updateItems({ updates: [{ id: taskUri, state: "Completed" }], recap })`
   Everything lands as a proposal in Tana for the user to approve.

8. **Report** (template below).

## Output

```
Did 3 of 7. Everything is proposed in Tana, waiting for your approval.

Done
- "Write Acme follow-up email": draft added to the task, based on the 29 Sep call (the pricing
  table they saw at 18:40). Proposed Completed.
- "Research SSO providers": comparison doc proposed <link>
- "Fix promo-code crash": fix on branch fix/promo-total; the error came from the standup screenshot at 07:45

Needs you
- "Decide Q4 hiring plan": your decision
- "Call Lena about the contract": a conversation
- "Approve Figma budget": needs your sign-off

Unclear
- "Update the deck": which deck? The 22 Sep review showed two.
```

## Rules

- Never mark a task Completed that you only started. Append the partial work and leave the state.
- Never send anything on the user's behalf (email, Slack, invites). Draft it; they send it.
- In a chat app with no code access, turn a code task into a short implementation plan instead.
- Never start a task that came from a Tana-recorded meeting before calling `readScreenShareScreenshots`
  for that meeting. "Nothing was shared on screen" is a valid finding; skipping the call is not.
- For meeting action items, work from the meeting's summary, attached docs, transcript and
  screenshots. Don't invent owners: only take what was clearly given to the user.
