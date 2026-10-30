---
name: mercury-detect-anomaly
description: "Detect anomalous Mercury transactions by building 90-day per-counterparty and per-category baselines and flagging pattern breaks in a recent window. Use for questions like anything unusual this week, new vendors, or unexpected charges."
metadata:
  version: "1.0.0"
  category: agentic
  tools: [getCurrentDate, getAccounts, listTransactions]
  requires: [mercury-mcp]
---

# Mercury Detect Anomaly

Detect anomalous transactions by building historical spending baselines and flagging pattern breaks. This skill pulls baseline and recent transactions through the Mercury MCP server, computes per-counterparty and per-category norms, and scores recent transactions against those baselines using a weighted anomaly model. It is read-only. Follow `mercury-mcp` for pagination, dates, and formatting.

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `analysisWindow` | Last 7 days | Time period for transactions to evaluate for anomalies |
| `baselinePeriod` | 90 days | Historical lookback period for building baselines |
| `scoreThreshold` | 0.5 | Minimum weighted score to flag a transaction as anomalous |

## Execution Strategy

### Step 1: Establish Date Windows

```
1. Call getCurrentDate to get today's date.
2. Call getAccounts to get all accounts.
3. Compute:
   - baselineStart = today - baselinePeriod   (default: 90 days)
   - baselineEnd   = today - analysisWindow   (default: 7 days ago)
   - analysisStart = today - analysisWindow
   - analysisEnd   = today
```

### Step 2: Fetch Transactions

Two fetches: one for the baseline window, one for the analysis window. Both restricted to `sent` transactions, both paginated to completion per `mercury-mcp`. `listTransactions` takes a single `accountId`; omit it to cover every account, or call once per account when the user has narrowed the scope. Use `postedStart`/`postedEnd`, not `start`/`end`.

```
# Baseline window
listTransactions({ postedStart: <baselineStart>, postedEnd: <baselineEnd>, status: ["sent"], limit: 300 })
# Analysis window
listTransactions({ postedStart: <analysisStart>, postedEnd: <analysisEnd>, status: ["sent"], limit: 300 })
# For each: while response.page.nextPage, repeat with start_after = response.page.nextPage
```

If the baseline result is very large (>2,000 rows), split the baseline range into 7-day windows, fetch each, then merge.

### Step 3: Score Anomalies

```
baselineTransactions = merge(baseline responses)
analysisTransactions = merge(analysis responses)

# Per-counterparty baseline.
counterpartyBaseline = {}
FOR EACH txn IN baselineTransactions:
    cp = txn.counterpartyName
    counterpartyBaseline[cp].amounts.push(abs(txn.amount))
    counterpartyBaseline[cp].dates.push(txn.postedAt)
    counterpartyBaseline[cp].count += 1

FOR EACH cp IN counterpartyBaseline:
    cp.avgAmount = mean(cp.amounts)
    cp.frequency = cp.count / baselinePeriodWeeks   # transactions per week
    cp.typicalDays = mode(cp.dates.map(d => dayOfWeek(d)))

# Per-category baseline.
categoryBaseline = {}
FOR EACH txn IN baselineTransactions:
    cat = txn.category || "Uncategorized"
    categoryBaseline[cat].amounts.push(abs(txn.amount))
    categoryBaseline[cat].count += 1

FOR EACH cat IN categoryBaseline:
    cat.avgAmount = mean(cat.amounts)

# Score each transaction in the analysis window.
FOR EACH txn IN analysisTransactions:
    score = 0
    reasons = []
    cp = txn.counterpartyName
    cat = txn.category || "Uncategorized"
    txnAmount = abs(txn.amount)

    # 1. Amount anomaly (weight: 0.3)
    IF cp IN counterpartyBaseline AND txnAmount > 3 * counterpartyBaseline[cp].avgAmount:
        score += 0.3
        reasons.push("Amount ${txnAmount} is {ratio}x the baseline average ${cp.avgAmount} for {cp}")

    # 2. New counterparty (weight: 0.2)
    IF cp NOT IN counterpartyBaseline:
        score += 0.2
        reasons.push("First transaction with counterparty '{cp}'")

    # 3. Frequency spike (weight: 0.2)
    IF cp IN counterpartyBaseline:
        analysisWindowWeeks = analysisWindow / 7
        currentFrequency = count(analysisTransactions where counterparty == cp) / analysisWindowWeeks
        IF currentFrequency > 2 * counterpartyBaseline[cp].frequency:
            score += 0.2
            reasons.push("Frequency {currentFrequency}/week vs baseline {cp.frequency}/week")

    # 4. Category outlier (weight: 0.15)
    IF cat IN categoryBaseline AND txnAmount > 2 * categoryBaseline[cat].avgAmount:
        score += 0.15
        reasons.push("Amount is {ratio}x the category average of ${cat.avgAmount}")

    # 5. Time anomaly (weight: 0.15)
    IF cp IN counterpartyBaseline AND dayOfWeek(txn.date) NOT IN counterpartyBaseline[cp].typicalDays:
        score += 0.15
        reasons.push("Transaction on {day} -- typically occurs on {typicalDays}")

    txn.anomalyScore = score
    txn.anomalyReasons = reasons

flagged = analysisTransactions.filter(t => t.anomalyScore >= scoreThreshold)
flagged.sortBy(anomalyScore, descending)
```

### Step 4: Present

```
1. Summary header:
   - Analysis window and baseline period
   - Total transactions analyzed
   - Number of anomalies detected
   - Highest anomaly score

2. Ranked anomaly list:
   FOR EACH txn IN flagged (sorted by score descending):
       | Score | Date | Counterparty | Amount | Category |
       Reasons: bullet list of what triggered the flag.
       Baseline context: historical average, frequency, typical timing.

3. Anomaly breakdown by signal type:
   - Amount anomalies
   - New counterparties
   - Frequency spikes
   - Category outliers
   - Time anomalies
```

## Example Output

```
Anomaly Detection: Apr 22 - Apr 29, 2026
Baseline: Jan 29, 2026 - Apr 22, 2026 (90 days)
Transactions analyzed: 142 | Anomalies flagged: 3

Flagged Transactions:

1. Score: 0.65 | Apr 25 | "NewTech Solutions" | $18,500.00 | Software
   - First transaction with counterparty 'NewTech Solutions' (+0.2)
   - Amount is 3.2x the Software category average of $1,622.50 (+0.15)
   - Amount $18,500.00 is 4.1x the average for similar vendors (+0.3)

2. Score: 0.50 | Apr 27 | "AWS" | $28,900.00 | Cloud Services
   - Amount $28,900.00 is 3.4x the average $8,500.00 for AWS (+0.3)
   - Frequency 3/week vs baseline 0.8/week (+0.2)

3. Score: 0.50 | Apr 23 | "Office Depot" | $4,200.00 | Office Supplies
   - Amount is 2.8x the category average of $617.00 (+0.15)
   - Transaction on Saturday -- typically occurs on Mon, Wed (+0.15)
   - Frequency 4/week vs baseline 1.5/week (+0.2)

Signal Breakdown:
  Amount anomalies:    2
  New counterparties:  1
  Frequency spikes:    2
  Category outliers:   2
  Time anomalies:      1
```

## Tips

- A 90-day baseline gives reliable averages for most counterparties. For newer accounts with less history, surface that reduced confidence in the output.
- Transactions with multiple anomaly signals are far more likely to be genuinely anomalous — prioritize composite scores.
- A 90-day baseline can run to many pages. Fetch it in 7-day windows if a single call truncates, and reduce each page programmatically as it arrives instead of holding raw rows in context.
