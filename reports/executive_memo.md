\# CredResolve Collections Recovery Analytics

\# Executive Memo



\## Executive Summary



CredResolve's collections portfolio contains 30,000 analyzed accounts.



The final account-level analytical dataset shows:



\- 30,000 accounts analyzed

\- 13,284 recovered accounts

\- 16,716 unrecovered accounts

\- 44.28% overall recovery rate

\- Approximately 1.879 billion in total recovery amount



The analysis evaluates recovery performance across portfolio characteristics

and collection-exposure dimensions.



The results show relatively modest differences across loan type and risk

segment, while collection-exposure groups show somewhat higher observed

recovery rates at higher exposure levels.



These relationships are observational and should not be interpreted as proof

that additional collection activity causes higher recovery.





\## Business Problem



The objective of the analysis is to understand recovery performance across the

collections portfolio and identify measurable relationships between recovery

outcomes and collection activity.



The analysis is designed to support:



\- portfolio monitoring

\- recovery performance measurement

\- collection strategy investigation

\- operational reporting

\- identification of areas for further statistical investigation





\## Analytical Approach



The analysis follows a reproducible SQL-based pipeline:



Raw Data

→ Staging

→ Data Quality

→ Clean Tables

→ Account Recovery

→ Call Activity

→ Account Features

→ Metrics

→ Analysis

→ Business Findings



The final analytical grain is one record per account.



The golden dataset is:



`account\_features`





\## Data Quality



The payment data contains 25,500 raw rows and 25,000 unique payment IDs.



There are 500 duplicate payment IDs.



The duplicate IDs were investigated and showed:



\- 0 conflicting payment statuses

\- 0 conflicting payment amounts

\- 0 conflicting event timestamps



The duplicates are therefore treated as duplicate/re-ingested records.



One record per payment ID is retained during the account recovery

transformation.



The final golden dataset contains:



\- 30,000 rows

\- 30,000 unique account IDs

\- 0 NULL account IDs





\## Portfolio Performance



Overall recovery rate:



\*\*44.28%\*\*



Recovered accounts:



\*\*13,284\*\*



Unrecovered accounts:



\*\*16,716\*\*



Total recovery amount:



\*\*Approximately 1.879 billion\*\*





\## Loan-Type Findings



Observed recovery rates:



| Loan Type | Recovery Rate |

|---|---:|

| CONSUMER | 45.28% |

| AUTO | 44.42% |

| CREDIT\_CARD | 44.24% |

| PERSONAL | 43.94% |

| BNPL | 43.52% |



CONSUMER has the highest observed recovery rate.



BNPL has the lowest observed recovery rate.



The overall range is relatively narrow, indicating that loan type alone does

not produce a large separation in recovery performance in this portfolio.





\## Risk-Segment Findings



Observed recovery rates:



| Risk Segment | Recovery Rate |

|---|---:|

| LOW | 45.00% |

| MEDIUM | 44.27% |

| NPA | 44.15% |

| HIGH | 43.70% |



LOW risk accounts have the highest observed recovery rate.



HIGH risk accounts have the lowest observed recovery rate.



The difference is modest, suggesting that risk segment alone is not sufficient

to explain the majority of observed recovery variation.





\## Collection-Exposure Findings



\### Call Exposure



| Call Exposure | Recovery Rate |

|---|---:|

| 0-2 calls | 43.89% |

| 3-4 calls | 44.37% |

| 5+ calls | 44.97% |



There is a modest upward association between call exposure and observed

recovery rate.



The difference between the lowest and highest call-exposure groups is:



\*\*1.08 percentage points\*\*





\### Agent Exposure



Recovery rates generally remain around the mid-40% range across the main

agent-exposure groups.



Higher observed recovery rates appear in some higher-exposure groups, but

groups with very high agent counts contain few accounts.



Those small groups should therefore not be used as strong evidence.





\### Campaign Exposure



Recovery rates generally remain in the mid-40% range.



The observed rate increases from 43.22% for accounts with no campaign exposure

to 49.56% for accounts with eight campaigns.



Very high campaign-count groups contain very few accounts and require caution.





\### Vendor Exposure



Recovery rates generally increase across several of the main vendor-exposure

groups.



For example:



\- 0 vendors: 43.22%

\- 3 vendors: 44.59%

\- 5 vendors: 45.37%

\- 7 vendors: 49.54%

\- 8 vendors: 54.35%



The higher vendor-count groups are much smaller, so these rates should be

treated as descriptive rather than definitive.





\## Key Business Insights



\### 1. Portfolio recovery is approximately 44%



Less than half of the analyzed accounts are classified as recovered under the

defined recovery rule.



This provides a clear baseline KPI for portfolio monitoring.



\### 2. Loan-type differences are relatively small



The observed recovery-rate range across loan types is approximately 1.76

percentage points.



This suggests that portfolio-wide recovery variation is not strongly separated

by loan type alone.



\### 3. Risk-segment differences are also modest



The observed difference between LOW and HIGH risk segments is approximately

1.30 percentage points.



This indicates that additional account and collection characteristics should

be considered when investigating recovery variation.



\### 4. Collection exposure has a modest positive observed association



The 5+ call group has a 44.97% recovery rate compared with 43.89% for the

0-2 call group.



This relationship should be investigated further rather than interpreted as

causal.





\## Recommendations



\### Recommendation 1 — Use the 44.28% recovery rate as a baseline KPI



Track recovery rate and recovery amount consistently across future portfolio

periods.



\### Recommendation 2 — Investigate collection exposure more deeply



The observed increase in recovery rates at higher exposure levels provides a

useful hypothesis for further analysis.



A controlled or statistical approach should be used before changing collection

policy.



\### Recommendation 3 — Avoid decisions based on tiny exposure groups



Agent, campaign, and vendor groups with very few accounts should not drive

portfolio-wide decisions.



\### Recommendation 4 — Combine portfolio and activity characteristics



Loan type and risk segment alone show relatively small differences.



A more advanced model could evaluate the combined effect of:



\- DPD

\- outstanding amount

\- risk segment

\- loan type

\- call exposure

\- attempts

\- agents

\- campaigns

\- vendors

\- targeting activity



\### Recommendation 5 — Consider causal/statistical follow-up



Future analysis could use statistical modeling or controlled experimentation to

determine whether collection activity has incremental causal impact on

recovery.





\## Limitations



This analysis is primarily descriptive.



It does not establish:



\- causal impact of calls

\- causal impact of agents

\- causal impact of campaigns

\- causal impact of vendors

\- optimal collection frequency

\- optimal agent assignment

\- optimal campaign strategy



Collection activity may be correlated with borrower risk, DPD, account

status, or other operational decisions.





\## Final Conclusion



The CredResolve analytical pipeline produces a validated account-level golden

dataset containing 30,000 unique accounts.



The portfolio has a 44.28% observed recovery rate and approximately 1.879

billion in recovery amount.



Loan type and risk segment show relatively modest differences in recovery

performance.



Collection exposure shows somewhat stronger descriptive variation, with higher

observed recovery rates among several higher-exposure groups.



The strongest next analytical opportunity is therefore to investigate whether

these exposure relationships remain after controlling for account-level risk,

DPD, outstanding balance, and other portfolio characteristics.



The current analysis provides a reproducible foundation for dashboarding,

portfolio monitoring, and further statistical investigation.

