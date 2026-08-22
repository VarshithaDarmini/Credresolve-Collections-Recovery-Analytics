# CredResolve Collections Recovery Analytics

# Final Analytical Findings

## 1. Executive Summary

The final analytical dataset contains 30,000 unique accounts.

Overall portfolio recovery performance:

- Total accounts analyzed: 30,000
- Recovered accounts: 13,284
- Unrecovered accounts: 16,716
- Overall recovery rate: 44.28%
- Total recovery amount: ₹1,315,583,964.64 (~₹131.56 Cr)

Recovery amount is defined as the sum of valid SUCCESS payment amounts after duplicate payment IDs have been removed. FAILED, PENDING, and REVERSED payments are excluded from recovery.

The analysis evaluates recovery performance across loan type, risk segment, DPD, call exposure, attempt exposure, agent exposure, campaign exposure, vendor exposure, and targeting exposure.

These results describe observed associations in the portfolio. They should not be interpreted as causal effects without additional experimental or longitudinal analysis.

---

## 2. Golden Dataset

The final account-level analytical dataset is:

`account_features`

Validation results:

- Rows: 30,000
- Unique account IDs: 30,000
- NULL account IDs: 0
- Columns: 23

The dataset combines account attributes, recovery outcomes, and collection activity features at account level.

---

## 3. Payment Data Quality Finding

The raw payment data contains:

- Raw payment rows: 25,500
- Unique payment IDs: 25,000
- Duplicate payment IDs: 500
- Conflicting status values among duplicate IDs: 0
- Conflicting amount values among duplicate IDs: 0
- Conflicting timestamp values among duplicate IDs: 0

The duplicate payment records are therefore consistent duplicates rather than records with conflicting business values.

The account recovery transformation retains one record per payment ID before calculating account-level payment metrics.

The resulting account-level recovery amount is:

**₹1,315,583,964.64 (~₹131.56 Cr)**

Recovery amount includes SUCCESS payments only. FAILED, PENDING, and REVERSED payments are excluded.

---

## 4. Month-on-Month Recovery and the 11% Claim

The claim that "recovery has improved by 11% month-on-month" was tested using deduplicated SUCCESS payment activity.

The available payment activity covers January 1, 2026 through August 8, 2026.

August 2026 is treated as a partial month because payment activity is available only through August 8, 2026.

Only comparable FULL_MONTH periods are used when evaluating the 11% month-on-month claim.

The analysis does not support a sustained 11% month-on-month improvement.

March 2026 is the specific month in which the 11% increase is observed:

| Metric | February 2026 | March 2026 | MoM Change |
|---|---:|---:|---:|
| Recovered accounts | 2,173 | 2,419 | +11.32% |
| Recovery amount | ₹170.14M | ₹188.91M | +11.03% |
| Portfolio recovery rate | 7.24% | 8.06% | +0.82 pp |

However, April subsequently declined, and the remaining complete months did not show another 11% month-on-month increase.

### Recovery-rate denominators

Two monthly recovery-rate denominators are reported:

- **Worked-account recovery rate:** recovered accounts divided by accounts with payment activity in that month.
- **Portfolio recovery rate:** recovered accounts divided by the 30,000-account portfolio.

The worked-account recovery rate is approximately 71–72% during the complete months.

This metric should not be compared directly with the overall 44.28% portfolio recovery rate because the denominators are different.

The portfolio recovery rate provides a broader portfolio-level view, while the worked-account rate describes conversion among accounts that had payment activity.

### Verdict on the 11% Claim

The 11% claim is:

**NOT SUPPORTED as a sustained month-on-month trend.**

March 2026 showed:

- +11.32% recovered accounts
- +11.03% recovery amount

But this improvement was not sustained in subsequent complete months.

The monthly analysis found:

- 6 comparable FULL_MONTH MoM periods
- Only 1 period with at least 11% recovery-amount growth
- Only 1 period with at least 11% recovered-account growth
- Average recovery-amount MoM change: approximately +0.29%
- Average recovered-account MoM change: approximately -0.08%

August 2026 is excluded from the sustained-trend conclusion because it is a PARTIAL_MONTH.

The supporting monthly analysis is available in:

`outputs/monthly_recovery_trend.csv`

### Data Period Limitation

The available payment activity covers January 1, 2026 through August 8, 2026.

Therefore, the monthly recovery trend represents approximately seven complete months plus a partial August period.

The analysis should not be described as a full 12-month recovery trend unless additional collection-period data is available.

---

## 5. Recovery by Loan Type

Observed recovery rates:

| Loan Type | Accounts | Recovered | Recovery Rate |
|---|---:|---:|---:|
| CONSUMER | 5,930 | 2,685 | 45.28% |
| AUTO | 6,079 | 2,700 | 44.42% |
| CREDIT_CARD | 6,080 | 2,690 | 44.24% |
| PERSONAL | 5,983 | 2,629 | 43.94% |
| BNPL | 5,928 | 2,580 | 43.52% |

CONSUMER has the highest observed recovery rate at 45.28%.

BNPL has the lowest observed recovery rate at 43.52%.

The difference between the highest and lowest observed loan-type recovery rates is relatively small at 1.76 percentage points.

Loan type therefore does not appear to create a large separation in observed recovery rate in this portfolio.

---

## 6. Recovery by Risk Segment

Observed recovery rates:

| Risk Segment | Accounts | Recovered | Recovery Rate |
|---|---:|---:|---:|
| LOW | 7,513 | 3,381 | 45.00% |
| MEDIUM | 7,533 | 3,335 | 44.27% |
| NPA | 7,402 | 3,268 | 44.15% |
| HIGH | 7,552 | 3,300 | 43.70% |

LOW-risk accounts have the highest observed recovery rate at 45.00%.

HIGH-risk accounts have the lowest observed recovery rate at 43.70%.

The observed difference is modest at 1.30 percentage points.

Risk segment should therefore be treated as an important portfolio characteristic when interpreting collection-exposure patterns, but the analysis does not establish causality.

---

## 7. Recovery by DPD

Observed recovery rates by exact DPD values:

| DPD | Accounts | Recovered | Recovery Rate |
|---:|---:|---:|---:|
| 0 | 2,685 | 1,220 | 45.44% |
| 1 | 2,713 | 1,161 | 42.79% |
| 5 | 2,727 | 1,222 | 44.81% |
| 15 | 2,736 | 1,178 | 43.06% |
| 30 | 2,704 | 1,158 | 42.83% |
| 45 | 2,744 | 1,257 | 45.81% |
| 60 | 2,770 | 1,267 | 45.74% |
| 75 | 2,741 | 1,215 | 44.33% |
| 90 | 2,727 | 1,221 | 44.77% |
| 120 | 2,759 | 1,225 | 44.40% |
| 180 | 2,694 | 1,160 | 43.06% |

Recovery rates vary across DPD levels but do not show a strong monotonic pattern.

The observed range is approximately 42.79% to 45.81%.

Therefore, DPD does not provide a strong standalone separation of recovery outcomes in this dataset.

---

## 8. Recovery by Call Exposure

Observed results using the driver-analysis call bands:

| Call Exposure | Accounts | Recovered | Recovery Rate |
|---|---:|---:|---:|
| 0 calls | 1,592 | 688 | 43.22% |
| 1-2 calls | 11,045 | 4,859 | 43.99% |
| 3-4 calls | 11,815 | 5,242 | 44.37% |
| 5+ calls | 5,548 | 2,495 | 44.97% |

The larger call-exposure groups show a modest increase in observed recovery rate:

43.22% → 43.99% → 44.37% → 44.97%.

This indicates a modest positive observed association between call exposure and recovery rate.

However, this should not be interpreted as proof that additional calls cause higher recovery.

Collection activity may itself be influenced by account characteristics, delinquency, borrower risk, or collection strategy.

The exact high-call groups also become very small:

- 9 calls: 78 accounts
- 10 calls: 25 accounts
- 11 calls: 7 accounts
- 12 calls: 2 accounts
- 13 calls: 1 account

These very small groups should not be used for strong operational conclusions.

---

## 9. Recovery by Attempt Exposure

Recovery should also be evaluated against collection-attempt exposure.

The analysis uses the following bands:

- 0 attempts
- 1-2 attempts
- 3-5 attempts
- 6+ attempts

Observed differences should be interpreted descriptively.

Higher attempt exposure does not establish that additional attempts cause higher recovery because collection attempts may be targeted toward accounts with different underlying characteristics.

---

## 10. Recovery by Agent Exposure

Observed recovery rates:

| Agent Count | Accounts | Recovered | Recovery Rate |
|---:|---:|---:|---:|
| 0 | 1,695 | 728 | 42.95% |
| 1 | 4,572 | 2,013 | 44.03% |
| 2 | 6,799 | 2,975 | 43.76% |
| 3 | 6,758 | 3,007 | 44.50% |
| 4 | 4,945 | 2,202 | 44.53% |
| 5 | 2,881 | 1,271 | 44.12% |
| 6 | 1,419 | 647 | 45.60% |
| 7 | 612 | 284 | 46.41% |
| 8 | 224 | 112 | 50.00% |

The larger groups generally remain around the mid-40% recovery range.

The very high agent-exposure groups are small:

- 9 agents: 65 accounts
- 10 agents: 20 accounts
- 11 agents: 7 accounts
- 12 agents: 2 accounts
- 13 agents: 1 account

These groups should not be used to claim that additional agents cause higher recovery.

---

## 11. Recovery by Campaign Exposure

Observed recovery rates:

| Campaigns | Accounts | Recovered | Recovery Rate |
|---:|---:|---:|---:|
| 0 | 6,656 | 2,996 | 45.01% |
| 1 | 10,109 | 4,356 | 43.09% |
| 2 | 7,658 | 3,454 | 45.10% |
| 3 | 3,691 | 1,631 | 44.19% |
| 4 | 1,368 | 610 | 44.59% |
| 5 | 388 | 169 | 43.56% |
| 6 | 108 | 60 | 55.56% |

The 7- and 8-campaign groups are too small for strong conclusions:

- 7 campaigns: 19 accounts
- 8 campaigns: 3 accounts

The larger campaign groups remain broadly within the mid-40% recovery range.

Therefore, the data does not establish a reliable causal campaign-effect relationship.

---

## 12. Recovery by Vendor Exposure

Observed recovery rates:

| Vendors | Accounts | Recovered | Recovery Rate |
|---:|---:|---:|---:|
| 0 | 1,592 | 688 | 43.22% |
| 1 | 4,902 | 2,177 | 44.41% |
| 2 | 7,615 | 3,282 | 43.10% |
| 3 | 7,409 | 3,304 | 44.59% |
| 4 | 4,846 | 2,166 | 44.70% |
| 5 | 2,438 | 1,106 | 45.37% |
| 6 | 925 | 422 | 45.62% |
| 7 | 218 | 108 | 49.54% |
| 8 | 46 | 25 | 54.35% |

The larger vendor-exposure groups show a modest upward pattern in observed recovery rates.

However, the 8-vendor group contains only 46 accounts.

The 9- and 10-vendor groups are extremely small:

- 9 vendors: 8 accounts
- 10 vendors: 1 account

These groups should not be used for strong operational conclusions.

The results describe association only and do not establish that additional vendors cause higher recovery.

---

## 13. Recovery by Targeting Exposure

Observed targeting results:

| Targeted | Accounts | Recovered | Recovery Rate |
|---|---:|---:|---:|
| No | 6,656 | 2,996 | 45.01% |
| Yes | 23,344 | 10,288 | 44.07% |

Targeted accounts have an observed recovery rate of 44.07%, compared with 45.01% for non-targeted accounts.

This is an observed difference of approximately **-0.94 percentage points**.

This result should **not** be interpreted as evidence that targeting reduces recovery.

Targeting may have been directed toward accounts with different risk, delinquency, or collection characteristics.

Therefore, the targeting result should be treated as an area for further investigation rather than a causal finding.

---

## 14. Key Business Observations

### Observation 1 — Overall recovery is approximately 44%

The portfolio recovery rate is 44.28%, meaning that 13,284 of the 30,000 accounts have a positive recovery outcome under the defined recovery rule.

### Observation 2 — The sustained 11% improvement claim is not supported

March 2026 showed:

- +11.32% recovered accounts
- +11.03% recovery amount

However, subsequent complete months did not maintain an 11% improvement.

Therefore, the evidence supports a March improvement rather than a sustained 11% month-on-month trend.

### Observation 3 — Risk differences are modest

Recovery rates range from 43.70% for HIGH risk to 45.00% for LOW risk.

The difference is only 1.30 percentage points.

### Observation 4 — Call exposure shows a modest observed association

Recovery increases from 43.22% among accounts with no calls to 44.97% among accounts with 5+ calls.

This is an observed association and does not establish that additional calls cause recovery.

### Observation 5 — Agent exposure shows a similar modest pattern

The larger agent-exposure groups remain broadly around the mid-40% recovery range.

Very high agent-count groups are too small for strong conclusions.

### Observation 6 — Vendor exposure shows a modest observed pattern

Recovery generally increases across the larger vendor-exposure groups, but the highest-exposure groups have very small samples.

### Observation 7 — Targeting does not show a positive observed difference

Targeted accounts have a 44.07% recovery rate compared with 45.01% for non-targeted accounts.

This should not be interpreted as evidence that targeting causes lower recovery.

### Observation 8 — Loan-type differences are relatively small

The highest loan-type recovery rate is 45.28% and the lowest is 43.52%.

### Observation 9 — Small high-exposure groups require caution

Agent, campaign, and vendor exposure groups with very few accounts should not be used to make strong portfolio-wide decisions.

---

## 15. Investment Case

The investment analysis evaluates potential operational improvements using scenario-based estimates.

The analysis does not claim that the observed relationships are causal.

The ₹10 Cr investment case therefore should be treated as a **scenario and validation framework**, not as a guaranteed financial return.

The final investment recommendation is:

> **Pilot first — do not commit the full ₹10 Cr until incremental recovery is validated.**

The investment analysis explicitly avoids inventing implementation costs where the source data does not provide them.

The scenario analysis should therefore be used to identify which opportunities warrant controlled testing before full-scale investment.

---

## 16. Analytical Limitations

The analysis is primarily descriptive.

The current results do not establish:

- causal impact of calls
- causal impact of agents
- causal impact of campaigns
- causal impact of vendors
- causal impact of targeting
- optimal number of collection attempts
- incremental recovery caused by a particular intervention
- guaranteed financial return from the ₹10 Cr investment

Collection exposure may be correlated with borrower risk, delinquency, portfolio characteristics, or collection strategy.

The monthly recovery analysis is limited by the available payment activity period, which runs from January 1, 2026 through August 8, 2026.

August is a partial month and should not be compared directly with complete months.

Very small exposure groups also create unstable recovery-rate estimates.

Further causal or statistical analysis would be required before using these relationships to establish operational causality.

---

## 17. Recommended Business Use

The analysis can be used to:

1. Monitor portfolio recovery performance.
2. Compare recovery outcomes across portfolio segments.
3. Evaluate month-on-month recovery movements.
4. Identify collection-exposure patterns for further investigation.
5. Support operational dashboarding.
6. Identify areas where controlled experiments or deeper statistical analysis may be useful.
7. Support pilot design for potential collection-operations investments.

The recommended approach is to validate promising operational interventions through controlled pilots before making large-scale investment decisions.

---

## 18. Data Pipeline

Raw source data

→ Staging

→ Data Quality

→ Clean Tables

→ Account Recovery

→ Call Activity

→ Account Features

→ Metrics

→ Analysis

→ Investment Case

→ Dashboard / Business Findings

The `account_features` dataset is the final account-level analytical layer.