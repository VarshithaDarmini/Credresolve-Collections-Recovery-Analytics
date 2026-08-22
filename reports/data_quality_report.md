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
| Missing business dimensions | Client, geography, language, agent tenure | Not fabricated |

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

## 7. Data Availability Limitations

The assignment requests analysis across several dimensions.

The following dimensions are not available as reliable standalone analytical fields in the supplied data:

- Client
- Geography
- Language
- Agent tenure

These dimensions are **not fabricated or inferred**.

### Business Impact

The project reports only dimensions that can be supported by the available data.

Additional source fields would be required for reliable production analysis of these dimensions.

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
- Missing business dimensions are not fabricated.
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

The final analytical dataset contains:

- **30,000 account records**
- **30,000 unique account IDs**
- **0 NULL account IDs**
- **0 duplicate account IDs**

The payment layer contains 500 duplicate payment IDs, but these are handled before account-level recovery aggregation.

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

### MISSING BUSINESS DIMENSIONS

**DOCUMENTED — not fabricated**

### COST PER ₹ RECOVERED

**NOT ESTIMABLE FROM SUPPLIED DATA**

---

## 12. Conclusion

The primary material data-quality issue identified is the presence of **500 duplicate payment IDs** within **25,500 raw payment rows**.

The duplicates were investigated and showed no conflicting payment status, amount, or timestamp values. They are therefore treated as duplicate/re-ingested records and deduplicated before account-level recovery aggregation.

The final analytical dataset passes the account-level integrity checks and contains **30,000 unique accounts**.

The resulting verified SUCCESS-based recovery is:

**₹1,315,583,964.64 (~₹131.56 Cr)**

The data-quality treatment provides a reliable foundation for the downstream recovery, driver, statistical, counterfactual, and investment analyses.

Where the supplied data cannot support a requested metric or business dimension, the project explicitly records the limitation rather than introducing unsupported values.