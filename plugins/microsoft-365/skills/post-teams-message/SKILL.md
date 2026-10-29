---
name: post-teams-message
description: Write a message for a Microsoft Teams chat, show it to the user as a draft, and post it with send-chat-message only after the user says to post it.
---

# Post a message in a Teams chat

Teams has no drafts. The draft is the message you show the user in this chat. Post it only when the user says to, in a message after the draft. A request to "draft" or "prepare" a message is not that: show the draft and stop.

## 1. Find the chat

Call `list-chats` with `$expand: "members"`. A group chat carries its name in `topic`. A one-to-one chat has no `topic`: match it on the other member's `displayName`. When more than one chat matches, ask the user which one.

Done when you hold one chat's `id` and its `webUrl`.

## 2. Write the draft

Read the last messages with `list-chat-messages` first, so the message fits the conversation. Write in the user's register, and name the real thing the message is about.

Show the user the chat's name and the message, quoted so it reads in the chat. Say that it is not posted.

## 3. Post it

When the user says to post it, call `send-chat-message` with the chat's `id` and the message as you showed it, or as the user changed it. To answer one message in its thread, call `reply-to-chat-message` instead.

Make every post with these two tools. `graph-batch` only reads, and the server refuses a post inside it.

**When `send-chat-message` is not there or is refused:** the user switched it off in Pleasefix. Say so. Give the message and the chat's `webUrl`, so the user can paste it in Teams. Do not look for another way to post.

## Report

Say that the message is posted, in which chat, and give the chat's `webUrl`.
