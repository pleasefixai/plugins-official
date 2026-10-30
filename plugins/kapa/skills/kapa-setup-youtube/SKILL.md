---
name: kapa-setup-youtube
description: Set up a Kapa YouTube source so a channel's video transcripts are ingested. Use when the user wants Kapa to answer from their YouTube videos.
---

# Set up YouTube

## 1. Get the channel id, which is the fiddly part

`channel_id` is the raw id starting `UC`, **not a URL and not an @handle**.
There is no lookup, so a handle will simply find nothing.

If the user has a `youtube.com/channel/UC...` URL, take the `UC...` segment. If
they only have an `@handle`, tell them to open the channel and find the id in
the page source, since only the channel owner sees it directly.

## 2. Create the source

`create_youtube_source` with `project` and `name`. Keep the returned id.

## 3. Check the channel and list its playlists

`get_youtube_channel` with `channel_id` confirms the id resolves, and answers
with the channel title. Read that back to the user: it is the only way to
catch a `UC` id that is valid but not theirs.

A 404 means the id is wrong. There is no way to search by name, so ask the
user to re-copy it.

`list_youtube_playlists` then shows the real playlists to choose from.

## 4. Configure it

`set_youtube_config` with `source_youtube` and `channel_id`.

Ask whether to restrict to specific `playlists`, which matters when a channel
mixes tutorials with marketing or conference recordings. Leaving it out
ingests every video on the channel.

## What gets ingested

Transcripts only. A video with no captions contributes nothing and is skipped
silently, so a channel of caption-less videos produces an empty source with no
error. Say this to the user before setting it up.

## Finish the job

Saving the configuration starts ingestion. There is no separate publish step,
so once the config saves the source is live.

Then call `list_sources` with `project_id` to confirm what the project holds.
