---
name: schedule-meeting
description: "Set up a meeting in Tana and the user's calendar: check the user's calendar for a free slot, then create the event with the right people, time and an agenda. Use when the user says 'set up a meeting with Anna and Mads on Thursday about pricing', 'book 30 minutes with the Acme team next week', 'schedule a follow-up to today's design review', 'find time for a 1:1 with Hilde', or 'put a call with lena@acme.com on my calendar'."
---

# Schedule a meeting

Turn "set up a meeting with X and Y about Z" into a real calendar event with the right people, a
sensible time and an agenda, so the meeting starts with context instead of "so, why are we here?".

## Steps

1. **Parse the ask:** who, when (a day or a window), how long (default 30 minutes), what about.

2. **Resolve the people.**
   - Teammates: `listOrgMembers` gives user-profile URIs. They go in `participants` as `{ "uri": "tana:user-profile:..." }`
     and get access to the meeting's notes in Tana. Never list the user themselves; they are the organizer.
   - External people: only email addresses the user gave you go in `attendeeEmails`. Never guess or
     complete an address. If the user only gave a name, look for it in a past meeting's `attendees`
     (`readEvent`), and confirm the address with the user before using it.

3. **Check the user's calendar.**
   - `listCalendars`: the calendar with `isDefaultWriteTarget: true` is where the event goes. If none is
     marked, or `connectionAccess` is `"read-only"`, the event stays in Tana and no invites go out. Tell
     the user before you create it.
   - `listEvents({ startDate, endDate, timezone })` over the window to find free slots. You can see only
     the user's own calendar, not other people's availability; say so when you propose a time.

4. **Build the agenda.** From the topic, in 2–5 lines. For a follow-up ("follow-up to today's design
   review"), read that meeting with the `tana-meeting` skill, including its screen-share screenshots,
   and build the agenda from what is still open and what was shown ("revisit the checkout sketch from
   12:10"). Link the earlier meeting with `getShareLink`.

5. **Confirm in 2–3 lines** and wait for an OK: title, day and time with timezone, people, agenda.

6. **Create it:**
   ```json
   { "title": "Pricing: annual plans",
     "startTime": "2026-10-01T14:00:00",
     "endTime": "2026-10-01T14:30:00",
     "timezone": "Europe/Oslo",
     "description": "Agenda\n- Annual discount: 15% or 20%?\n- Who owns the pricing page change\nContext: Pricing sync 22 Sep <link>",
     "participants": [{ "uri": "tana:user-profile:..." }],
     "attendeeEmails": ["lena@acme.com"],
     "recap": "A 30-minute pricing meeting with Anna and Mads on Thursday, agenda included." }
   ```
   (`createEvent`). This lands as a proposal in Tana for the user to approve. Approving it creates the
   event and may send real calendar invitations.

7. **Report** in one or two lines, and pass on anything the result says about a missing calendar
   connection or default calendar, including the step it points to.

## Output

```
Proposed in Tana: "Pricing: annual plans", Thu 1 Oct 14:00–14:30 (Oslo) with Anna, Mads and
lena@acme.com, agenda included. Approve it in Tana to add it to your Google Calendar and send invites.
```

## Rules

- Times are local wall times without a UTC offset (`2026-10-01T14:00:00`) plus `timezone` (an IANA
  name like `Europe/Oslo`). Never compute offsets or Unix timestamps. If the tool asks a
  daylight-saving question, ask the user and wait.
- Always set `endTime`; otherwise the external copy defaults to 30 minutes.
- No all-day events: this tool only makes timed ones. Ask for a time.
- No start time given and no window to search? Ask; don't guess.
- To move or change a meeting that already exists, use `updateEvent` with `eventUri`, `startTime`,
  `endTime` and `inputTimezone`; to add external invitees, use `addAttendeeEmails`.
