---
name: create-from-meeting
description: "Turn a Tana meeting into something new: a 'here's what we agreed' recap for a client, a brief, a slides outline, a storyboard, a Slack or email recap, a proposal, a follow-up email, a video script, an FAQ, a training guide, anything. Built from what was said (the transcript) and what was shown (screen-share screenshots of the sketches, designs, slides and spreadsheets people looked at). Use when the user says 'write up the design review for the client', 'recap yesterday's call for Slack', 'turn the workshop into slides', 'draft a proposal from my call with Acme', 'storyboard the demo', 'send them what we agreed', or 'make something from this meeting'."
---

# Create from a meeting

Any meeting can become a deliverable. Take a design consultant who walked a customer through
sketches: the screenshots are the sketches, and the transcript is the customer saying "move this
up, make that bigger, drop the sidebar". Put the two together and you get "here's what we agreed",
sketch by sketch, ready to send. **The screenshots are the source for what was reviewed. The
transcript is the source for what was said about it.**

## Steps

1. **Read the meeting.** Locate it (see the `tana-meeting` skill), then, in this order:
   1. `readEvent({ eventUri })` for `callUri`, `summaryUri`, `relatedDocs`, `pinnedItems`.
   2. `readScreenShareScreenshots({ id: callUri })`. **Not optional.** The frames are the sketches,
      designs and slides the deliverable is about.
   3. `readScreenshotImages({ id: callUri, cids: [...] })` for the frames that carry the substance
      (up to 10 cids per call).
   4. `readFullTranscript({ id: callUri })`, reading around the frames that mattered.
   5. `readItems` on the summary and attached docs, with a `task`.
   The `tana-meeting` skill has the details of each part.

2. **Pick the shape and the reader.** If the user named a format, use it. If not, ask one short
   question ("Slack recap, client email, or slides?"). A customer-facing piece drops internal
   chatter, prices not yet agreed, and anything said about the customer.

3. **Walk the screen, frame by frame.** For each frame that was discussed:
   - look at the pixels (step 1.3) for sketches, designs, slides and numbers
   - read the transcript for that frame's window (`capturedAtSec` to `visibleUntilSec`)
   - write what was agreed about that frame, in plain words, and who asked for it
   Frames nobody talked about are usually scrolling; leave them out.

4. **Draft it in the chat first.** Use the template for the format (below). Keep the sketch or slide
   next to the change it drives. Mark anything that was discussed but not decided.

5. **Offer to save it in Tana**, in one line. Two ways:
   - a doc: `createItems({ items: [{ title, content }], recap })`. Embed screenshots in `content`
     with `![what it shows](cid:<cid>)`, copying the full 64-character cid from
     `readScreenShareScreenshots`.
   - a visual artifact: `createArtifact({ artifactType, title, data, recap })`, where `artifactType`
     is `"slides"`, `"storyboard"` or `"customer-journey"`. First call
     `readSkill({ title: "Create storyboard artifact" })` (or `slides` / `customer journey`) to get that
     type's `data` schema. In a storyboard, put the real screen-share frames in the scenes'
     `screenshotIds`: what was actually on screen beats a generated illustration.
   Either one lands as a proposal in Tana for the user to approve. Once approved, offer to pin it to
   the meeting page: `pinItem({ target: "event", targetUri: eventUri, itemUris: [docUri] })`.

## Templates

**Here's what we agreed (design or product review)**
```
<Project>: what we agreed, <date>

1. Checkout page (sketch 1)
   ![Checkout sketch](cid:...)
   - Move the promo-code field above the total (Lena)
   - CTA becomes green, full width (agreed by all)
2. Order confirmation (sketch 2)
   - Keep as is
Still open: delivery-date picker, you'll send two options by Friday.
Next step: revised sketches Thursday 10:00.
```

**Slack recap**
```
*<Meeting>, <date>* (<link>)
Decided: ...
Shown: <the dashboard / demo / sketch>, key takeaway: ...
Owners: @Anna: ..., @Mads: ...
Open: ...
```

**Slides outline:** one slide per frame or topic: headline (the decision), the screenshot, two
supporting bullets from the transcript, speaker note with the quote.

Other shapes follow the same pattern: brief, proposal, follow-up email, video script, FAQ,
onboarding guide, bug report, customer-journey map, press note. Pick the frames that matter, pair
each with what was said, and write for the reader.

## Rules

- Never invent an agreement. "We discussed X" is not "we agreed X".
- Attribute requests and decisions to the person who made them.
- Numbers, names and on-screen text come from the screenshot, checked in the pixels.
- Never write before calling `readScreenShareScreenshots` for each Tana-recorded meeting you use.
  "Nothing was shared on screen" is a valid finding (then build from the transcript and attached
  docs); skipping the call is not.
- Keep it as long as the reader needs, not as long as the meeting was.
