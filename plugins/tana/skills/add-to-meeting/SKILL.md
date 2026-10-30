---
name: add-to-meeting
description: "Add something to a meeting in Tana so it is there when the meeting starts: a link, an agenda item, questions, a list of bugs, a doc, notes. Finds the right upcoming (or past) meeting and attaches the item to its agenda or meeting page. Use when the user says 'add this to my meeting with Anna', 'put these bugs on the agenda for Thursday's sync', 'attach the spec to tomorrow's design review', 'add this link to the Acme call', 'make sure we talk about X at standup', or 'add my notes to yesterday's meeting'."
---

# Add to a meeting

The user has something that belongs in a meeting: a link, a topic, a list of bugs, a doc. Put it on
the meeting so everyone sees it when the meeting opens, and tell the user where it went.

## Steps

1. **Find the meeting.** Follow step 1 of the `tana-meeting` skill. Default to the next upcoming
   occurrence: `searchItems` with `targets: [{ "target": "event", "eventStartTimeMin": "<now, local>", "eventTimeZone": "<tz>" }]`
   and the person's name, email or the meeting title in `queries`. A recurring meeting ("standup",
   "Thursday's sync") means the next occurrence unless the user says otherwise. State which meeting in
   one line: "Adding to Design review, Thu 1 Oct 10:00."

2. **Read it.** `readEvent({ eventUri })`: note `agendaUri`, `pinnedItems` and `relatedDocs`, so you
   don't add something that's already there. For a past meeting ("add my notes to yesterday's
   meeting"), also, in this order:
   1. `readScreenShareScreenshots({ id: callUri })`. **Not optional.** Notes on a past meeting should
      point at what was shown; embed a frame with `![what it shows](cid:<cid>)`.
   2. `readScreenshotImages({ id: callUri, cids: [...] })` for the frames you will refer to (up to 10 per call).
   3. `readFullTranscript({ id: callUri })` around those frames, if the notes need the words.
   The `tana-meeting` skill has the details of each part.

3. **Gather the item.** If it lives elsewhere (bugs in an issue tracker, a web page, a file in the repo),
   collect it with the tools you have and turn it into short text with links. If it is a Tana doc,
   get its URI (search for it with `searchItems`, or take it from a pasted link).

4. **Add it the right way:**

   | What | How |
   | --- | --- |
   | An existing Tana doc | `pinItem({ operation: "pin", target: "event", targetUri: eventUri, itemUris: [docUri] })`. Applies right away; it shows on the meeting page for everyone who can see the meeting. |
   | Agenda items, questions, links, a bug list | If the agenda exists (`readItems({ ids: [agendaUri] })` returns it): `updateItems({ updates: [{ id: agendaUri, appendContent: "- Promo-code bug on mobile: <link>" }], recap })`. |
   | Same, but the meeting has no agenda yet | `createItems({ items: [{ title: "Agenda: <meeting>, <date>", content }], recap })`, then pin it with `pinItem` once the user has approved it. |
   | Longer notes or a doc to bring | `createItems` with the content, then pin it after approval. |

   Writes with `updateItems` and `createItems` land as a proposal in Tana for the user to approve;
   `pinItem` does not need approval but only works on an approved doc.

5. **Report in one or two lines** (template below), including anything that still waits for approval.

## Output

```
Added to Design review, Thu 1 Oct 10:00 <link>:
- Pinned "Checkout spec v2" to the meeting page
- Proposed 3 agenda items (the mobile promo-code bugs). Approve them in Tana to add them.
```

## Examples

- "Add this Loom link to my call with Acme": find the next event whose attendees match Acme, append
  `- Demo recording: <url>` to the agenda.
- "Put the open checkout bugs on Thursday's sync": list them (`searchItems` text target with
  `"type": "Bug"` or your issue tracker), append one line per bug with its link.
- "Attach the pricing doc to tomorrow's review": search for the doc, pin it.

## Rules

- Prefer the agenda or a pinned doc over the invite text. On a Google or Outlook event,
  `updateEvent`'s `description` only changes Tana's copy, and the next calendar sync may overwrite it.
- Keep agenda lines short: one topic per line, with the owner and a link.
- If two meetings match, name both and ask which one.
- Never write notes on a past Tana-recorded meeting before calling `readScreenShareScreenshots` for it.
  "Nothing was shared on screen" is a valid finding; skipping the call is not.
