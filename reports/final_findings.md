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

Recovery amount is defined as the sum of valid SUCCESS payment amounts after
duplicate payment IDs have been removed.

FAILED, PENDING, and REVERSED payments are excluded from recovery.

The analysis evaluates recovery performance across:

- loan type
- risk segment
- DPD
- call exposure
- attempt exposure
- agent exposure
- campaign exposure
- vendor exposure
- targeting exposure
- call direction
- calling time
- required collection metrics
- statistical associations
- counterfactual investment scenarios

These results describe observed associations in the portfolio. They should not
be interpreted as causal effects without controlled experimental or
longitudinal validation.

---

## 2. Golden Dataset

The final account-level analytical dataset is:

`account_features`

Validation results:

| Check | Result |
|---|---:|
| Rows | 30,000 |
| Unique account IDs | 30,000 |
| NULL account IDs | 0 |
| Columns | 23 |

The dataset combines account attributes, recovery outcomes, and collection
activity features at account level.

---

## 3. Payment Data Quality Finding

The raw payment data contains:

| Check | Result |
|---|---:|
| Raw payment rows | 25,500 |
| Unique payment IDs | 25,000 |
| Duplicate payment IDs | 500 |
| Conflicting status values | 0 |
| Conflicting amount values | 0 |
| Conflicting timestamp values | 0 |

The duplicate payment records are therefore consistent duplicates rather than
records with conflicting business values.

The account recovery transformation retains one record per payment ID before
calculating account-level payment metrics.

The resulting account-level recovery amount is:

**₹1,315,583,964.64 (~₹131.56 Cr)**

Recovery amount includes SUCCESS payments only.

FAILED, PENDING, and REVERSED payments are excluded.

---

## 4. Month-on-Month Recovery and the 11% Claim

The claim that:

> "Recovery has improved by 11% month-on-month."

was tested using deduplicated SUCCESS payment activity.

The available payment activity covers:

**January 1, 2026 through August 8, 2026.**

August 2026 is treated as a partial month because payment activity is available
only through August 8, 2026.

Only comparable complete months are used when evaluating the sustained 11%
month-on-month claim.

The analysis does **not** support a sustained 11% month-on-month improvement.

### March 2026

March 2026 is the specific month in which approximately 11% growth is observed:

| Metric | February 2026 | March 2026 | MoM Change |
|---|---:|---:|---:|
| Recovered accounts | 2,173 | 2,419 | +11.32% |
| Recovery amount | ₹170.14M | ₹188.91M | +11.03% |
| Portfolio recovery rate | 7.24% | 8.06% | +0.82 pp |

However, April subsequently declined, and the remaining complete months did
not show another sustained 11% month-on-month increase.

### Recovery-Rate Denominators

Two monthly recovery-rate denominators are reported.

**Worked-account recovery rate**

Recovered accounts divided by accounts with payment activity in that month.

**Portfolio recovery rate**

Recovered accounts divided by the 30,000-account portfolio.

The worked-account recovery rate is approximately 71–72% during the complete
months.

This metric should not be compared directly with the overall 44.28% portfolio
recovery rate because the denominators are different.

The worked-account rate describes conversion among accounts that had payment
activity, while the portfolio recovery rate provides a broader portfolio-level
view.

### Verdict on the 11% Claim

**NOT SUPPORTED as a sustained month-on-month trend.**

March 2026 showed:

- +11.32% recovered accounts
- +11.03% recovery amount

However, this improvement was not sustained in subsequent complete months.

The monthly analysis found:

- 6 comparable FULL_MONTH MoM periods
- Only 1 period with at least 11% recovery-amount growth
- Only 1 period with at least 11% recovered-account growth
- Average recovery-amount MoM change: approximately +0.29%
- Average recovered-account MoM change: approximately -0.08%

August 2026 is excluded from the sustained-trend conclusion because it is a
PARTIAL_MONTH.

Supporting monthly analysis:

`outputs/monthly_recovery_trend.csv`

### Data Period Limitation

The available payment activity covers January 1, 2026 through August 8, 2026.

Therefore, the monthly recovery trend represents approximately seven complete
months plus a partial August period.

The analysis should not be described as a full 12-month recovery trend unless
additional collection-period data is available.

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

The difference between the highest and lowest observed loan-type recovery
rates is approximately **1.76 percentage points**.

Loan type therefore does not create a large separation in observed recovery
rate in this portfolio.

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

The observed difference is modest at **1.30 percentage points**.

Risk segment should therefore be treated as an important portfolio
characteristic when interpreting collection-exposure patterns, but the
analysis does not establish causality.

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

Recovery rates vary across DPD levels but do not show a strong monotonic
pattern.

The observed range is approximately 42.79% to 45.81%.

Therefore, DPD does not provide a strong standalone separation of recovery
outcomes in this dataset.

---

## 8. Recovery by Call Exposure

Observed results using the driver-analysis call bands:

| Call Exposure | Accounts | Recovered | Recovery Rate |
|---|---:|---:|---:|
| 0 calls | 1,592 | 688 | 43.22% |
| 1-2 calls | 11,045 | 4,859 | 43.99% |
| 3-4 calls | 11,815 | 5,242 | 44.37% |
| 5+ calls | 5,548 | 2,495 | 44.97% |

The larger call-exposure groups show a modest increase in observed recovery
rate:

**43.22% → 43.99% → 44.37% → 44.97%**

This indicates a modest positive observed association between call exposure
and recovery rate.

However, this should not be interpreted as proof that additional calls cause
higher recovery.

Collection activity may itself be influenced by account characteristics,
delinquency, borrower risk, or collection strategy.

Very high call-count groups are small:

| Calls | Accounts |
|---:|---:|
| 9 | 78 |
| 10 | 25 |
| 11 | 7 |
| 12 | 2 |
| 13 | 1 |

These groups should not be used for strong operational conclusions.

---

## 9. Recovery by Attempt Exposure

Recovery should also be evaluated against collection-attempt exposure.

The analysis uses:

- 0 attempts
- 1-2 attempts
- 3-5 attempts
- 6+ attempts

Observed differences should be interpreted descriptively.

Higher attempt exposure does not establish that additional attempts cause higher
recovery because collection attempts may be targeted toward accounts with
different underlying characteristics.

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

Very high agent-exposure groups are small:

- 9 agents: 65 accounts
- 10 agents: 20 accounts
- 11 agents: 7 accounts
- 12 agents: 2 accounts
- 13 agents: 1 account

These groups should not be used to claim that additional agents cause higher
recovery.

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

Therefore, the data does not establish a reliable causal campaign-effect
relationship.

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

The larger vendor-exposure groups show a modest upward pattern in observed
recovery rates.

However, the 8-vendor group contains only 46 accounts.

The 9- and 10-vendor groups are extremely small:

- 9 vendors: 8 accounts
- 10 vendors: 1 account

These groups should not be used for strong operational conclusions.

The results describe association only and do not establish that additional
vendors cause higher recovery.

---

## 13. Recovery by Targeting Exposure

Observed targeting results:

| Targeted | Accounts | Recovered | Recovery Rate |
|---|---:|---:|---:|
| No | 6,656 | 2,996 | 45.01% |
| Yes | 23,344 | 10,288 | 44.07% |

Targeted accounts have an observed recovery rate of 44.07%, compared with
45.01% for non-targeted accounts.

This is an observed difference of approximately **-0.94 percentage points**.

This result should **not** be interpreted as evidence that targeting reduces
recovery.

Targeting may have been directed toward accounts with different risk,
delinquency, or collection characteristics.

Therefore, the targeting result should be treated as an area for further
investigation rather than a causal finding.

---

## 14. Call Direction and Calling Time

The dataset contains call direction and call timestamps, allowing additional
telephony analysis.

Observed call direction:

- OUTBOUND: 84,151 calls
- INBOUND: 7,199 calls

Recovery by call direction:

| Direction | Accounts | Recovered | Recovery Rate |
|---|---:|---:|---:|
| INBOUND | 6,322 | 2,753 | 43.55% |
| OUTBOUND | 28,035 | 12,447 | 44.40% |

The observed difference is approximately **+0.85 percentage points** for
outbound-exposed accounts.

Calling time was grouped into four six-hour bands:

| Calling Time | Accounts | Recovered | Recovery Rate |
|---|---:|---:|---:|
| 00-05 | 15,875 | 7,024 | 44.25% |
| 06-11 | 15,879 | 7,070 | 44.52% |
| 12-17 | 15,656 | 6,957 | 44.44% |
| 18-23 | 15,801 | 7,020 | 44.43% |

Calling-time recovery rates are tightly clustered around 44.3–44.5%.

Therefore, the available calling-time analysis does not show a strong
standalone separation in recovery outcomes.

Neither call direction nor calling time establishes a causal effect.

---

## 15. Required Collection Metrics

The project defines and calculates the required collection metrics where the
supplied data supports them.

| Metric | Result |
|---|---:|
| Contact Rate | 25.90% |
| RPC Rate | 22.57% |
| PTP Rate | 36.78% |
| PTP Kept Rate | 24.94% |
| Recovery Rate | 44.28% |
| Recovery per Account | ₹99,035.23 |
| Recovery per Agent-Hour | ₹16,680.22 |
| Cost per ₹ Recovered | Not estimable |
| SMS Conversion | 24.25% |
| WhatsApp Conversion | 18.69% |

### Contact Rate

`contacted calls / total calls`

### RPC

`RPC calls / total calls`

### PTP Rate

`PTP calls / RPC calls`

### PTP Kept Rate

`kept PTPs / total PTPs`

### Recovery Rate

`recovered accounts / total portfolio accounts`

### Recovery per Account

`SUCCESS recovery amount / recovered accounts`

### Recovery per Agent-Hour

`SUCCESS recovery amount / recorded agent hours`

This is an operational productivity metric and should not be interpreted as
causal ROI.

### Cost per ₹ Recovered

**Not estimable from supplied data.**

No reliable collection/intervention cost field is available.

A production implementation would require reliable operational cost data such
as:

- agent labor cost
- telephony cost
- vendor cost
- messaging cost
- campaign cost
- other intervention costs

### Channel Conversion

| Channel | Sent | Delivered | Conversion Events | Delivery Rate | Conversion Rate |
|---|---:|---:|---:|---:|---:|
| SMS | 9,899 | 9,789 | 2,374 | 98.89% | 24.25% |
| WHATSAPP | 9,168 | 8,944 | 1,672 | 97.56% | 18.69% |

These are channel-level observed conversion metrics and do not establish
causal superiority of one channel.

---

## 16. Statistical Analysis

Statistical analysis was performed to distinguish observed associations from
random variation.

The categorical tests included:

- Loan type
- Risk segment
- Account status
- DPD bucket

The analysis found that DPD bucket showed a statistically significant
association at the 5% level before interpretation of effect size and
multiple-testing context.

Other tested categorical dimensions did not show statistically significant
evidence at the 5% level.

The statistical analysis also includes numeric driver testing and model-based
association analysis.

The statistical analysis explicitly avoids causal claims.

---

## 17. Key Business Observations

### Observation 1 — Overall recovery is approximately 44%

The portfolio recovery rate is 44.28%, meaning that 13,284 of the 30,000
accounts have a positive recovery outcome under the defined recovery rule.

### Observation 2 — The sustained 11% improvement claim is not supported

March 2026 showed:

- +11.32% recovered accounts
- +11.03% recovery amount

However, subsequent complete months did not maintain an 11% improvement.

Therefore, the evidence supports a March improvement rather than a sustained
11% month-on-month trend.

### Observation 3 — Risk differences are modest

Recovery rates range from 43.70% for HIGH risk to 45.00% for LOW risk.

The difference is only 1.30 percentage points.

### Observation 4 — Call exposure shows a modest observed association

Recovery increases from 43.22% among accounts with no calls to 44.97% among
accounts with 5+ calls.

This is an observed association and does not establish that additional calls
cause recovery.

### Observation 5 — Agent exposure shows a similar modest pattern

The larger agent-exposure groups remain broadly around the mid-40% recovery
range.

Very high agent-count groups are too small for strong conclusions.

### Observation 6 — Vendor exposure shows a modest observed pattern

Recovery generally increases across the larger vendor-exposure groups, but the
highest-exposure groups have very small samples.

### Observation 7 — Targeting does not show a positive observed difference

Targeted accounts have a 44.07% recovery rate compared with 45.01% for
non-targeted accounts.

This should not be interpreted as evidence that targeting causes lower
recovery.

### Observation 8 — Loan-type differences are relatively small

The highest loan-type recovery rate is 45.28% and the lowest is 43.52%.

### Observation 9 — Small high-exposure groups require caution

Agent, campaign, and vendor exposure groups with very few accounts should not
be used to make strong portfolio-wide decisions.

### Observation 10 — Calling time does not show a strong separation

Recovery rates across the four calling-time bands range only from 44.25% to
44.52%.

---

## 18. ₹10 Cr Investment Case

The investment case uses the corrected Stage 7 counterfactual analysis.

### Baseline

- Portfolio accounts: 30,000
- Recovered accounts: 13,284
- Baseline recovery rate: 44.28%
- SUCCESS-based recovery amount: ₹1,315,583,964.64 (~₹131.56 Cr)
- Outstanding portfolio amount: ₹10,489,040,000 (~₹104.89 Cr)

### Telephony Scenario

The Stage 7 telephony scenario reports:

- Modeled telephony effect: **+1.076249 percentage points**
- Modeled incremental recovery: **₹112,888,100 (~₹11.29 Cr)**
- Modeled incremental recovered accounts: **approximately 322.87**

These are model-based counterfactual estimates and are **not causal
estimates**.

### ₹10 Cr Break-Even

The investment scenario is:

**₹100,000,000 / ₹10 Cr**

The required recovery uplift to break even is:

**+0.953377 percentage points**

The modeled telephony effect is:

**+1.076249 percentage points**

Therefore:

**Modeled margin above break-even = +0.122872 percentage points**

The modeled telephony scenario therefore clears the mathematical ₹10 Cr
break-even threshold.

However, clearing the modeled threshold does **not** mean that the investment
should automatically be approved.

The observed data is not sufficient to establish that the modeled +1.076249 pp
uplift will actually occur after implementation.

### Downside / Base / Upside

The investment model uses sensitivity scenarios:

- Downside: 50% of modeled telephony effect
- Base: 100% of modeled telephony effect
- Upside: 125% of modeled telephony effect

These are sensitivity assumptions rather than observed outcomes.

### Investment Recommendation

> **Pilot first — do not commit the full ₹10 Cr until incremental recovery is validated.**

A controlled telephony pilot should measure incremental recovery against a
comparable control group before full-scale deployment.

The pilot should establish:

- incremental recovery rate
- incremental recovery amount
- cost per incremental ₹ recovered
- confidence interval around uplift
- treatment/control comparability
- operational scalability

Only after these measures are validated should the full ₹10 Cr investment be
considered.

---

## 19. Analytical Limitations

The analysis is primarily descriptive.

The current results do not establish:

- causal impact of calls
- causal impact of agents
- causal impact of campaigns
- causal impact of vendors
- causal impact of targeting
- causal impact of call timing
- causal impact of call direction
- optimal number of collection attempts
- incremental recovery caused by a particular intervention
- guaranteed financial return from the ₹10 Cr investment

Collection exposure may be correlated with borrower risk, delinquency,
portfolio characteristics, or collection strategy.

The monthly recovery analysis is limited by the available payment activity
period, which runs from January 1, 2026 through August 8, 2026.

August is a partial month and should not be compared directly with complete
months.

Very small exposure groups also create unstable recovery-rate estimates.

Further causal or experimental analysis would be required before using these
relationships to establish operational causality.

---

## 20. Recommended Business Use

The analysis can be used to:

1. Monitor portfolio recovery performance.
2. Compare recovery outcomes across portfolio segments.
3. Evaluate month-on-month recovery movements.
4. Identify collection-exposure patterns for further investigation.
5. Support operational dashboarding.
6. Identify areas where controlled experiments or deeper statistical analysis
   may be useful.
7. Support pilot design for potential collection-operations investments.
8. Monitor the required collection metrics.
9. Evaluate the ₹10 Cr investment hypothesis before committing capital.

The recommended approach is to validate promising operational interventions
through controlled pilots before making large-scale investment decisions.

---

## 21. Data Pipeline

```text
Raw Data
   ↓
Staging
   ↓
Data Quality
   ↓
Clean Tables
   ↓
Account Recovery
   ↓
Call Activity
   ↓
Account Features
   ↓
Metrics
   ↓
Analysis
   ↓
Counterfactual Analysis
   ↓
Investment Case
   ↓
Dashboard / Business Findings