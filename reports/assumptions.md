\# CredResolve Collections Recovery Analytics

\# Assumptions and Analytical Decisions



\## 1. Account-Level Analytical Grain



The final analytical dataset is maintained at one record per account.



The primary analytical key is:



`account\_id`



The final `account\_features` dataset was validated to contain:



\- 30,000 rows

\- 30,000 unique account IDs

\- 0 NULL account IDs



\---



\## 2. Recovery Definition



An account is classified as recovered when it has at least one payment with:



`payment\_status = 'SUCCESS'`



The analytical field is:



`recovered\_account`



where:



\- `1` = at least one successful payment

\- `0` = no successful payment



\---



\## 3. Recovery Amount



Recovery amount is calculated from valid payment records after payment-ID

deduplication.



The account-level field is:



`total\_payment\_amount`



\---



\## 4. Duplicate Payment Treatment



The raw payment data contains 500 duplicate payment IDs.



Duplicate payment IDs were checked for:



\- payment status conflicts

\- amount conflicts

\- event timestamp conflicts



No conflicting values were found for these attributes.



The duplicates are therefore treated as duplicate/re-ingested records.



One record per `payment\_id` is retained during the account recovery

transformation.



The clean source table itself is not modified to perform this downstream

deduplication.



\---



\## 5. Source Data Preservation



Raw and cleaned source data are preserved.



Transformations create analytical tables/views rather than modifying the raw

source data.



This supports reproducibility and auditability.



\---



\## 6. Missing Activity Treatment



When an account has no corresponding call, attempt, disposition, or targeting

activity, activity metrics are represented as zero in the final account-level

feature dataset.



This allows accounts with no observed collection activity to remain in the

analysis.



\---



\## 7. Call Exposure



An account is considered call-exposed when:



`total\_calls > 0`



The resulting field is:



`call\_exposed`



\---



\## 8. Attempt Exposure



An account is considered attempt-exposed when:



`total\_attempts > 0`



The resulting field is:



`attempt\_exposed`



\---



\## 9. Targeting Exposure



An account is considered targeted when:



`targeting\_events > 0`



The resulting field is:



`targeted\_account`



\---



\## 10. Exposure Buckets



Call exposure is grouped into:



\- `0-2 calls`

\- `3-4 calls`

\- `5+ calls`



These buckets are used for descriptive portfolio analysis.



\---



\## 11. Risk Segment



The existing risk-segment classification in the source/account layer is used

without inventing new risk classifications.



\---



\## 12. DPD



Days past due (`dpd`) is treated as the account's delinquency measure.



It is used for descriptive portfolio comparisons and DPD-band analysis.



\---



\## 13. Small Exposure Groups



Very small groups, particularly groups with only a few accounts, are not

treated as strong evidence.



Their recovery rates may be highly sensitive to individual accounts.



\---



\## 14. Causal Interpretation



The analysis is descriptive.



Higher recovery rates observed among accounts with greater collection

exposure do not prove that the collection activity caused the higher recovery

rate.



Collection activity may be related to borrower characteristics, delinquency,

risk, account status, or collection strategy.



Causal conclusions would require additional statistical or experimental

analysis.



\---



\## 15. Metric Reproducibility



Business metrics are calculated from the account-level analytical dataset.



The SQL transformation and analysis layers are retained so that the results

can be reproduced.



\---



\## 16. Golden Dataset



`account\_features` is treated as the final account-level analytical dataset.



It contains account attributes, recovery outcomes, and collection activity

features required for the downstream analysis and dashboard.



\---



\## 17. Reporting Precision



Currency and aggregate financial values are rounded for presentation where

appropriate.



Underlying analytical calculations retain their available numeric precision.



\---



\## 18. Analytical Scope



The current analysis focuses on:



\- recovery performance

\- portfolio characteristics

\- loan type

\- risk segment

\- account status

\- DPD

\- call exposure

\- agent exposure

\- campaign exposure

\- vendor exposure



The analysis does not claim to estimate causal treatment effects or an optimal

collection strategy.

