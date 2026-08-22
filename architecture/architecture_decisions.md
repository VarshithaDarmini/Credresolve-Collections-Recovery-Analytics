# CredResolve Collections Recovery Analytics --- Architecture Decisions

## 1. Purpose

This document describes the production analytics design for the
CredResolve collections recovery analytics project.

The production flow follows the assignment-required pattern:

**Raw → Staging → Clean → Golden → Feature → Metrics → Dashboard**

The design is intended to provide a trustworthy analytical layer for
daily leadership reporting while preserving reproducibility, data
quality, lineage, and controlled recovery/investment analysis.

------------------------------------------------------------------------

## 2. Source Data and Raw Layer

The raw layer preserves source records before analytical
transformations.

The project currently contains source datasets covering borrowers,
accounts, agents, agent sessions, campaigns, daily targeting, calls,
call attempts, call dispositions, WhatsApp events, SMS events, field
visits, promises to pay, payments, telephony vendors, complaints, and
account status history.

Raw records should be retained as an auditable source layer. Source
timestamps, source identifiers, and ingestion metadata should be
preserved wherever available.

### Production principle

Raw data is not treated as the final analytical truth. Downstream layers
apply validation, cleaning, reconciliation, and business rules.

------------------------------------------------------------------------

## 3. Staging Layer

The staging layer is responsible for ingestion and structural
standardization.

Responsibilities:

-   schema and column standardization
-   data-type casting
-   timestamp normalization
-   source-level validation
-   preservation of source identifiers
-   load/audit metadata
-   isolation of source-specific formats

The staging layer should remain close to the source and should not
contain business-specific recovery metrics.

------------------------------------------------------------------------

## 4. Clean Layer

The clean layer applies data-quality and consistency rules before
records become part of the trusted analytical layer.

Checks include:

-   duplicate detection
-   missing-value treatment
-   invalid-value checks
-   referential-integrity checks
-   timestamp validation
-   business-rule validation
-   inconsistent identifier detection
-   correction or exclusion of invalid records

Records that cannot be safely corrected should be rejected or
quarantined rather than silently included in analytical metrics.

The project documents these investigations through the data-quality and
forensic outputs.

------------------------------------------------------------------------

## 5. Golden Dataset

The Golden Dataset is the trusted analytical layer used for downstream
recovery analysis.

Key responsibilities:

-   entity resolution
-   deduplication
-   source-of-truth decisions
-   conformed identifiers
-   payment attribution
-   historical-state handling
-   exclusion rules
-   documented assumptions

The Golden Dataset should provide stable analytical keys and preserve
the ability to trace important records back to their source.

### Golden-layer principle

Recovery metrics should be calculated from the trusted Golden layer
rather than directly from raw event tables.

------------------------------------------------------------------------

## 6. Entity Resolution and Primary Keys

The main analytical entities include:

  Entity           Business identifier   Analytical key
  ---------------- --------------------- ----------------
  Account          account_id            account_sk
  Borrower         borrower_id           borrower_sk
  Agent            agent_id              agent_sk
  Campaign         campaign_id           campaign_sk
  Call             call_id               call_sk
  Payment          payment_id            payment_sk
  Promise to Pay   ptp_id                ptp_sk
  Field Visit      visit_id              visit_sk

The exact source identifier and surrogate-key implementation should be
governed by the production data contract.

Entity resolution is required when the same real-world entity appears
under inconsistent identifiers.

------------------------------------------------------------------------

## 7. Feature Layer

The feature layer derives account-, borrower-, agent-, campaign-, call-,
and exposure-level analytical features from the Golden Dataset.

Examples include:

-   call exposure
-   attempt frequency
-   agent exposure
-   campaign exposure
-   recovery indicators
-   DPD-related features
-   targeting exposure
-   time-based features
-   portfolio and risk-segment features

Features should be reproducible from documented upstream data and
transformations.

------------------------------------------------------------------------

## 8. Metrics Layer

The metrics layer contains governed business definitions used by the
dashboard and analytical outputs.

Important recovery metrics include:

-   recovery rate
-   recovery amount
-   recovered accounts
-   contact rate
-   RPC
-   PTP rate
-   PTP kept rate
-   recovery per account
-   recovery per agent-hour
-   cost per ₹ recovered
-   channel conversion

Metric definitions should specify numerator, denominator, population,
time window, exclusions, and source layer.

A metric must not change definition silently between reporting periods.

------------------------------------------------------------------------

## 9. Data Lineage

The expected lineage is:

**Raw source → Staging table → Clean table → Golden entity/event →
Feature table → Metric table → Dashboard**

Lineage should be maintained at table and metric level so that a
dashboard value can be traced back to the analytical dataset and
ultimately to source records.

The SQL repository mirrors the transformation stages through separate
staging, cleaning, transformation, feature, metrics, and analysis
folders.

------------------------------------------------------------------------

## 10. Data Contracts

Each production source should have a documented contract covering:

-   expected schema
-   required columns
-   data types
-   primary/business identifiers
-   timestamp semantics
-   allowed values
-   expected delivery frequency
-   freshness expectation
-   ownership
-   acceptable null rates

Schema changes should be detected before they silently alter downstream
metrics.

------------------------------------------------------------------------

## 11. Incremental Processing

A production implementation should support both initial full loads and
incremental loads.

Incremental processing should use a reliable event/update timestamp or
source watermark.

Recommended controls:

-   maintain a high-water mark
-   process only new or changed records
-   use idempotent transformations
-   partition large event tables where appropriate
-   record load/run metadata
-   reconcile source and target row counts

A periodic full reconciliation should be used to detect missed or
incorrectly processed records.

------------------------------------------------------------------------

## 12. Late-Arriving Data

Late-arriving events are expected in operational collections systems.

Examples include:

-   delayed payment events
-   delayed call dispositions
-   corrected account status records
-   delayed campaign or targeting events

The production design should use an allowed lateness window and
reprocess affected periods when late data arrives.

Affected metrics should be versioned or refreshed rather than
permanently freezing an incomplete historical result.

------------------------------------------------------------------------

## 13. Backfills

Historical corrections should be handled through controlled backfill
jobs.

A backfill should:

1.  identify the affected date/entity range
2.  reload or recompute the required upstream layer
3.  rebuild dependent features
4.  recompute affected metrics
5.  run data-quality checks
6.  compare before/after results
7.  record the backfill in an audit log

Backfills should be reproducible and should not require manual edits to
final metric tables.

------------------------------------------------------------------------

## 14. Data-Quality Checks

Production checks should include:

-   freshness
-   row-count/volume monitoring
-   uniqueness
-   null/domain validation
-   referential integrity
-   duplicate detection
-   timestamp validity
-   identifier consistency
-   reconciliation checks
-   business-rule checks

Critical failures should prevent bad data from silently reaching
executive metrics.

------------------------------------------------------------------------

## 15. Monitoring and Anomaly Detection

The production system should monitor:

-   pipeline success/failure
-   source freshness
-   record volumes
-   duplicate rates
-   null rates
-   schema changes
-   recovery-rate changes
-   payment volumes
-   unusual exposure distributions
-   unexpected metric movements

Anomaly thresholds should be based on historical behavior and business
expectations.

Alerts should identify the affected dataset, metric, period, and
severity so an analyst or engineer can investigate quickly.

------------------------------------------------------------------------

## 16. Security and Governance

Production access should follow least-privilege principles.

Controls should include:

-   role-based access
-   protection of borrower/customer information
-   audit logging
-   controlled access to raw data
-   documented metric definitions
-   separation between source data and executive reporting layers

Only approved analytical fields should be exposed to dashboard
consumers.

------------------------------------------------------------------------

## 17. Reproducibility

The repository separates:

-   SQL transformations and metrics
-   analytical notebooks
-   Golden Dataset outputs
-   data-quality outputs
-   investment-analysis outputs
-   dashboard
-   tests
-   reports

This allows an engineering or analytics team to reproduce the analytical
workflow rather than relying on manually edited dashboard numbers.

------------------------------------------------------------------------

## 18. Investment Analysis Governance

The ₹10 Cr investment analysis is based on observational evidence and
therefore should not be interpreted as proof of causality.

The current analysis identifies better telephony infrastructure as the
leading directly measurable candidate because its standardized
model-based effect is approximately **+0.961 percentage points**,
compared with a calculated break-even requirement of approximately
**+0.953 percentage points**.

Because the margin is extremely small and the adjusted telephony model
has **p = 0.051541**, the recommended production decision is a
**controlled pilot before committing the full ₹10 Cr**.

The pilot should include a control group and measure incremental
recovery against the predefined break-even threshold.

------------------------------------------------------------------------

## 19. Production Architecture Summary

The complete production flow is:

**Raw Sources** → **Staging** → **Clean / Data Quality** → **Golden
Dataset** → **Feature Layer** → **Metrics Layer** → **Executive
Dashboard**

Cross-cutting services operate across the pipeline:

**Data Contracts + Data Quality + Lineage + Monitoring + Anomaly
Detection + Security/Governance**

This design directly addresses the production analytics requirements in
the assignment while keeping the analytical workflow transparent and
reproducible.
