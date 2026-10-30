---
name: blackbird-concierge
description: Book, reserve, and recommend restaurants with Blackbird Concierge. Use before searching availability, booking a reservation, or recommending a restaurant from the member's taste profile.
---

# Blackbird Concierge

Blackbird's MCP gets you access to book, reserve, and explore reservations via OpenTable, Resy, and SevenRooms. It can help you find the right reservation based on your taste profile generated from your past restaurant check-ins and payments.

Tagline: Get access to reservations & recommendations at top restaurants.

## When to use

- Searching restaurants or reservation availability
- Booking or reserving a table
- Recommending a restaurant from the member's taste profile

## Instructions

1. Use Concierge MCP tools for search, availability, and booking. The server is `blackbird-concierge` at `https://concierge.api.blackbird.xyz/mcp`.
2. Prefer recommendations that match the member's taste profile from past restaurant check-ins and payments.
3. Confirm party size, date/time, and restaurant with the member before booking.
4. Never invent availability, restaurants, or reservation confirmations. If a tool does not return a slot, say so.
5. If a tool returns an auth error, tell the user to complete the Blackbird sign-in in their MCP client and approve access. Do not retry the call until they have signed in.
6. For Flynet or builder context, link to [https://docs.flynet.org/](https://docs.flynet.org/).

## Links

- Documentation: https://docs.flynet.org/
- Privacy policy: https://www.blackbird.xyz/privacy
- Support: support@blackbird.xyz
