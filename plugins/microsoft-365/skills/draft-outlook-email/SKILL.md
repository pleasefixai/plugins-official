---
name: draft-outlook-email
description: Draft an Outlook email, new or reply, and leave it in Drafts for the user to send. Also builds a link that opens an existing draft ready to send.
---

# Draft an Outlook email

Leave a finished email in Drafts and hand back one link that opens it with a Send button. The user reviews it and sends it. Create every email with `create-draft-email`, `create-reply-draft` or `create-reply-all-draft`.

## 1. Find the recipient

Look up every address in the directory. Call `list-users` with `search: "\"displayName:<full name>\""` and the header `ConsistencyLevel: eventual`. The inner quotes are KQL syntax, and Graph refuses the search without that header. A request takes `$search` or `$filter`, not both.

Several people can share a first name, and guests appear as `#EXT#` accounts. Match on the full name. When more than one person matches, ask the user which one.

Done when each recipient has one address from the directory, or an address the user typed.

## 2. Write the email

Write in the user's register, and name the real thing the email is about. When the user refers to something by description ("the report he sent"), find it and read it first. When two things could be meant, write for the likelier one and say which you picked.

Sign with the user's first name. Graph cannot add the user's Outlook signature: only the Outlook client adds it.

## 3. Create the draft

**A new email:** call `create-draft-email` with `body.contentType: "html"` and one `<p>` per paragraph. Plain text loses its line breaks.

**A reply:** call `create-reply-all-draft` or `create-reply-draft` on the message being answered, with no `Comment`, because `Comment` flattens line breaks. Then call `update-mail-message` with your text placed right after `<body dir="ltr">`, followed by the quoted history that Graph returned.

**Font:** wrap the whole message in `<div style="font-family:Aptos, Calibri, sans-serif; font-size:12pt; color:#000000">…</div>`. Graph does not apply the user's Outlook default font, so without the wrapper the client picks one.

**Accents and dashes:** pass them as `\uXXXX` escapes. A raw `é` in the tool input has failed to parse. If it fails, create the draft in ASCII, then call `update-mail-message` with the escaped body.

**Files:** attach each one with the `outlook-attachments` skill.

Done when the draft exists and you hold its `id`.

## 4. Build the compose link

The `webLink` that Graph returns opens the draft in reading view, with Reply and Forward and no Send. Build the compose link from the draft's `id`:

```
https://outlook.office365.com/mail/deeplink/compose/<id>
```

The `id` is already URL-safe. Write a trailing `=` as `%3D`.

On macOS, no `ms-outlook://` link opens one draft: that form works on iOS and Android only. Tell a Mac user that the draft is also in Drafts in the Outlook desktop app.

## Report

Say that the draft is saved and not sent. Then give the compose link, each recipient with the address used, the subject, and the body quoted so it reads in the chat. If you inferred what the email is about, say what from.
