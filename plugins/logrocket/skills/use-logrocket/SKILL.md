---
name: use-logrocket
description: Query LogRocket for session replays, metrics, issues, and user behavior using natural language. Use when debugging issues, analyzing feature usage, investigating errors, triaging problems, or understanding how users interact with your app.
---

# Use LogRocket

## When to use

- Debugging a user-reported issue or error
- Understanding how a feature is currently being used before making changes
- Triaging new issues and figuring out root causes
- Checking for regressions after recent deploys or commits
- Prioritizing what to work on next based on real user impact
- Investigating JavaScript errors, rage clicks, or dead clicks
- Inspecting the network requests and responses a user's session actually made, such as failing API calls
- Analyzing post-launch behavior for a new feature
- Researching a specific user or account's sessions

## Available tools

This plugin connects with `?toolsets=all`, so all of these tools are available:

- `list_organizations`: List the LogRocket organizations you can access.
- `list_projects`: List the LogRocket projects within an organization.
- `use_logrocket`: Run natural language queries against your LogRocket data (sessions, metrics, issues), powered by Ask Galileo. It chains tool calls internally and is the best general-purpose entry point.
- `find_sessions`: Filter LogRocket sessions by criteria like user, URL, time range, or events.
- `watch_sessions`: Analyze one or more specific sessions and extract detailed, qualitative information about user behavior.
- `get_network_entries`: Retrieve the raw network requests and responses recorded during a single session as a HAR 1.2 document, filtered by URL, HTTP method, status code, and time.
- `build_metric`: Query LogRocket analytics data directly.
- `find_issues`: List a project's issues - JavaScript exceptions, network errors, rage clicks, dead clicks, frustrating network requests, error states, and mobile crashes - filtered by severity, triage status, issue type, and time range.

## Instructions

1. For broad or open-ended requests, call the `use_logrocket` MCP tool with a natural language `query` describing what you want to know — it handles sessions, metrics, and issues end to end.
2. For precise work, prefer the targeted tools:
   - Use `find_sessions` to filter down to relevant sessions, then `watch_sessions` to analyze or extract details from specific ones.
   - Use `get_network_entries` instead of `watch_sessions` when you only need network data for a session. It takes the `recordingID` and `sessionID` returned by `find_sessions`, and narrowing with `urlFilter`, `methods`, `minStatus`/`maxStatus`, or `startTime`/`endTime` keeps responses small. Results are paginated, so when `offset + limit` is less than `total`, call again with a higher `offset`. Truncated or missing bodies, headers, cookies, and timings are expected and don't indicate a problem with the recorded app. To cover many sessions, call this once per session found by `find_sessions`.
   - Use `build_metric` to query analytics/metrics data directly.
   - Use `find_issues` for issue triage. It defaults to severe, untriaged issues from the last week, so widen `severity`, `triageStatuses`, or the date range when the user asks for something broader. Issues data is only retained for 30 days. When an issue already has an `issueAnalysis`, use it instead of re-deriving the root cause, and follow up with `watch_sessions` on affected sessions when you need more detail.
3. If the user hasn't specified an organization or project, use the `list_organizations` and `list_projects` tools to discover them. If multiple are found, ask the user which to use.
4. To continue the same conversation (e.g. follow-up questions, drilling deeper), pass the `chatID` from the previous `use_logrocket` response.
5. Be specific about what you want analyzed — mention URLs, click targets, user emails, time ranges, or custom events when possible.
6. Ask LogRocket to watch sessions when you need detailed, qualitative insights about user behavior.
7. Present results clearly to the user, including any session URLs, issue links, metrics, charts, or actionable insights.

## Example Prompts

- **Debug user-reported issues:** "User X reported a problem with checkout. Can you use LogRocket to watch their sessions and figure out the root cause?"
- **Understand feature usage:** "I'm about to work on the search feature — can you use LogRocket to help me understand how it's currently being used?"
- **Triage new issues:** "Can you look at LogRocket for new issues from the past week, try to figure out their root causes, and then suggest which ones I can fix?"
- **Check for regressions:** "Look at all commits from last week, and check LogRocket data to ensure they didn't introduce any regressions."
- **Prioritize your work:** "Use LogRocket to watch sessions and look at issues to figure out what is highest priority that I work on next."

## Suggested Automations

Because the MCP server can be called programmatically by AI agents, you can set up powerful automations that continuously leverage LogRocket data:

- **Research churning customers and low NPS scores:** Automatically pull LogRocket sessions for users who are churning or leaving low NPS scores to understand what went wrong in their experience.
- **Research new support tickets:** Connect to your help desk to automatically research incoming support tickets using LogRocket session data. LogRocket offers out-of-the-box integrations with Zendesk and Intercom to attach session replays directly to tickets.
- **Summarize user behavior for sales and customer success:** Automatically generate summaries of how key accounts are using your product, giving your sales and customer success teams actionable insights.
- **Connect LogRocket with your backend data:** Build a skill that allows your agent to correlate LogRocket frontend data with backend observability tools (e.g. Datadog MCP) for end-to-end debugging.
- **Run daily or weekly reports:** Schedule an agent to look for new issues and UX frustration signals on a recurring basis, so your team is always aware of emerging problems.
