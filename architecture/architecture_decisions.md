# CredResolve Collections Recovery Analytics — Architecture Decisions

## 1. Purpose

This document describes the production analytics architecture for the CredResolve collections recovery analytics project.

The production flow follows the assignment-required pattern:

**Raw → Staging → Clean → Golden → Feature → Metrics → Dashboard**

The design is intended to provide a trustworthy analytical layer for daily leadership reporting while maintaining data quality, reproducibility, lineage, and controlled investment analysis.

---

## 2. Source Data and Raw Layer

The Raw layer preserves source records before analytical transformations.

The project works across operational datasets including:

- Borrowers
- Accounts
- Agents
- Agent sessions
- Campaigns
- Daily targeting
- Calls
- Call attempts
- Call dispositions
- WhatsApp events
- SMS events
- Field visits
- Promises to pay
- Payments
- Telephony vendors
- Complaints
- Account status history

Raw records should be retained as an auditable source layer.

Source identifiers, timestamps, and ingestion metadata should be preserved wherever available.

### Production Principle

Raw data is not treated as the final analytical truth.

Validation, cleaning, reconciliation, deduplication, and business rules are applied before data reaches the trusted analytical layer.

---

## 3. Staging Layer

The Staging layer is responsible for ingestion and structural standardization.

Responsibilities include:

- Schema and column standardization
- Data-type casting
- Timestamp normalization
- Source-level validation
- Preservation of source identifiers
- Load and audit metadata
- Isolation of source-specific formats

The Staging layer remains close to the original source and does not contain business-specific recovery metrics.

---

## 4. Clean Layer

The Clean layer applies data-quality and consistency rules before records become part of the trusted analytical layer.

Checks include:

- Duplicate detection
- Missing-value treatment
- Invalid-value checks
- Referential-integrity checks
- Timestamp validation
- Business-rule validation
- Inconsistent identifier detection
- Correction or exclusion of invalid records

Records that cannot be safely corrected are rejected or quarantined rather than silently included in analytical metrics.

The project documents these investigations through the data-quality and forensic outputs.

---

## 5. Golden Dataset

The Golden Dataset is the trusted analytical layer used for downstream recovery analysis.

Key responsibilities include:

- Entity resolution
- Deduplication
- Source-of-truth decisions
- Conformed identifiers
- Payment attribution
- Historical-state handling
- Exclusion rules
- Documented assumptions

The Golden Dataset provides stable analytical keys and preserves traceability to important source records.

### Golden-Layer Principle

Recovery metrics should be calculated from the trusted analytical layer rather than directly from raw event tables.

---

## 6. Entity Resolution and Primary Keys

The main analytical entities include:

| Entity | Business Identifier | Analytical Key |
|---|---|---|
| Account | `account_id` | `account_sk` |
| Borrower | `borrower_id` | `borrower_sk` |
| Agent | `agent_id` | `agent_sk` |
| Campaign | `campaign_id` | `campaign_sk` |
| Call | `call_id` | `call_sk` |
| Payment | `payment_id` | `payment_sk` |
| Promise to Pay | `ptp_id` | `ptp_sk` |
| Field Visit | `visit_id` | `visit_sk` |

The exact source identifier and surrogate-key implementation should be governed by the production data contract.

Entity resolution is required when the same real-world entity appears under inconsistent identifiers.

---

## 7. Feature Layer

The Feature layer derives reproducible analytical features from the Golden Dataset.

Examples include:

- Call exposure
- Attempt frequency
- Agent exposure
- Campaign exposure
- Recovery indicators
- DPD-related features
- Targeting exposure
- Time-based features
- Portfolio features
- Risk-segment features

Features should be reproducible from documented upstream data and transformations.

---

## 8. Metrics Layer

The Metrics layer contains governed business definitions used by analytical outputs and the executive dashboard.

Important recovery metrics include:

- Recovery rate
- Recovery amount
- Recovered accounts
- Contact rate
- RPC
- PTP rate
- PTP kept rate
- Recovery per account
- Recovery per agent-hour
- Cost per ₹ recovered
- Channel conversion

Every governed metric should define:

- Numerator
- Denominator
- Population
- Time window
- Exclusions
- Source layer

### Recovery Amount Definition

Recovery amount is calculated from successfully attributed payments after payment-level deduplication.

```text
payment_status = SUCCESS