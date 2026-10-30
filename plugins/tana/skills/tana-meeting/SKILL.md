---
name: tana-meeting
description: "Find and fully read a Tana meeting: the transcript, every screen-share screenshot, attendees, attached docs and outcomes. Use whenever the user mentions a meeting, call, sync, standup, 1:1, demo, interview, workshop or customer call ('yesterday's design sync', 'my call with Acme', 'the meeting on Tuesday', 'what did we look at in the review?'), pastes a Tana link (home.tana.inc, meet.tana.inc or a tana: URI), or another Tana skill says to locate and read a meeting. Also the reference for how writes to Tana work: every change becomes a proposal the user approves in Tana."
---

# Read a Tana meeting

A Tana meeting is more than a transcript. Tana joins the call, transcribes it, and captures
**screenshots of whatever was shared on screen** (never camera video, never faces). Those
screenshots are the only record of what people were actually looking at: the bug, the Figma
sketch, the spreadsheet, the slide. People say "this", "here", "move that up", and the
screenshot is what "this" was. **Read the screenshots every time, before you answer.**

## What a meeting holds

| Part | Tool | Use it for |
| --- | --- | --- |
| Event | `readEvent` | title, time, `attendees` (invited), `participants` (joined), `organizer`, `description` (the invite text, often the agenda), and the URIs below |
| Screen-share screenshots | `readScreenShareScreenshots`, `readScreenshotImages` | what was on screen, and when: designs, bugs, numbers, slides, code |
| Transcript | `readFullTranscript` | who said what, when: decisions, commitments, objections |
| Summary | `readItems` on `summaryUri` | Tana's wrap-up: decisions and action items |
| Attached docs | `readItems` on `relatedDocs` and `pinnedItems` | docs Tana drafted during the meeting from its live suggestions (recaps, storyboards, slides, notes), and docs people pinned |
| Agenda | `readItems` on `agendaUri` | the shared agenda, if someone wrote one |

## Step 1: find the meeting

**A pasted link wins. Read exactly that item, don't search.**
- `https://meet.tana.inc/<code>` or a bare code like `xhq-dckf-dxx`: pass it verbatim, `readEvent({ eventUri: "xhq-dckf-dxx" })`.
- `https://home.tana.inc/...`: find the `tana%3Aevent%3A<id>` segment, URL-decode it to `tana:event:<id>`, then `readEvent`. Other kinds in the URL: `tana:text:` goes to `readItems`, `tana:call:` or `tana:transcript:` to `readFullTranscript`, anything else to `getItemInfo({ ids: [...] })`.
- A raw `tana:...` URI: same routing.

**By date:** `listEvents({ startDate: "2026-09-29", endDate: "2026-09-29", timezone: "Europe/Oslo" })`.
Resolve "yesterday" or "last Tuesday" yourself. Use the user's IANA timezone (ask once if you don't know it).
Add `query` to filter by title. Each row's time field says whether it already happened.

**By title, topic or person:**
```json
{ "queries": ["design sync"],
  "targets": [{ "target": "event", "eventStartTimeMax": "2026-09-30T18:00:00", "eventTimeZone": "Europe/Oslo" }],
  "sortOptions": [{ "field": "startTime", "direction": "desc" }] }
```
That is `searchItems`. Event `queries` also match attendee names and emails ("acme.com", "Anna").
For teammates you can filter with `hasParticipantUris` (user-profile URIs from `listOrgMembers`).
- "Last" or "previous" meeting: only `eventStartTimeMax` = now, query `"*"`, most recent comes first.
- "Next" or "upcoming": only `eventStartTimeMin` = now, query `"*"`, soonest comes first.
- Start-time bounds are local wall times with no UTC offset, plus `eventTimeZone`.

**Recurring meetings:** `readEvent` returns `previousInstance` and `nextInstance`; `listEvents({ recurrenceId, ... })` lists the series.

**Several matches?** Pick the likeliest by date and people, and say which in one line
("Using Design sync, Tue 29 Sep, with Mads and Hilde."). Ask only when it is genuinely a coin flip.

## Step 2: read the event

`readEvent({ eventUri })`. Keep `callUri`, `summaryUri`, `agendaUri`, `relatedDocs`, `pinnedItems`.
Companion URIs (`callUri`, `transcriptUri`, `agendaUri`) come back even when that document does not
exist. A meeting with no `participants` and no transcript never happened as a Tana call.

## Step 3: read the screen-share screenshots (always)

1. `readScreenShareScreenshots({ id: callUri })`. Pass the **call** URI (`tana:call:<same id as the event>`), not the event URI.
   You get every unique frame in order: `cid`, `capturedAtSec`, `visibleUntilSec`, `title`, `summary`, `details`.
2. Read every `details`. Build a timeline of what was on screen:
   `03:10–07:45 Figma: checkout page v2 · 07:45–12:00 Sentry: "TypeError: total is undefined"`.
3. Look at the pixels with `readScreenshotImages({ id: callUri, cids: [...] })` (up to 10 cids per call)
   whenever the image is the substance: a sketch or mockup, a UI to build or fix, an error or stack
   trace, numbers in a chart or sheet, a diagram, anything the user will act on.
4. No frames? Say "nothing was shared on screen in this meeting". That is a fact, not a failure.

`readEvent`'s own `screenshots` field is only a few wrap-up picks. Always use the full list.

## Step 4: read the transcript against the screen

`readFullTranscript({ id: callUri })` (an event URI works too). Lines look like `[2646s] Anna: text`.
For long meetings, read windows with `startSec` / `endSec`.

**Pair the two.** A frame is on screen from `capturedAtSec` until `visibleUntilSec`; the transcript
lines in that window are what people said about it. Resolve every "this", "that button", "the red
one", "move it here" against the frame that was visible at that second. Cite moments as mm:ss
(2646s is 44:06).

## Step 5: read outcomes and attached docs

- `readItems({ ids: [summaryUri, ...relatedDocs, ...pinnedItems], task: "<what you need from them>" })`.
- `agendaUri`: `readItems` too; it may not exist.

## Linking back

`getShareLink({ ids: [eventUri, docUri] })` returns https:// links that open in Tana for members of the
workspace. Use them whenever you cite a meeting or doc outside Tana (code comments, Slack, chat apps).

## Writing to Tana: every write is a proposal

Every write tool (`createItems`, `updateItems`, `createEvent`, `updateEvent`, `createArtifact`,
`deleteItems`, ...) creates a **proposal**. The user reviews and approves it in Tana; nothing changes until
they do. That is the contract: you never change Tana silently.

- Always pass `recap`: 1–2 sentences to the user about what you propose and why. It opens the proposal in Tana.
- Leave `autoApprove` unset and never call `approveProposals` on your own. Do either only when the user
  explicitly tells you, in this conversation, to apply the change without review.
- After a write, say in one line: "Proposed in Tana: <what>. Open it in Tana to approve."
  `listProposals({ sessionUri })` shows what is pending (the write result returns `sessionUri`).
- One exception: `pinItem` applies immediately (it only adds a doc to a meeting page). Say what you pin.

## Rules

- Screenshots before answers. Never describe what was reviewed, designed or debugged from the transcript alone.
- Quote, don't invent. If what was said and what was shown disagree, say so.
- `attendees` were invited; `participants` actually joined.
- Answer the question. Don't paste the transcript back.
