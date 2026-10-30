---
name: kapa-setup-discourse
description: Set up a Kapa Discourse source so a public forum is ingested. Use when the user wants Kapa to answer from their Discourse community forum.
---

# Set up Discourse

The simplest community source: a public forum needs no credential at all.

## 1. Create the source

`create_discourse_source` with `project` and `name`. Keep the returned id.

## 2. Check the forum and list what it holds

`validate_discourse_url` with `url` confirms the forum is reachable
anonymously. A failure means it is login-walled, and there is no credential
here to fix that.

`list_discourse_categories` and `list_discourse_tags` then show the real
options to offer the user. An empty tag list means the forum has tagging
turned off, so filter by category instead.

## 3. Configure it

`set_discourse_config` with `source_discourse` and `url`, the base URL of the
forum, such as `https://forum.acme.com`.

Ask which parts of the forum to read. `match_categories` and `match_tags`
take what the user picks, and leaving both out reads every topic. Use
`list_discourse_categories` and `list_discourse_tags` to show them the real
options.

Pass categories by **name or slug**, never by numeric id. An id matches
nothing, and ingestion then drops the category filter and reads the whole
forum.

## Getting good answers out of it

Forum threads contain wrong answers as well as right ones, so ask the user
how to handle that:

- `include_solved_only`: keep only topics with an accepted answer, or take
  every topic. Check first whether their forum marks solutions at all, since
  this filter leaves nothing on a forum that does not.

## When it ingests nothing

The forum is not public, or `include_solved_only` is on for a forum that does
not mark accepted answers.

## Finish the job

Saving the configuration starts ingestion. There is no separate publish step,
so once the config saves the source is live.

Then call `list_sources` with `project_id` to confirm what the project holds.
