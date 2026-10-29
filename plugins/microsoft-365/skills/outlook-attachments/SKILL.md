---
name: outlook-attachments
description: Attach a file to an Outlook email, draft or reply. Says which tool carries a file of any size, and how to check that it arrived.
user-invocable: false
---

# Attach a file in Outlook

Attach every file through an upload session, whatever its size.

1. Create or find the draft, and note its message id.
2. Call `create-mail-attachment-upload-session` on that message, with `AttachmentItem` set to `attachmentType: "file"`, the file's `name` and its exact `size` in bytes.
3. Upload the file's raw bytes to the `uploadUrl` that the call returns, with any HTTP client the machine has. Send each piece as a `PUT` with `Content-Type: application/octet-stream` and `Content-Range: bytes <first>-<last>/<size>`, for example `bytes 0-1023/1024` for a whole 1,024-byte file. The URL carries its own authorization, so send no `Authorization` header. Send a file larger than 4 MB in pieces of at most 4 MB, in order.
4. List the message's attachments. Done when the file is in the list with the right size. Only then say that it is attached.

The tool's description says that the upload session refuses files under 3 MB. It does not: it takes a file of any size.

`add-mail-attachment` carries the file as base64 inside the tool call. The server refuses a request above about 100 KB, so that tool fails for any file above about 75 KB. The upload session sends only a few hundred bytes through the server.

When Outlook answers `ErrorMessageSizeExceeded`, the draft has reached the mailbox's message size limit, which counts every attachment on the draft. Tell the user, with the size of the files you tried to attach, and leave the draft as it is.
