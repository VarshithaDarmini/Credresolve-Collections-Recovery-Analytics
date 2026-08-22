\# CredResolve Collections Recovery Analytics

\# Data Quality Report



\## 1. Purpose



This report documents the data-quality validation performed before creating

the final account-level analytical dataset.



The objective is to identify duplicate, conflicting, missing, or structurally

invalid records that could affect recovery analysis.



\---



\## 2. Payment Data Validation



\### Raw Payment Volume



| Check | Result |

|---|---:|

| Raw payment rows | 25,500 |

| Unique payment IDs | 25,000 |

| Duplicate payment IDs | 500 |



There are 500 payment IDs that occur more than once in the raw payment data.



\---



\## 3. Duplicate Payment Investigation



The duplicated payment IDs were checked for conflicting business attributes.



| Validation | Result |

|---|---:|

| Duplicate IDs with conflicting status | 0 |

| Duplicate IDs with conflicting amount | 0 |

| Duplicate IDs with conflicting timestamp | 0 |



Therefore, the duplicate payment IDs do not show conflicting payment status,

amount, or event timestamp values.



The duplicates are treated as duplicate/re-ingested records.



\---



\## 4. Duplicate Handling



Payment records are deduplicated at `payment\_id` level in the account recovery

transformation.



The transformation retains one record per payment ID before calculating

account-level payment metrics.



This prevents duplicated payment records from being counted multiple times in

the recovery amount.



The deduplication logic is implemented in:



`sql/transformations/01\_account\_recovery.sql`



\---



\## 5. Recovery Amount Validation



The deduplicated payment amount used by the account recovery layer is:



Approximately 1.879 billion.



The account recovery transformation produces the same aggregate recovery

amount used by the final account-level analytical dataset.



\---



\## 6. Golden Dataset Validation



The final analytical dataset is:



`account\_features`



Validation results:



| Check | Result |

|---|---:|

| Total rows | 30,000 |

| Unique account IDs | 30,000 |

| Duplicate account IDs | 0 |

| NULL account IDs | 0 |

| Number of columns | 23 |



Therefore, the final account-level dataset contains exactly one analytical

record per account.



\---



\## 7. Final Recovery Validation



The final portfolio contains:



| Metric | Result |

|---|---:|

| Accounts analyzed | 30,000 |

| Recovered accounts | 13,284 |

| Unrecovered accounts | 16,716 |

| Recovery rate | 44.28% |

| Recovery amount | Approximately 1.879 billion |



\---



\## 8. Cleaning Impact



The payment cleaning process retained the same number of payment rows:



\- Raw payment rows: 25,500

\- Clean payment rows: 25,500



The duplicate-payment issue is therefore handled downstream during account

recovery aggregation rather than by removing rows from the clean payment table.



This preserves the cleaned source layer while ensuring that account-level

recovery metrics do not double-count duplicate payment IDs.



\---



\## 9. Golden Dataset Integrity



The following integrity checks passed:



\- Account IDs are present.

\- Account IDs are unique.

\- Account-level grain is maintained.

\- Recovery metrics are available.

\- Collection activity features are available.

\- The final dataset contains 30,000 account-level records.



\---



\## 10. Data Quality Conclusion



The final analytical dataset is structurally valid for the descriptive

recovery analysis performed in this project.



The primary data-quality issue identified was duplicate payment IDs.



Because duplicate payment IDs had no conflicting status, amount, or timestamp

values, they were treated as duplicate/re-ingested records and deduplicated

during the account recovery transformation.



No duplicate account IDs or NULL account IDs were found in the final golden

dataset.



\---



\## 11. Important Analytical Limitation



Data-quality validation does not establish causal relationships.



The recovery analysis describes observed portfolio patterns and collection

exposure associations. It does not establish that calls, agents, campaigns,

or vendors caused a change in recovery performance.

