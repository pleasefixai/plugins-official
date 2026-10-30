---
name: athenahq
description: Report how AI assistants (ChatGPT, Perplexity, Gemini, and others) talk about a brand using AthenaHQ analytics. Trigger for AI search visibility, share of voice, mention or citation rates, ranking position vs competitors, cited sources and pages, tracked prompts, and AI-response sentiment. Do not trigger for traditional SEO (Google organic rankings, keywords, backlinks). The MCP server also provides write tools gated by the connected user's AthenaHQ role.
---

# AthenaHQ: brand visibility in AI search

Use the AthenaHQ MCP tools to answer questions about how AI assistants
mention, cite, and rank a brand versus its competitors. The workflows below
cover the common analytics read path. The MCP server also provides tools that
create, edit, publish, or delete data and start response runs. For signed-in
connections, AthenaHQ gates each write by the user's role. See the
[MCP write tools documentation](https://docs.athenahq.ai/api-reference/mcp#write-tools)
for the complete list and required permissions.

## Always resolve the website first

1. Every tool except `list_websites`, `get_credits_organization`,
   `list_pitches`, and `get_pitch` requires a `website_id` (UUID).
2. Start with `list_websites` (empty arguments `{}`). One website: use it.
   Several: ask the user which one, or infer from the brand they named.
   When several websites share a name, check `baseCountry` on each item:
   they are often per-country editions of the same brand.
3. Before date-filtered queries, call `get_date_range` to learn the earliest
   and latest analyzed dates. Never query outside that range.

## Metric questions → tools

All metric tools take `website_id` plus a `filters` object.
`filters.start_date` (YYYY-MM-DD) is required; `end_date`, `models`,
`prompt_ids`, `competitor_ids`, `location_ids`, `persona_ids`,
`prompt_tags` are optional narrowing filters.

- "Share of voice" / "how visible are we vs competitors" →
  `get_share_of_voice_cumulative` (per-competitor totals for the range) or
  `get_share_of_voice_time_series` (daily trend).
- "How often are we mentioned" → `get_mention_rate_cumulative` /
  `get_mention_rate_time_series`.
- "How often are we cited/linked" → `get_citation_rate_cumulative` /
  `get_citation_rate_time_series`.
- "Where do we rank in AI answers" → `get_position_cumulative` /
  `get_position_time_series`.

Pick cumulative for "who is winning" comparisons and time series for
"how is it trending" questions. State the date range you used in the answer.

## Drill-down workflows

- Which domains AI models cite: `get_sources` (root domains, classified
  owned / competitor / partner / third_party) → `get_source_pages` for
  individual URLs with per-URL trends.
- What AI assistants actually said: `get_responses` (paginated via
  `page_num` / `page_size`, max 100 per page) — includes sentiment,
  sources, and ranking per response. Use `filters.has_search_queries` to
  select answers that did or did not use web/map search, and
  `filters.search_query_text` with optional
  `filters.search_query_text_operator` (`contains` or `does_not_contain`) to
  match the generated search-query text. For bulk pulls where you only need
  which prompt ran and how it scored, set `include_response: false` and
  `compact_sources: true`: that drops the answer text and swaps the
  per-URL sources for a deduped `source_domains` list, cutting each row
  to roughly a tenth. Pair with `filters.variation_filter: ["variation"]`
  to export only the fan-out variations of your tracked prompts.
- Tracked prompts (the queries AthenaHQ monitors): `get_prompts`.
  Tracked competitors: `get_competitors`. Geo targets: `get_locations`.
- Content performance: `get_content_hub_sheets` (discover tabs) →
  `get_tracked_content` (finished content with citation/impression
  metrics, excludes in-flight items, filter by `sheet_id`) →
  `get_content_detail` (full text of one
  item) or `get_content_citation_prompts` (which prompts cite it).
- Content inventory, including unpublished work: `list_content` enumerates
  every item (in-flight drafts, briefs, scheduled and failed runs, plus
  tracked pages; no metrics). Use it to find items `get_tracked_content`
  does not show and to get a draft's `content_id` for `get_content_detail`.
  `stage` is pipeline state, not publication: treat an item as published
  only when `stage` is `done` (or it is an external/imported page) AND it
  has a `url`. `done` without a `url` is an unpublished orphan; manual
  editor items carry `generated`; `null` is a page with no pipeline
  record.
- Plan usage: `get_credits_organization` / `get_credits_website`.
- Sales pitch reports (org-wide): `list_pitches` → `get_pitch`.

## Answering style

- Lead with the number and the comparison the user asked for; name the top
  competitors by name.
- Note the analyzed date range and any filters applied.
- If a tool returns empty data, check `get_date_range` and widen the range
  before concluding there is no data. For content specifically, an empty
  `get_tracked_content` result can simply mean nothing has finished
  generating yet: call `list_content` before reporting a sheet as empty.

## Write tools and boundaries

- Treat analytics reads separately from writes. Before creating, editing,
  publishing, deleting, or starting a response run, state the exact action and
  invoke the tool only when the user has explicitly requested it.
- AthenaHQ enforces write permissions from the connected user's role. If a
  write is denied, explain the required permission and point the user to the
  AthenaHQ dashboard (https://app.athenahq.ai).
- Some delete tools are permanent. Never imply that a destructive action can
  be undone unless the tool result says so.
- These analytics cover AI assistant answers, not Google organic search.
  Redirect traditional SEO questions instead of answering with these tools.
