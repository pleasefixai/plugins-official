---
name: mercury-cash-reconciliation
description: "Produce the Mercury side of a cash General Ledger reconciliation for a given account and period, formatted to drop into a Mercury Reconciliation Workbook."
metadata:
  version: "1.0.0"
  category: agentic
  tools: [getCurrentDate, getAccounts, getAccountStatements, listTransactions]
  requires: [mercury-mcp]
---

# Mercury Cash Reconciliation

Pulls the Mercury side of a cash General Ledger (GL) reconciliation for a target Mercury account and accounting period. Produces a workpaper block formatted to match the standard Mercury Reconciliation Workbook — GL balance vs. Mercury balance, a reconciling-items table bucketed into timing / permanent / prior-period, tickmark legend, and sign-off line.

> This skill produces only the Mercury side of the workpaper. The other half — the GL-system balance pull, accounting-tool sync, and any journal-entry adjustments — comes from your finance close process and is supplied by the user.

This skill is **read-only**. It pulls balances, statement metadata, and transactions through the Mercury MCP server and never modifies anything. Follow `mercury-mcp` for pagination and formatting.

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `accountId` | (required) | Mercury account to reconcile. If omitted, the skill lists accounts and asks. |
| `period` | Last closed month | Period to reconcile, as `YYYY-MM` (e.g. `2026-04`). |
| `priorOpenItems` | none | Optional path to a JSONL file or pasted list of items still outstanding from the prior period — used to age and resolve carry-forward items. |
| `outputDir` | `~/Downloads` | Where to save the reconciliation Markdown block. |

## Execution Strategy

### Step 1: Anchor and resolve scope

```
1. Call getCurrentDate to get today's date.
2. IF period not provided:
       period = previous calendar month, format YYYY-MM
3. Compute:
   - periodStart = first day of period (YYYY-MM-01)
   - periodEnd   = last day of period (last calendar day)
4. Call getAccounts.
5. IF accountId not provided:
       Show the user a numbered account list (name, kind, last4) and ask which to reconcile.
   ELSE:
       Confirm the account exists in the list. If not, stop and surface the error.
6. Capture the Mercury-reported `currentBalance` and `availableBalance` from the chosen account row.
```

### Step 2: Locate the period statement

The statement is the authoritative source for the bank-side closing balance the reconciliation owner ties to. Statement PDFs are not available through the MCP server, but the statement record is:

```
getAccountStatements({ accountId: <accountId>, start: <periodStart>, end: <periodEnd> })
```

If a statement for the period exists and its record carries a closing balance, use that as the canonical Mercury-side balance and cite the statement in the workpaper. Otherwise tie to `currentBalance` from Step 1 and say so in the workpaper notes. Tell the user the PDF itself can be downloaded from the Mercury dashboard if the reviewer needs it attached.

### Step 3: Pull the period's transactions

```
listTransactions({
  accountId: <accountId>,
  start: <periodStart>,
  end:   <periodEnd>,
  limit: 300
})
# while response.page.nextPage: repeat with start_after = response.page.nextPage
```

Two deliberate departures from `mercury-mcp` here:

- **`start`/`end`, not `postedStart`/`postedEnd`.** Reconciliation needs everything *created* in the period, including items that had not posted by period end; that is exactly what the `createdAt` filter gives. Results still carry `postedAt`, which is what Step 4 compares against `periodEnd`.
- **No `status` filter.** Pending and in-transit items are the reconciling differences; filter by status in Step 4 instead.

### Step 4: Bucket reconciling items

```
# Every row was created in the period (Step 3's filter), so bucket on status and postedAt.
posted    = transactions where status == "sent" AND postedAt <= periodEnd
inTransit = transactions where status != "sent" OR postedAt > periodEnd
pending   = transactions where status in ("pending", "processing")

# Aged carry-forward
IF priorOpenItems supplied:
    FOR EACH prior IN priorOpenItems:
        IF prior.id IN posted (i.e. it cleared this period):
            mark prior as "cleared"
        ELSE:
            carryForward.push(prior with age + 1 month)
ELSE:
    carryForward = []  # ask user to supply prior workbook for full aging
```

### Step 5: Compute the reconciliation

```
mercuryBalance   = statement closing balance (Step 2, if available) OR currentBalance (Step 1)
inTransitTotal   = sum(abs(t.amount) for t in inTransit, with sign preserved)
pendingTotal     = sum(abs(t.amount) for t in pending, with sign preserved)
carryForwardTotal = sum(carryForward amounts)

# Adjusted Mercury balance — what the GL should reconcile to.
adjustedMercury = mercuryBalance
                  + (debits in transit / pending that haven't yet hit the bank)
                  - (credits in transit / pending that haven't yet hit the bank)
                  + carryForwardTotal

# At this stage the user supplies the GL balance from the finance close process.
# Difference = glBalance - adjustedMercury
# Any non-zero difference is a "permanent" reconciling item -- bank fees, missing entries, errors.
```

If the user hasn't supplied the GL balance, emit the workpaper with the GL row blank and a `[fill in from NetSuite]` placeholder.

### Step 6: Emit the workpaper block

Save to `<outputDir>/mercury-rec-<accountSlug>-<period>.md` and also print to the conversation.

```markdown
# Mercury Cash Reconciliation — <Account Name> (****<last4>)

**Entity:** <entity number from account, if available>
**GL Account:** [fill in from NetSuite]
**Period:** <period> (<periodStart> to <periodEnd>)
**Statement:** <statement period / id, or "tied to current balance">
**Prepared by:** <user>  |  **Date:** <today>

## Balance summary

| Line | Amount |
|------|--------|
| GL closing balance | $[fill in] |
| Less: in-transit debits not yet posted | -$<amount> |
| Add: in-transit credits not yet posted | +$<amount> |
| Less: pending debits | -$<amount> |
| Add: pending credits | +$<amount> |
| Aged outstanding carryforward | +/-$<amount> |
| **Adjusted Mercury balance** | **$<adjustedMercury>** |
| Mercury statement closing balance | $<mercuryBalance> |
| **Difference (should be $0.00)** | **$<diff>** |

## Reconciling items

| # | Date | Counterparty | Amount | Category | Age (days) | Status | Action | Tickmark |
|---|------|--------------|--------|----------|------------|--------|--------|----------|
| 1 | ... | ...          | ...    | timing   | ...        | ...    | ...    | ✓        |
| 2 | ... | ...          | ...    | prior    | ...        | ...    | ...    | †        |
| 3 | ... | ...          | ...    | permanent| ...        | ...    | ...    | ^        |

**Tickmarks:** ✓ agreed to Mercury statement   ^ recalculated   † tied to prior period

## Sign-off

| | Name | Date |
|-|------|------|
| Preparer | | |
| Reviewer | | |
```

### Carry-forward between periods

Nothing is written back to Mercury. To let next month's run age items automatically, save the open reconciling items as JSONL alongside the workpaper (`<outputDir>/mercury-rec-<accountSlug>-<period>-open-items.jsonl`) and pass that file as `priorOpenItems` next time.

## Example Output

```
Mercury Cash Reconciliation — Operating (****4821)
Entity: 11300   GL Account: [fill in from NetSuite]
Period: 2026-04 (2026-04-01 to 2026-04-30)
Statement: 2026-04 (closing balance from statement record)
Prepared by: cobrien   Date: 2026-05-14

Balance summary:
  GL closing balance                                  $[fill in]
  Less: in-transit debits not yet posted              -$4,820.00
  Add:  in-transit credits not yet posted             +$0.00
  Less: pending debits                                -$1,247.50
  Add:  pending credits                               +$0.00
  Aged outstanding carryforward                       +$312.00
  Adjusted Mercury balance                            $1,247,503.21
  Mercury statement closing balance                   $1,253,258.71
  Difference                                          $0.00  ✓

Reconciling items:
  # | Date       | Counterparty       | Amount     | Category  | Age | Status   | Tickmark
  1 | 2026-04-29 | Vendor Wire Co     | -$4,820.00 | timing    |   1 | pending  | ✓
  2 | 2026-04-28 | SaaS Charge        | -$1,247.50 | timing    |   2 | pending  | ✓
  3 | 2026-02-15 | OldVendor LLC      | -$312.00   | prior     |  88 | open     | †
```

## Tips

- **Pull without a `status` filter** for this skill; pending and in-transit items are the whole point. The `mercury-mcp` default of `sent` applies to spend-analysis skills, not reconciliation.
- The statement closing balance is what the reconciliation owner ties to. If the statement record doesn't carry one, surface that clearly and tie to `currentBalance` with a note.
- If the GL balance isn't supplied, emit the workpaper with placeholders rather than skipping — the reconciliation owner pastes the GL row in from the finance close process on their side.
- For Broker Dealer / restricted-cash subaccounts, the entity number matters for the J-file. Confirm with the user which entity context the account belongs to before emitting the workpaper.
- Aged items 60+ days old should be flagged to the user verbally, not just included in the table — they may need an adjusting entry rather than another month of carry-forward.
