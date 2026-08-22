# CredResolve Collections Recovery Analytics

# Data Quality Report

## 1. Purpose

This report documents the data-quality investigations performed before using the data for recovery, driver, statistical, counterfactual, and investment analysis.

The objective is to identify data issues that could materially distort business conclusions and document:

1. Major data issues
2. Detection methodology
3. Treatment
4. Business impact

The final analytical grain is **one record per account**.

---

## 2. Data Quality Summary

| Area | Finding | Status |
|---|---|---|
| Payment duplicates | 500 duplicate payment IDs | Investigated and deduplicated |
| Conflicting duplicate status | 0 | No conflict found |
| Conflicting duplicate amount | 0 | No conflict found |
| Conflicting duplicate timestamp | 0 | No conflict found |
| Final account duplicates | 0 | Pass |
| NULL account IDs | 0 | Pass |
| Final account records | 30,000 | Pass |
| SUCCESS-only recovery | Applied | Pass |
| Partial August data | August ends Aug 8 | Excluded from full-month trend conclusion |
| Cost per ₹ recovered | Cost field unavailable | Not estimable |
| **Borrower identity conflicts** | **73.3% of borrower_ids have conflicting city/state across rows** | **Unresolved — geography excluded** |
| **Agent identity conflicts** | **100% of agent_ids map to multiple identities/join dates** | **Unresolved — agent tenure excluded** |
| Client, Language dimensions | Not present in any source table | Not fabricated |

---

## 3. Major Issue: Duplicate Payments

### Finding

The raw payment data contains:

- **25,500 payment rows**
- **25,000 unique payment IDs**
- **500 duplicate payment IDs**

Duplicate payment records could inflate recovery if the same payment event were counted multiple times.

### Detection Method

Payment records were grouped by `payment_id` and checked for repeated identifiers.

For duplicated payment IDs, the following business attributes were compared:

- Payment status
- Payment amount
- Event timestamp

Results:

| Validation | Conflicting Records |
|---|---:|
| Status | 0 |
| Amount | 0 |
| Timestamp | 0 |

No conflicting values were identified among the duplicate payment IDs.

### Treatment

The duplicate records are treated as duplicate/re-ingested events.

The account-recovery transformation retains one record per `payment_id` before recovery aggregation.

The cleaning process is implemented in:

`sql/transformations/01_account_recovery.sql`

The raw and clean source tables are preserved rather than physically deleting the duplicate source records.

### Business Impact

Without deduplication, duplicate payment events could artificially inflate recovery.

Deduplication therefore protects:

- Recovery amount
- Recovered-account classification
- Recovery rate
- Monthly recovery trends
- Downstream statistical analysis
- Investment analysis

The verified SUCCESS-based recovery amount after deduplication is:

**₹1,315,583,964.64 (~₹131.56 Cr)**

---

## 4. Recovery Definition Validation

Recovery is independently defined rather than relying on a pre-existing reporting metric.

### Recovered Account

An account is classified as recovered when it has at least one valid SUCCESS payment after payment-level deduplication.

### Recovery Amount

Recovery amount is:

`SUM(payment_amount) WHERE payment_status = 'SUCCESS'`

after payment-ID deduplication.

The following statuses are excluded:

- FAILED
- PENDING
- REVERSED

### Business Impact

This prevents non-successful payments and duplicate payment events from being incorrectly counted as recovery.

---

## 5. Golden Dataset Integrity

The final analytical dataset is:

`account_features`

Validation results:

| Check | Result |
|---|---:|
| Total rows | 30,000 |
| Unique account IDs | 30,000 |
| Duplicate account IDs | 0 |
| NULL account IDs | 0 |
| Columns | 23 |

### Detection Method

The final table was checked for:

- Account-level grain
- Account ID uniqueness
- NULL account IDs
- Recovery indicators
- Collection exposure features

### Treatment

The dataset is maintained at one record per account.

Invalid or unresolved records are not silently included in downstream metrics.

### Business Impact

The account-level grain provides a stable denominator for:

- Recovery rate
- Recovered accounts
- Recovery per account
- Driver analysis
- Statistical analysis
- Counterfactual analysis
- Investment analysis

---

## 6. Timestamp and Monthly Data Quality

The available payment activity covers:

**January 1, 2026 through August 8, 2026**

August is therefore a partial month.

### Detection Method

Monthly payment activity was evaluated using the available event timestamps and the maximum observed event date within each month.

### Treatment

August is treated as a **partial month** and is not used as a complete month when evaluating whether the reported 11% improvement is sustained.

### Business Impact

This prevents an incomplete August from being incorrectly compared with full calendar months and creating a misleading month-on-month conclusion.

---

## 7. Entity Identity Problems: Geography and Agent Tenure

The assignment requests analysis by geography, language, agent tenure, and client. This section documents why two of these four dimensions are technically present in the schema but were excluded from driver analysis, and quantifies the underlying identity problem — directly addressing Part 2E of the assignment ("Agent identity problems: does the same agent appear under multiple identifiers?").

### 7.1 Client and Language — genuinely absent

Neither `client` nor `language` exists as a field in any raw or golden source table. These dimensions are not fabricated or inferred.

### 7.2 Geography — present but unreliable due to unresolved borrower identity

`borrowers.city` and `borrowers.state` exist in the schema. However, `borrower_id` does not behave as a stable entity key in the supplied data:

| Check | Result |
|---|---:|
| Unique `borrower_id` values | 11,015 |
| `borrower_id` values appearing on more than one row | 8,566 (77.8%) |
| `borrower_id` values with **conflicting `state`** across rows | 8,070 (73.3%) |
| `borrower_id` values with conflicting `name` across rows | 8,185 (74.3%) |

**Example:** `BRW0000001` appears on 3 rows as "Aarav Sharma" (Kolkata → Hyderabad) and "Rohan Patel" (Hyderabad), with no consistent `updated_at` ordering that resolves which record is authoritative (`created_at` is not monotonic with `updated_at` across the duplicate rows).

#### Detection Method
Grouped `borrowers_golden` by `borrower_id` and counted distinct `state` and `name` values per group.

#### Treatment
Geography is excluded from driver analysis rather than assigning an arbitrary row (e.g. "first" or "last") to each account, which would silently misattribute state to the wrong physical location for roughly three out of four borrowers.

#### Business Impact
A geography cut is not reliable until borrower identity is resolved (e.g. via phone/email matching, a canonical source-of-truth table, or an upstream fix to the ingestion process producing duplicate `borrower_id` rows with conflicting attributes). Any geography-based recovery comparison built on the current table would reflect data-entry noise, not a real geographic effect.

### 7.3 Agent Tenure — present but unreliable due to unresolved agent identity

`agents.joined_at` exists and is the natural source for tenure. However, `agent_id` is even less reliable than `borrower_id`:

| Check | Result |
|---|---:|
| Unique `agent_id` values | 1,000 |
| Raw `agents_golden` rows | 30,000 (30 rows per agent_id on average) |
| `agent_id` values with **conflicting `joined_at`** | 1,000 (100%) |

Every single `agent_id` maps to roughly 20–30 distinct name/team/`joined_at` combinations. Example: `AGT0000001` alone maps to 23 different names and join dates spanning January 2024 to September 2025.

#### Detection Method
Grouped `agents_golden` by `agent_id` and counted distinct `joined_at`, `agent_name`, and `team` values per group.

#### Treatment
Agent tenure is excluded from driver analysis. No single-row selection rule (latest `updated_at`, first `created_at`, most frequent value) can be justified without confirming which underlying identity the `agent_id` is actually meant to represent — this looks less like ordinary duplication and more like an unresolved multi-entity mapping problem upstream of this dataset.

#### Business Impact
Reporting a tenure effect on top of an unresolved 100%-conflict identifier would produce a number that cannot be trusted or reproduced. This is flagged as a candidate root-cause investigation for the source system rather than something correctable in this analysis.

### 7.4 Recommendation

Before geography or agent tenure can be added to production driver analysis:

1. Establish a canonical identity-resolution rule for `borrower_id` and `agent_id` (e.g., a verified source-of-truth table, majority-vote on stable fields, or a fix at ingestion).
2. Re-run the conflict checks above against the resolved table and confirm conflict rates drop to near zero.
3. Only then re-introduce geography and agent tenure as driver-analysis cuts.

---

## 8. Cost Data Limitation

The assignment requires:

**Cost per ₹ recovered**

However, the supplied data does not contain a reliable collection/intervention cost field.

### Treatment

No unsupported cost value is created.

The metric is reported as:

**NOT ESTIMABLE FROM SUPPLIED DATA**

### Business Impact

A reliable operational ROI cannot be calculated from observed collection costs.

The ₹10 Cr investment analysis therefore uses the explicitly modeled investment scenario and clearly separates modeled estimates from observed financial outcomes.

---

## 9. Analytical Integrity Controls

The following principles are applied throughout the project:

- Raw records are preserved.
- Source identifiers are retained where available.
- Duplicate payment IDs are investigated before recovery aggregation.
- Recovery is based on SUCCESS payments only.
- Account-level grain is explicitly validated.
- Partial months are identified before trend conclusions.
- Missing or unresolved-identity business dimensions are not fabricated or arbitrarily assigned.
- Unsupported financial metrics are reported as not estimable.
- Observational relationships are not presented as causal effects.

---

## 10. Final Data Quality Impact

After applying the documented validation and treatment rules:

| Metric | Final Result |
|---|---:|
| Accounts analyzed | 30,000 |
| Recovered accounts | 13,284 |
| Unrecovered accounts | 16,716 |
| Recovery rate | 44.28% |
| Verified SUCCESS recovery | ₹1,315,583,964.64 |
| Recovery in Crores | ~₹131.56 Cr |
| Borrower identity conflict rate | 73.3% of borrower_ids |
| Agent identity conflict rate | 100% of agent_ids |

The final analytical dataset contains:

- **30,000 account records**
- **30,000 unique account IDs**
- **0 NULL account IDs**
- **0 duplicate account IDs**

The payment layer contains 500 duplicate payment IDs, but these are handled before account-level recovery aggregation. The borrower and agent identity layers contain far more severe, currently unresolved conflicts (73.3% and 100% respectively), which is why geography and agent tenure are excluded from driver analysis rather than silently computed on an unreliable key.

---

## 11. Overall Data Quality Assessment

### ACCOUNT-LEVEL GRAIN

**PASS**

### ACCOUNT ID UNIQUENESS

**PASS — 30,000 unique IDs**

### NULL ACCOUNT IDs

**PASS — 0**

### DUPLICATE PAYMENT INVESTIGATION

**PASS — 500 identified and investigated**

### CONFLICTING DUPLICATE PAYMENT VALUES

**PASS — 0 conflicts**

### SUCCESS-ONLY RECOVERY DEFINITION

**PASS**

### PAYMENT-LEVEL DEDUPLICATION

**PASS**

### PARTIAL-MONTH HANDLING

**PASS — August treated as partial**

### BORROWER IDENTITY (borrower_id → city/state)

**FAIL — 73.3% conflict rate; geography excluded pending entity resolution**

### AGENT IDENTITY (agent_id → joined_at)

**FAIL — 100% conflict rate; agent tenure excluded pending entity resolution**

### CLIENT / LANGUAGE DIMENSIONS

**NOT PRESENT IN SCHEMA — not fabricated**

### COST PER ₹ RECOVERED

**NOT ESTIMABLE FROM SUPPLIED DATA**

---

## 12. Conclusion

Two material data-quality issues were identified.

The first is the presence of **500 duplicate payment IDs** within **25,500 raw payment rows**. These were investigated and showed no conflicting payment status, amount, or timestamp values, and were deduplicated before account-level recovery aggregation.

The second, more severe issue is an **unresolved entity-identity problem in the borrower and agent tables**: 73.3% of `borrower_id` values carry conflicting city/state data across rows, and 100% of `agent_id` values map to multiple, materially different name/team/join-date combinations. Rather than assign an arbitrary row to each ID — which would silently fabricate a geography or tenure value — these dimensions are excluded from driver analysis until the source identity keys are resolved upstream.

The final analytical dataset passes all account-level integrity checks and contains **30,000 unique accounts**.

The resulting verified SUCCESS-based recovery is:

**₹1,315,583,964.64 (~₹131.56 Cr)**

The data-quality treatment provides a reliable foundation for the downstream recovery, driver, statistical, counterfactual, and investment analyses. Where the supplied data cannot support a requested metric or business dimension — either because the field is absent or because its identity key is unresolved — the project explicitly records the limitation and quantifies it, rather than introducing unsupported values.