---
name: adspirer-search-measurement
description: Audit search-ad conversion tracking and investigate performance using available Google Analytics, Search Console, and Tag Manager tools.
---

# Measurement and conversion tracking

Load adspirer-search-mcp. Identify the conversion event, account/property/container, time
range, attribution basis, and business objective. Ask for additional connections only when
the current question needs them.
Discover audit_conversion_tracking and available GA4, GSC, and GTM tools and schemas.
Start with reads. Separate Google Ads conversions, GA4 events, and Search Console organic
clicks; they have different definitions and should not be treated as interchangeable.
Report verified findings, unknowns, access gaps, and prioritized fixes. An absent event in
a sample does not establish broken tracking. Do not promise complete multi-touch attribution.
Publishing a GTM container, editing tags, changing conversion actions, or other writes needs
specific approval and a rollback plan. Verify after approved changes; do not report success
solely because a write request was accepted.
