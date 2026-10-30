---
name: booking-handoff
description: Freight Right booking preparation — turn a chosen offer into a confirmation link that the customer opens and submits themselves, then read what they decided. Use after an instant price check or a QUOTED quote request when the customer wants to book an offer, and to check the state of a booking already prepared. No tool here books anything.
---

# Freight Right: preparing a booking

**Nothing here books anything.** These tools write a pending record and return a link. Only the customer, signed in
to Freight Right in their own browser, can submit it on that page. Give them the link and say plainly what it will
book.

Say "I have prepared a booking for you to confirm", never "I booked it".

## Which prepare tool

| Came from | Tool | Needs |
|---|---|---|
| An instant price check | `freightright_prepare_instant_booking` | `pricing_id` (`pj_…`) + `offer_id` (`of_…`) |
| A quote request | `freightright_prepare_rate_request_booking` | `rate_request_id` (`rfq_…`) + `offer_id` (`of_…`) |

The instant path needs an offer that is still bookable: **a price check without `bookable_until`, or whose
`bookable_until` has passed, is refused and nothing is prepared.** Without one, Freight Right did not keep the offers
for booking — they can be shown but not booked online, so do not offer a link: price the lane again later or, only
if the customer asks for it, send a quote request. Once it has passed, price again and book from the new price check.

The quote-request path is refused unless the request's status is **`QUOTED`**. Check it first and tell the customer
what the status actually is. It is also refused when the request's `may_book` is `false` — this connection can read
it but not book it, because booking takes the account that created the request, a current member of the
organization it is billed to, or an address Freight Right shared its quote with (an administrator books only the
requests their own account created). Say who can
book it instead of preparing a link that would fail.

Both take an optional `reference` (up to 64 characters — the customer's own PO or job number) and `note` (up to
2,000). Offer these; a reference is what the customer will recognise the shipment by later. If a note is refused as
too long, say that the note is too long and ask the customer to shorten it — it is their input, not an outage.

The offer's identity and revision are what was shown to the customer. The server attaches them; you never pass a
revision. If the offer has changed or expired upstream, the booking is refused rather than silently repriced.

## Three different expiry times — keep them apart

| Time | What it is |
|---|---|
| The link's `expires_at` | Up to **30 minutes** from preparing, cut short if the offer stops being bookable sooner |
| `bookable_until` | When the offer stops being bookable at all. A price check without one cannot be booked online |
| The offer's `valid_until` | A **date**, after which the price is no longer valid |

Show the link's deadline prominently, with its timezone. Never let "price valid until" imply the link still works.

**Preparing the same pending booking again returns the same link and does not extend it.** If the customer asks for
more time, the honest answer is that the deadline has not moved. Once an operation is decided — cancelled, expired
or failed — a fresh attempt can be prepared, and it gets a new link, provided the offer is still available.

## Reading what the customer decided

`freightright_get_booking_operation(operation_id)`.

| State | Means | Do |
|---|---|---|
| `PENDING_CONFIRMATION` | Waiting for the customer's click | Give them the link and the deadline |
| `SUBMITTING` | Being sent | Read again shortly |
| `DONE` | Freight Right has the request and is **reviewing** it | Say it is submitted and under review |
| `CANCELLED` | The customer declined on the page | Ask what they want instead |
| `EXPIRED` | The window passed unused | Offer to prepare it again if still bookable |
| `FAILED` | Freight Right refused it | Report the reason given |
| `UNKNOWN` | The outcome is not yet established | **Read it again shortly. Never prepare a second time** |

`UNKNOWN` is reconciled in the background using the same bytes and the same key. Preparing again in response to it
is how a customer ends up with two bookings — do not.

`DONE` is not a confirmed booking. It becomes `BOOKING_REQUESTED` at Freight Right, and **`BOOKED` is a separate
confirmation** that Freight Right makes. Do not tell the customer their freight is booked until it is.

The summary on the operation is a snapshot of what the customer was shown when it was prepared. It does not change
because the upstream moved, and that is deliberate — it is the promise. Present it as shown, and note that a long
charge list or note may be abbreviated for display while the whole note is what gets submitted.
