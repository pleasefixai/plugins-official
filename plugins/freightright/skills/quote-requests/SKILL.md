---
name: quote-requests
description: Freight Right quote requests — ask Freight Right's pricing team for a price that instant rates cannot give. Use for full truckload, Mexico trucking, hazardous or temperature-controlled cargo on a mode that refuses it, oversized or unusual cargo, a lane with no instant offers, or a second opinion on an instant price. Covers previewing what would be sent, submitting it, polling the result, who may book it, listing quotes — a customer's own, or every organization's for a Freight Right administrator — and an administrator sharing a quote with e-mail addresses and finishing a draft quote: its offers, the one chosen, sending it and its public link. Also use when a customer wants to ask Freight Right's team something in their own words — a spot rate, a contract inquiry, help with a booking, a shipment problem, a correction or a feature request — or to follow up on or withdraw such a request.
---

# Freight Right: quote requests

A quote request goes to Freight Right's pricing team, who answer with a quote the customer can book. It is the
route for everything instant prices cannot do.

A **request to Freight Right's team** (`FR-…`) is a different thing: the customer's own words, answered by e-mail.
It has its own tools and its own rules — see the last section.

## When a quote request, not an instant price

Check the mode before deciding — the rules are not uniform.

| Situation | Route |
|---|---|
| **FTL** (full truckload), any cargo | Quote request. FTL is never priced instantly |
| **FCL** with hazardous **or** temperature-controlled cargo | Quote request — FCL refuses both |
| **LTL** with temperature-controlled cargo | Quote request |
| **LTL** with hazardous cargo | **Instant price** — LTL takes the hazardous flag |
| **LCL** or **AIR** with hazardous or temperature-controlled cargo | **Instant price** — both are accepted |
| Insurance on LTL or FTL | Quote request, with the value in the note |
| Mexico trucking, oversized cargo, no instant offers, a second opinion | Quote request |

FTL equipment goes in `containers` as container sizes — the current API representation. Everything else about the
truck (trailer type, loading, weight) goes in the note.

## Preview, then submit

`freightright_preview_rate_request` shows exactly what would be sent. **It sends nothing, creates nothing and
stores nothing.** Show it to the customer before submitting.

**A preview is not authorization to send.** It is a draft for the customer to look at. Submit when the customer has
said to — and if the content changes after they agreed, preview again and ask again. Equally, do not re-ask for
authorization the customer has already given for the same request.

`freightright_submit_rate_request` takes **the same arguments you previewed**, unchanged. It creates the request,
notifies the pricing team and emails the customer.

Whether the customer's assistant asks them to confirm before this is sent depends on their assistant settings, not
on Freight Right. Say what you are about to send.

A Freight Right administrator submits a quote request **for** a client organization: `billing_organization_id`
of one found with `freightright_list_billing_organizations` `query`, or `billing_company_name` for a customer who has
no organization. Their request is an internal draft until Freight Right's team sends it; the organization's own
users do not see it before then.

## Who may book it

`freightright_get_rate_request.may_book` says whether **this connection** may book the request: the account that
created it, a current member of the organization it is billed to, or an address Freight Right shared its quote with.
Reading is not booking. When it is `false`,
say who can book it and do not offer to — `freightright_prepare_rate_request_booking` refuses it anyway. An
administrator reads every organization's requests and books only the ones their own account created.

## Sharing a quote (Freight Right administrators)

`freightright_share_quote` shares a quote with e-mail addresses: the `quote_number` (an integer from
`freightright_list_quotes`) and 1 to 20 addresses. Each address then sees the quote once it signs in to Shipment
Manager with that address — with or without an organization — and can use its approval, booking-request and
cancellation actions. An administrator's draft stays hidden until it is sent.

- **Only an administrator's connection shares.** On a customer's connection the tool refuses; say that Freight Right
  shares quotes, and that the customer can ask their Freight Right contact.
- **Share only the addresses the user named,** and only when they asked: the people behind them see the quote's
  prices. Whether the user is asked to confirm first depends on their assistant settings.
- **Sharing sends no e-mail.** To notify someone, send them the quote (`freightright_send_quote`, below). An address
  is removed on the quote page in Shipment Manager — no tool removes one.
- If one address is not valid, nothing is shared: correct it and send them again. An address the quote already has
  changes nothing, so a retry is safe.

A quote row with `shared_with_you: true` is one the user sees only because it was shared with them.

## Finishing a draft quote (Freight Right administrators)

An administrator's connection takes a draft quote to its customer — in this order, and each step only when the user
asks. Every tool takes the `quote_number`.

| Step | Tool | |
|---|---|---|
| 1. List its offers | `freightright_get_quote_offers` | As its customer would see them, cheapest first |
| 2. Select the one the user chose | `freightright_select_quote_offer` | The `offer_id` and `revision` exactly as listed |
| 3. Share it with the people who should see it | `freightright_share_quote` | Above |
| 4. Send it | `freightright_send_quote` | The draft becomes pending the customer's approval |
| 5. Give it a public link | `freightright_public_link` | `freightright_change_public_link` replaces it or turns it off |

- **The first listing prices the quote**, which can take up to a minute for a door delivery; if the answer says it
  is still pricing, ask again. A quote that already has its offer, or is no longer a draft, has nothing to list.
- **Select only the offer the user chose**, after telling them its carrier and total. A quote keeps the first offer
  selected — changing it is done on the quote page in Shipment Manager, not here. If the offer changed or is no
  longer listed, list the offers again. Selecting sends nothing: the quote stays a draft until it is sent.
- **Sending e-mails only the `recipients`** you pass — the quotation e-mail with the PDF — and each must already be
  an address the quote is shared with, so share first. With no recipients nothing is e-mailed. Send only when the
  user asked, to the people they named. The quote needs its offer, still valid; a quote already sent is sent again
  only to named recipients.
- **Anyone holding the public link sees the quote** without signing in, including later changes, until its offer
  expires or the link is turned off — give it only to whom the user names. It needs a sent quote with a valid
  offer, and asking again returns the same link.
- **`reset` and `turn_off` stop the current URL for everyone who has it**, so use them only when the user asks.
  `reset` makes a new URL; `turn_off` ends the link for good, whatever the quote's state.
- Whether the user is asked to confirm before a select or a send goes through depends on their assistant settings,
  not on Freight Right.
- On a customer's connection these tools refuse: say that finishing a quote is Freight Right's, and that the
  customer can ask their Freight Right contact.

## Give the shipment, or give a price check — never both

`freightright_submit_rate_request` accepts **either**:

- the shipment (`mode`, `origin`, `destination`, cargo) — with billing; **or**
- `rate_call_id` (`rc_…`) from an instant price check, to ask the team about a lane already priced — and then
  **omit billing**, because it comes from the price check.

Never both, never neither. `origin`, `destination` and `mode` look optional in the schema only because the
`rate_call_id` alternative exists.

## After it is sent

`freightright_get_rate_request(rate_request_id)` — the id is `rfq_…`.

| Status | Means |
|---|---|
| `PENDING` | With the pricing team. **Never resubmit** — wait |
| `QUOTED` | There is an offer that can be booked |
| `DECLINED` | Freight Right cannot quote it |
| `EXPIRED` | The offer is no longer valid |
| `BOOKING_REQUESTED` | A booking was asked for and is being reviewed |
| `BOOKED` | Freight Right confirmed the booking |

Submitting an identical request again within **30 days** returns the first one rather than creating a second. That
is a safeguard, not a way to poll.

`freightright_list_quotes` is the index across everything — quotes from the portal, from quote requests and from
instant bookings.

**Only some rows can be opened here.** A row with a `rate_request_id` (`rfq_…`) can be read in full with
`freightright_get_rate_request`. A row created in the portal has **`rate_request_id: null`** and there is no tool
that reads it — say so plainly and point the customer at that quote in Shipment Manager, rather than guessing an id
or reporting the row as if it were complete.

A **quote number is an integer** shown in Shipment Manager and is **not** a quote request id.

When `has_more` is true, call again with `cursor` set to `next_cursor` and the same filters. Never invent a cursor.

For enum values and limits, read `freightright://reference/codes`; if resources are unavailable in this client, ask
the customer rather than guessing.

## Requests to Freight Right's team

A request to the team is a message in the customer's own words, which the team answers **by e-mail**, to the
account's own address, in the thread of the confirmation the customer receives when it is sent. The customer can
also follow it in Shipment Manager. Its id is `FR-…`.

| `kind` | For |
|---|---|
| `spot-rate` | A price for a lane or shipment the instant tools could not answer |
| `contract-inquiry` | Rates over a period, for a volume |
| `booking-help` | Help with a quote, a quote request or a booking |
| `shipment-issue` | A problem with a shipment — it needs the shipment reference |
| `data-correction` | Something recorded wrongly — it needs the reference of the record |
| `feature-request` | Something the customer wishes the product did — their words are the request |

1. **Check first.** `freightright_list_requests`. An open request — `submitted`, `triaged` or `in_progress` — on the
   same ask is continued, **never duplicated**.
2. **Draft: nothing is sent.** `freightright_create_request_draft` with the `kind`, the customer's words **exactly
   as they said them** as `message` — never a summary of yours — and the details you read from them, never a guess.
   The draft is private: nobody is notified.
3. **One question at a time.** The answer says what Freight Right understood, what is still missing
   (`missing_fields`) and the one question to ask next (`suggested_question`). Ask that, then fill the answer in
   with `freightright_update_request_draft` and the `revision` of the last answer you saw. A detail not given is
   unchanged, `clear` empties one by name, and `message` adds the customer's further words to what they said
   before — never a replacement.
4. **Preview.** `freightright_preview_request` shows the confirmation e-mail the customer would receive, what the
   team gets and where replies go. It is read-only. Show it and ask whether to send **that** version.
5. **Submit only on the customer's yes to that version.** `freightright_submit_request` with the preview's
   `revision`. Never on your own initiative, never to save a step, never a duplicate of an open request. Whether the
   customer's assistant asks them before it runs depends on their assistant settings; their explicit yes in the
   conversation is what authorizes it. The customer then gets the confirmation e-mail and the team is pinged.

- **Never ask for the account or the e-mail address** — both are known, and replies always go to the account's own
  e-mail. Ask which organization only when `missing_fields` lists `organization`, and pass
  `billing_organization_id` from `freightright_list_billing_organizations`.
- **A changed draft is refused, not applied twice.** An update made from an older answer is not applied: the answer
  shows the draft as it is now, so continue from its revision. A submission whose draft changed since the preview
  sends nothing — preview again, show the new version, and ask again. A draft with `blocking_fields` is refused at
  submission with what is missing.
- **The same words and details within 30 days return the same request**, whatever became of it — `replayed` says
  so. If the customer meant a new one, add a detail or rephrase.
- **Withdraw only when the customer asks.** `freightright_withdraw_request` ends a draft, or a submitted request the
  team has not answered yet. It is the record only: nothing not yet sent goes out and the team stops working on it,
  but **an e-mail already delivered is not unsent**. An answered or closed request cannot be withdrawn — the
  customer replies to the team's e-mail instead.
- **Following one.** `freightright_get_request` reads its status, what was understood, the team's answer once one
  was e-mailed, the confirmation e-mail and its history. `responded` means the team marked it answered; the
  e-mailed reply is the request's `answer` — without one, do not tell the customer a reply was e-mailed. Reading is
  not authority to act: only the account that created a request updates, submits or withdraws it.
- **It needs a Freight Right account**, which is free: someone without one signs up on Shipment Manager's sign-up
  page, connects their assistant to that account, and asks again.
- **An administrator's connection files none.** It reads every organization's requests; staff file for a customer
  on the staff page in Shipment Manager.
- **At most 20 drafts and 5 submissions per organization per day.** When a limit is reached, the answer says when
  it resets.
