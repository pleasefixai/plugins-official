---
name: kapa-setup-s3
description: Set up a Kapa S3 source so files in a bucket are ingested. Use when the user wants Kapa to answer from documents stored in S3 or an S3-compatible bucket.
---

# Set up S3

Works with any S3-compatible provider, not just AWS.

## 1. Create the source

`create_s3_source` with `project` and `name`. Keep the returned id.

## 2. Configure it

`set_s3_config` with `source_s3`, `bucket_name`, `endpoint_url`,
`aws_access_key_id` and `aws_secret_access_key`.

- `endpoint_url` is **required even for plain AWS**, such as
  `https://s3.us-east-1.amazonaws.com`. Agents habitually omit it.
- `region_name` is needed by most providers. Use `us-east-1` when the provider
  has no regions.
- `prefix` limits the source to one folder, such as `docs`, with no leading or
  trailing slash. Leaving it out ingests the whole bucket.

Both keys are the user's secrets: ask for them, never invent them. Mention
that the credential only ever needs read access to that one bucket, so they
can scope it accordingly if they want to.

## 3. Check the bucket before saving

`validate_s3_config` with the bucket, endpoint and keys confirms Kapa can
reach it. It answers `{"is_valid": bool, "message": str}`.

**Show the message on a failure before blaming the keys.** It runs three
checks: the endpoint and bucket, the credential's permissions, and whether an
`index.json` in the bucket is well formed. A malformed `index.json` reads
identically to a bad credential unless the message is read. That file is
optional and maps objects to public URLs for citations.

## Finish the job

Saving the configuration starts ingestion. There is no separate publish step,
so once the config saves the source is live.

Then call `list_sources` with `project_id` to confirm what the project holds.
