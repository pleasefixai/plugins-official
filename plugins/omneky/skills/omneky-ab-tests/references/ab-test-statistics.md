# A/B test statistics

Use from `omneky-ab-tests` only. Use the connected Omneky MCP
server. Gate every named tool on this session's `tools/list`.

This file is the formula sheet. The skill owns the playbook.
Numbers below are **example data**, not a live brand.

**Invalid** is exempt from the horizon gate. The setup
check runs on every look, including pre-horizon peeks. If
it fails (broken setup, or SRM on a randomized planned
split), give the verdict Invalid immediately, Stop, and recommend
pausing or fixing the test (a pause is a later yes via
`omneky-launch-and-connect`; never mutate here). Only
Winner, Not commercially meaningful, Inconclusive, and
No detectable difference wait for `horizon`. A peek that
passes the setup check is INTERIM with no statistical
verdict. Then the lift, the interval, and whether it
clears the precommitted MDE and a CPA / ROAS dollar
impact.

**Example data — pre-horizon broken setup (Invalid, not INTERIM):**
horizon end date is next week; variant B has near-zero
delivery. Verdict: **Invalid**. Stop. Recommend pausing or
fixing. Do not label INTERIM.

## Precommit (create)

Record one primary metric, a baseline rate, MDE, α, power,
required `n_per_arm`, randomization unit, attribution window,
and a fixed `horizon` (end date or sample). Defaults: α = 0.05,
power = 0.8. One metric. Do not add a second primary later.

Baseline: call `get_daily_metrics` with `date_range` covering
at least the last 14 days when listed. CTR = clicks /
impressions. CVR = conversions / clicks. If reporting is empty,
state the assumed baseline and label it an assumption.

Randomization caveat: a platform ad-level split (two ads in
one ad set) is **not** true user randomization unless the
channel's own A/B product is used. Say that on the plan.

## Sample size (two-proportion)

Equal arms, two-sided test. Show this formula and the plugged
numbers:

```
n_per_arm = (Z_{α/2} + Z_β)² × (p1(1−p1) + p2(1−p2)) / (p1 − p2)²
```

Z_{0.025} = 1.96. Power 0.8 → Z_β = 0.8416. p1 is the baseline
rate. p2 = p1 + MDE (absolute). Round up.

**Example data** (not a live brand): p1 = 0.020 CTR from 400 /
20,000 impressions. MDE = +0.005 → p2 = 0.025.

```
n = (1.96 + 0.8416)² × (0.020×0.980 + 0.025×0.975) / (0.005)²
  = 7.84896 × 0.043975 / 0.000025
  = 13,807 impressions per arm
```

## Measurement (z-test)

Two-proportion z-test on the precommitted metric:

```
z = (p̂_B − p̂_A) / sqrt( p̂(1−p̂) × (1/n_A + 1/n_B) )
```

p̂ is the pooled rate. Two-sided p-value from |z|. 95% CI on
the difference:

```
(p̂_B − p̂_A) ± 1.96 × sqrt( p̂_A(1−p̂_A)/n_A + p̂_B(1−p̂_B)/n_B )
```

Achieved power: reuse the sample-size formula with observed
rates and the **actual** n; report 1 − β.

**Example data — valid winner:** A 400/20,000 (0.020), B
560/20,000 (0.028). z ≈ 5.23, p < 0.001. Difference 0.008,
95% CI [0.0050, 0.0110]. MDE was 0.005. Dollar impact: state
spend × CVR (or CTR) lift in $ from the same window. Verdict:
**Winner**.

**Example data — significant but below MDE:** difference
0.003, CI excludes 0, MDE was 0.005. Verdict: not
commercially meaningful (do not scale as a Winner).

**Example data — underpowered (horizon reached):** 2,000
impressions per arm vs required 13,807, |z| = 1.1, end date
passed. Verdict: **Inconclusive (underpowered)**.

## Horizon, peeking, early stop

No statistical verdict (Winner / Not commercially
meaningful / Inconclusive / No detectable difference)
before the precommitted `horizon` unless the setup check
already returned **Invalid**. A peek that passed setup is
an **interim** status report only — label it INTERIM, no
named statistical verdict. Invalid is exempt — Stop.

If they insist on early stopping: require an explicit
acknowledgement in the same turn. Then apply a conservative
correction and say which:

- Bonferroni across looks: α_look = 0.05 / k
- O'Brien-Fleming-style: critical z ≈ 1.96 / sqrt(t) where
  t = n_now / n_planned (at t = 0.5, |z| ≳ 2.80)

If they will not acknowledge, say early stopping is not
supported and keep the INTERIM label.

## SRM, delivery imbalance, low counts, many variants

Default one-ad-group, one-ad-per-variant setup is
auction-driven. Do not run SRM as a gate. Report delivery
imbalance as a caveat and compare rates, not totals.
**Example data — ad-level imbalance (caveat, not Invalid):**
14,000 vs 6,000 impressions in one ad group. Caveat the
imbalance; compare CTR / CVR, not impression totals.

SRM → Invalid only when traffic was randomized with a
planned split (platform A/B / split-test, or an explicit
planned allocation). χ² goodness-of-fit of observed vs
planned traffic share. **Example data — randomized split:**
14,000 vs 6,000 impressions vs 10,000 / 10,000 expected.
χ² = 320, p ≪ 0.001. Verdict: **Invalid** (SRM).
Threshold: p < 0.001.

Broken setup (near-zero delivery on a variant, a variant
changed mid-test, or more than one variable differs) →
**Invalid**.

Low counts: either arm below about 1,000 impressions, 30
clicks, or 10 conversions (CVR) → Insufficient data. Do not
declare a winner.

More than two arms: test each variant vs control. Bonferroni
across those comparisons (α / comparisons). Do not treat
pairwise-among-winners as the primary.

## Verdicts

| Verdict | When |
|---|---|
| **Invalid** | Exempt from the horizon gate. Setup check on every look (including peeks). Broken setup or SRM p < 0.001 on a randomized planned split. Immediate Stop; recommend pausing or fixing |
| **Inconclusive (underpowered)** | At or after horizon (or a corrected early stop), achieved power < 0.8 and not significant |
| **No detectable difference** | Horizon reached (or corrected early stop), \|z\| < 1.96, power ≥ 0.8 |
| Not commercially meaningful | Significant, but \|lift\| < MDE or $ impact below the stated floor |
| **Winner** | Horizon reached (or corrected early stop), significant, \|lift\| ≥ MDE, $ impact stated |

Statistical significance is not commercial meaning. Compare
the interval to MDE and to a CPA / ROAS dollar impact.
