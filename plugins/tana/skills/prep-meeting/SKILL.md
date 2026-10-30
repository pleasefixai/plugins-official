---
name: prep-meeting
description: "Prepare the user for an upcoming meeting: who is coming, what the invite says, what happened the last times with these people or on this topic (including what was shown on screen), open items and decisions, and 3–5 sharp questions to ask. Offers to attach the prep to the meeting in Tana. Use when the user says 'prep me for my 2 pm', 'what do I need to know before the Acme call?', 'brief me for tomorrow's 1:1 with Mads', 'get me ready for the design review', 'what's my next meeting about?', or 'prep my meetings today'."
---

# Prep a meeting

Walk in knowing what happened last time, what is still open, and what to ask. The best prep comes
from the last meetings with the same people: what they said, and what everyone looked at on screen
(the demo they saw, the proposal on the table, the numbers that worried them).

## Steps

1. **Find the meeting.**
   - "My 2 pm", "tomorrow's 1:1": `listEvents({ startDate, endDate, timezone })` for that day, then match by time or title.
   - "My next meeting": `searchItems` with `targets: [{ "target": "event", "eventStartTimeMin": "<now, local>", "eventTimeZone": "<tz>" }]` and query `"*"`.
   - A pasted link: read exactly that meeting (the `tana-meeting` skill shows how).
   - "Prep my meetings today": list the day and prep each one, shortest first.

2. **Read the upcoming event.** `readEvent({ eventUri })`: title, time, `description` (the invite often
   holds the agenda or a named doc), `attendees` with email domains (internal or external?), `organizer`,
   `pinnedItems`, `relatedDocs`. Read the agenda with `readItems({ ids: [agendaUri] })`; it may not exist.

3. **Find the previous meetings.**
   - Recurring meeting: follow `previousInstance` back one or two occurrences.
   - Otherwise search past events with the same people or topic, most recent first:
     ```json
     { "queries": ["acme.com", "Lena Berg", "onboarding"],
       "targets": [{ "target": "event", "eventStartTimeMax": "<now, local>", "eventTimeZone": "<tz>" }] }
     ```
   Take the 2–3 most relevant.

4. **Read each previous meeting fully.** For every past meeting you use, in this order:
   1. `readEvent({ eventUri })` for `callUri`, `summaryUri`, `relatedDocs`, `pinnedItems`.
   2. `readScreenShareScreenshots({ id: callUri })`. **Not optional.** The frames are the only record of
      what people were looking at: the roadmap, the sketch, the numbers, the bug. Note what was shown
      and when ("they saw the Q3 roadmap at 14:20 and pushed back on the October date").
   3. `readScreenshotImages({ id: callUri, cids: [...] })` for anything you will refer to: a price, a
      date, a design, a chart. Up to 10 cids per call.
   4. `readFullTranscript({ id: callUri })`, reading the lines around each frame that mattered.
   5. `readItems` on the summary and attached docs, with a `task`.
   The `tana-meeting` skill has the details of each part.

5. **Find what's still open.**
   - Tasks on the topic: `searchItems` with `targets: [{ "target": "text", "state": ["Inbox", "In Progress"] }]`
     and the topic or company as `queries`.
   - Related decisions and docs: `semanticSearchItems({ query: "<topic of the meeting>", limit: 10 })`, then
     `readItems` with a `task` for the few that matter.

6. **Write the prep** (template below). Keep it to one screen.

7. **Offer to attach it**, in one line. If the user agrees:
   - create the prep doc: `createItems({ items: [{ title: "Prep: <meeting>, <date>", content }], recap })`.
     This lands as a proposal in Tana for the user to approve.
   - once they have approved it, pin it to the meeting page so it's there when the meeting starts:
     `pinItem({ target: "event", targetUri: eventUri, itemUris: [docUri] })`. Pinning only works on an
     approved doc; if it is still pending, say so and pin after approval.

## Output

```
**Acme onboarding check-in · Thu 1 Oct, 14:00–14:30** · <link>
With: Lena Berg, Jonas Ek (Acme); Mads (us)
Why: follow-up on the pilot rollout (from the invite)

Last time (Tue 22 Sep) <link>
- They saw the admin dashboard demo; liked it, but Lena asked twice about SSO (at 12:40)
- On screen at 18:05: pilot timeline with go-live 15 Oct. Jonas: "tight but OK"
- We promised a security questionnaire by Friday

Open
- Security questionnaire: task assigned to Mads, In Progress <link>
- SSO: not on the roadmap yet

Ask
1. Is 15 Oct still the go-live date on their side?
2. Is SSO a blocker for the pilot, or for the full rollout?
3. Who signs off the security review at Acme?
```

## Rules

- Prep is for the user, not the attendees. Be frank about risks.
- Every claim about last time carries a date and, for meetings, a mm:ss.
- Never write the prep before calling `readScreenShareScreenshots` for each Tana-recorded past meeting.
  "Nothing was shared on screen" is a valid finding; skipping the call is not.
- If there is no earlier meeting with these people, say so and prep from the invite and docs.
- Questions must come from real open items, not generic ones.
