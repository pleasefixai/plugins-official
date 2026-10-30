---
name: instant-pricing
description: Freight Right instant freight prices — live carrier rates for FCL, LCL, AIR and LTL shipments. Use when a customer asks what a shipment will cost, wants to compare carriers on a lane, or when a price check that is still running needs collecting or its offers paging. Covers turning place names into port and airport codes, what each freight mode requires, the monthly price-check allowance, and reading an offer.
---

# Freight Right: instant prices

An instant price asks carriers live. **A new check spends one unit of the customer's monthly allowance**, so price
once per lane and cargo, when the customer wants prices — never to explore.

## Before you price

1. `freightright_get_account` — the billing policy and the remaining allowance. Free. A Freight Right
   administrator (`ANY_ORGANIZATION_OR_COMPANY_NAME`) bills a client organization they find with
   `freightright_list_billing_organizations` `query`, or a company name for a customer who has none; the allowance
   spent is the administrator's own.
2. **Resolve every place the customer named** with `freightright_find_locations`. A port or airport is a code
   (`CNSHA`, `USLAX`, `PVG`); a door is a postal code plus a two-letter country code, used exactly as given and
   needing no lookup. **No code is ever guessed** — a wrong one is `location_not_found` and nothing else.
3. Ask the customer for anything missing rather than assuming it. A guessed weight is a wrong price.

## What each mode needs

| Mode | Cargo | Also required | Refuses |
|---|---|---|---|
| **FCL** full container, ocean | `containers` (type + quantity, ≤4 entries) | `direction` | hazardous, temperature-controlled → quote request |
| **LCL** part container, ocean | `pieces` **or** `totals`, never both | `direction` | — |
| **AIR** | `pieces` **or** `totals`, never both | `direction` | — |
| **LTL** pallets by road | `pieces`, with a DOOR at both ends | — | `direction`, `incoterm`, port charges, customs, insurance |
| **FTL** full truck | — | — | never priced instantly — use a quote request |

A *piece group* is any number of **identical** pieces carrying the dimensions and weight of **one** of them. A
group can be hundreds of pallets, so the group limits are rarely a real constraint. `totals` (pieces, gross weight,
volume) is the fallback for LCL and AIR when dimensions are unknown.

Insurance is `insured_value_usd`, the commercial value of the goods in USD, and exists on **FCL, LCL and AIR only**.
For LTL and FTL, ask for insurance in a quote request note with the value.

For enum values, unit and decimal limits, packaging types, incoterms and freight classes, read
`freightright://reference/codes`. It is generated from the same table as the tool schemas, so it cannot fall behind
them. If you cannot read resources in this client, ask the customer or send the call and read the validation error —
never invent an enum value.

## What a call costs

`served_from` on the answer says it plainly:

- **`NEW_CHECK`** — this call started a check and **spent one unit**. It is not a promise the carriers were asked
  again; the API may answer a repeated request from its own cache and still charge.
- **`EXISTING_CHECK`** — an identical request for the same billing account joined a running check or was served a
  retained one. **This call spent nothing**, and the original pricing time is kept.

Reuse keys on the exact normalized request plus the billing context, not merely "the same lane and cargo". A result
is retained until `bookable_until` and can be dropped sooner, because only the five most recent results per customer
are kept. Never suggest altering shipment details to change this.

`freightright_find_locations` and `freightright_get_rate_offers` are free.

## A check that is still running

A slow answer comes back as `status: PRICING` with a `pricing_id` and a `retry_after_seconds`.

**Collect it with `freightright_get_rate_offers`.** Repeating an identical request joins the same check and does
not refresh its prices, so calling `freightright_get_instant_rates` again buys nothing — and a request that differs
even slightly is a NEW check, which does spend a unit.

Pricing again *is* right when the request has genuinely changed — different cargo, dates, services or lane — or when
the earlier result has expired or been evicted and the customer still wants prices. Say which of those applies.

## Reading the answer

`freightright_get_rate_offers` also pages offers (`offset`) and returns every charge of one offer (`offer_id`).

- An **offer is a price, not a booking**. Nothing is reserved.
- It is only valid until its `valid_until`. Never present a price as final after that date.
- `complete: false` means a source did not answer. No offers with `complete: true` means there is no instant price
  for that lane — offer a quote request.
- A price check without `bookable_until` cannot be booked online: say so rather than offering to book one of its
  offers.
- Amounts are sell prices for this customer, in the offer's currency. **Never add or compare totals across
  currencies.**
- An empty `not_included` means everything requested was priced. It is a different field from `exclusions`, which
  lists what the offer will not cover; an empty one says nothing about the other.

Lead with the total, the carrier, the transit time and the validity date. Mention any transhipment port. If you
computed anything yourself, say that you computed it.
