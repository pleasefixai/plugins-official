---
name: implement-from-meeting
description: "Turn what was discussed in a Tana meeting into working code. Builds the spec from the transcript and the screen-share screenshots (the bug, UI, sketch or diagram shown on screen is often the real spec), lists decisions and constraints, confirms a short plan, then implements it in the codebase. Works for a bug fix, a feature or a whole new project. Use in coding agents (Claude Code, Codex, Cursor) when the user says 'implement what we talked about in the design sync', 'fix the bug we looked at in standup', 'build what we sketched with Anna', 'start the project we scoped on Monday', or pastes a Tana meeting link and asks for code."
---

# Implement from a meeting

Meetings are where specs get made, and most of the spec was on screen: the error someone shared,
the Figma frame everyone pointed at, the whiteboard sketch, the table of edge cases. The transcript
says what people decided about it. This skill turns both into a confirmed plan and then into code.

## Steps

1. **Read the meeting.** Locate it (see the `tana-meeting` skill), then, in this order:
   1. `readEvent({ eventUri })` for `callUri`, `summaryUri`, `relatedDocs`, `pinnedItems`.
   2. `readScreenShareScreenshots({ id: callUri })`. **Not optional.** The bug, UI or sketch on screen
      is often the real spec, and nobody reads it out in full.
   3. `readScreenshotImages({ id: callUri, cids: [...] })` for the frames that carry the substance
      (up to 10 cids per call).
   4. `readFullTranscript({ id: callUri })`, reading around the frames that mattered.
   5. `readItems` on the summary and attached docs, with a `task`.
   The `tana-meeting` skill has the details of each part.

2. **Mine the screenshots for the spec.** For every frame that shows something to build or fix,
   look at the pixels (step 1.3). Pull out exactly:
   - error messages, stack traces, log lines, URLs and routes
   - UI copy, labels, component and screen names, layout, spacing, colours, states
   - data: column names, example values, numbers, edge cases in a table
   - sketches and diagrams: boxes, arrows, what moves where
   Then read the transcript for that frame's window (`capturedAtSec` to `visibleUntilSec`) to learn
   what was decided about it. The frame gives the exact thing; the talk gives the intent.

3. **Read what the meeting pointed to.** Docs in `relatedDocs` or `pinnedItems`, and any doc, ticket
   or spec named out loud: `searchItems({ queries: ["checkout spec"] })`, then `readItems`.

4. **Write the spec in chat** (template below). Separate decided from merely discussed.

5. **Map it to the codebase.** Strings seen on screen are exact search keys: grep for the error text,
   the UI label, the route. Find the component, handler or module each item touches.

6. **Confirm the plan in a few lines** and wait for an OK: what you will change, where, what you will
   not touch, and any open question that blocks you. Skip the wait only if the user said "just do it".

7. **Implement.** Follow the repo's conventions and instructions files. For a bug, reproduce it first
   with the error from the screenshot; write the failing test, then fix. For UI, compare your result
   against the frame. Run the project's tests and checks.

8. **Report back** (template below). Offer, in one line, to record the result in Tana, for example a
   short "implemented" note appended to the meeting summary:
   `updateItems({ updates: [{ id: summaryUri, appendContent }], recap })`.
   That lands as a proposal in Tana for the user to approve.

## Spec template

```
Meeting: <title>, <date> · <link from getShareLink>
Goal: <one sentence>

What was shown
- [07:45] Sentry error "TypeError: total is undefined" on /checkout (frame: Sentry issue page)
- [12:10] Figma: promo-code field moved above the total, CTA green (frame: Checkout v2)

Decided
- Promo field goes above the total (Anna, 12:30)
- Fix the undefined total before the redesign ships (Mads, 09:05)

Constraints / out of scope
- No backend changes this round (Hilde, 15:20)
- "Maybe later": saved payment methods (not in this change)

Open questions
- Should the CTA colour follow the theme token or be hard-coded green?

Done when
- /checkout with an empty cart shows 0, no error; promo field above total; tests green
```

## Report template

```
Implemented from <meeting>, <date>:
- <change> (<file>) covers "<decision>"
- <change> (<file>) fixes the error shown at 07:45
Not done: <item> (<why>)
Checks: <command> passed
```

## Kinds of work

- **Bug:** the screenshot usually holds the exact error and the screen it happened on. Start there.
- **Feature:** the design frame is the spec; the transcript gives priorities and what was cut.
- **New project:** scaffold only what was agreed. List the rest as follow-ups, don't build it.

## Rules

- Exact strings come from the screenshot, not from someone paraphrasing it out loud.
- Build what was decided. Ideas floated with "maybe", "later" or "what if" go under out of scope.
- When the meeting changed its mind, the later decision wins. Mention the reversal in the spec.
- If the screenshots contradict the transcript, stop and ask; don't guess.
- Never build before calling `readScreenShareScreenshots` for each Tana-recorded meeting you use.
  "Nothing was shared on screen" is a valid finding (then lean on the transcript and linked docs);
  skipping the call is not.
