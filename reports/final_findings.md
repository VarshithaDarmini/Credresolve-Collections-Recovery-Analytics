\# CredResolve Collections Recovery Analytics

\# Final Analytical Findings



\## 1. Executive Summary



The final analytical dataset contains 30,000 unique accounts.



Overall portfolio recovery performance:



\- Total accounts analyzed: 30,000

\- Recovered accounts: 13,284

\- Unrecovered accounts: 16,716

\- Overall recovery rate: 44.28%

\- Total recovery amount: approximately 1.879 billion



The analysis evaluates recovery performance across loan type, risk segment,

call exposure, agent exposure, campaign exposure, and vendor exposure.



These results describe observed associations in the portfolio. They should

not be interpreted as causal effects without additional experimental or

longitudinal analysis.





\## 2. Golden Dataset



The final account-level analytical dataset is:



`account\_features`



Validation results:



\- Rows: 30,000

\- Unique account IDs: 30,000

\- NULL account IDs: 0

\- Columns: 23



The dataset combines account attributes, recovery outcomes, and collection

activity features at account level.





\## 3. Payment Data Quality Finding



The raw payment data contains:



\- Raw payment rows: 25,500

\- Unique payment IDs: 25,000

\- Duplicate payment IDs: 500

\- Conflicting status values among duplicate IDs: 0

\- Conflicting amount values among duplicate IDs: 0

\- Conflicting timestamp values among duplicate IDs: 0



The duplicate payment records are therefore consistent duplicates rather than

records with conflicting business values.



The account recovery transformation retains one record per payment ID before

calculating account-level payment metrics.



The resulting account-level recovery amount is approximately:



1.879 billion





\## 4. Recovery by Loan Type



Observed recovery rates:



| Loan Type | Accounts | Recovered | Recovery Rate |

|---|---:|---:|---:|

| CONSUMER | 5,930 | 2,685 | 45.28% |

| AUTO | 6,079 | 2,700 | 44.42% |

| CREDIT\_CARD | 6,080 | 2,690 | 44.24% |

| PERSONAL | 5,983 | 2,629 | 43.94% |

| BNPL | 5,928 | 2,580 | 43.52% |



CONSUMER has the highest observed recovery rate at 45.28%.



BNPL has the lowest observed recovery rate at 43.52%.



The difference between the highest and lowest observed loan-type recovery

rates is relatively small, so loan type does not appear to create a large

separation in recovery rate in this portfolio.





\## 5. Recovery by Risk Segment



Observed recovery rates:



| Risk Segment | Accounts | Recovered | Recovery Rate |

|---|---:|---:|---:|

| LOW | 7,513 | 3,381 | 45.00% |

| MEDIUM | 7,533 | 3,335 | 44.27% |

| NPA | 7,402 | 3,268 | 44.15% |

| HIGH | 7,552 | 3,300 | 43.70% |



LOW risk accounts have the highest observed recovery rate at 45.00%.



HIGH risk accounts have the lowest observed recovery rate at 43.70%.



The observed difference is modest.





\## 6. Recovery by Call Exposure



Observed results:



| Call Exposure | Accounts | Recovered | Recovery Rate |

|---|---:|---:|---:|

| 0-2 calls | 12,637 | 5,547 | 43.89% |

| 3-4 calls | 11,815 | 5,242 | 44.37% |

| 5+ calls | 5,548 | 2,495 | 44.97% |



The observed recovery rate increases across the call-exposure bands:



43.89% → 44.37% → 44.97%.



This indicates a positive observed association between call exposure and

recovery rate in this dataset.



This should not be interpreted as proof that additional calls cause higher

recovery, because collection activity may itself be influenced by account

characteristics.





\## 7. Agent Exposure



Agent exposure shows the following broad pattern:



\- 0 agents: 42.95%

\- 1 agent: 44.03%

\- 2 agents: 43.76%

\- 3 agents: 44.50%

\- 4 agents: 44.53%

\- 5 agents: 44.12%

\- 6 agents: 45.60%

\- 7 agents: 46.41%

\- 8 agents: 50.00%



The larger agent-exposure groups generally show recovery rates around the

mid-40% range.



The groups with 9 or more agents contain very few accounts and should not be

used for strong conclusions.





\## 8. Campaign Exposure



Observed recovery rates generally remain in the mid-40% range.



Selected results:



\- 0 campaigns: 43.22%

\- 1 campaign: 44.16%

\- 2 campaigns: 43.88%

\- 3 campaigns: 43.95%

\- 4 campaigns: 44.99%

\- 5 campaigns: 44.12%

\- 6 campaigns: 45.22%

\- 7 campaigns: 46.49%

\- 8 campaigns: 49.56%



The results suggest a generally increasing observed recovery rate at higher

campaign exposure levels, although the relationship is not perfectly

monotonic.



Very high campaign-count groups contain very few accounts and should be

treated cautiously.





\## 9. Vendor Exposure



Observed recovery rates:



\- 0 vendors: 43.22%

\- 1 vendor: 44.41%

\- 2 vendors: 43.10%

\- 3 vendors: 44.59%

\- 4 vendors: 44.70%

\- 5 vendors: 45.37%

\- 6 vendors: 45.62%

\- 7 vendors: 49.54%

\- 8 vendors: 54.35%



The observed recovery rate generally increases at higher vendor exposure

levels, although the low-volume groups require caution.



The 9- and 10-vendor groups are too small to support strong conclusions.





\## 10. Key Business Observations



\### Observation 1 — Overall recovery is approximately 44%



The portfolio recovery rate is 44.28%, meaning that 13,284 of the 30,000

accounts have a positive recovery outcome under the defined recovery rule.



\### Observation 2 — Risk segment differences are modest



Recovery rates range from 43.70% for HIGH risk to 45.00% for LOW risk.



This suggests that risk segment alone does not create a large separation in

observed recovery outcomes in this dataset.



\### Observation 3 — Collection exposure shows a modest positive association



Accounts in the 5+ call group have a 44.97% recovery rate compared with

43.89% for accounts with 0-2 calls.



This is an observed association, not a causal conclusion.



\### Observation 4 — Loan-type differences are relatively small



The highest loan-type recovery rate is 45.28% and the lowest is 43.52%.



\### Observation 5 — Small high-exposure groups require caution



Some agent, campaign, and vendor exposure levels contain very few accounts.



These groups should not be used to make strong portfolio-wide decisions.





\## 11. Analytical Limitations



The analysis is primarily descriptive.



The current results do not establish:



\- causal impact of calls

\- causal impact of agents

\- causal impact of campaigns

\- causal impact of vendors

\- optimal number of collection attempts

\- incremental recovery caused by a particular intervention



Collection exposure may be correlated with borrower risk, delinquency,

portfolio characteristics, or collection strategy.



Further causal or statistical analysis would be required before using these

relationships to establish operational causality.





\## 12. Recommended Business Use



The analysis can be used to:



1\. Monitor portfolio recovery performance.

2\. Compare recovery outcomes across portfolio segments.

3\. Identify collection-exposure patterns for further investigation.

4\. Support operational dashboarding.

5\. Identify areas where controlled experiments or deeper statistical analysis

&#x20;  may be useful.





\## 13. Data Pipeline



Raw source data

→ Staging

→ Data Quality

→ Clean Tables

→ Account Recovery

→ Call Activity

→ Account Features

→ Metrics

→ Analysis

→ Dashboard / Business Findings



The `account\_features` dataset is the final account-level analytical layer.

