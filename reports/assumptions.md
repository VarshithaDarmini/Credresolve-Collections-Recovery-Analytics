# CredResolve Collections Recovery Analytics

# Assumptions and Analytical Decisions

## 1. Account-Level Analytical Grain

The final analytical dataset is maintained at one record per account.

The primary analytical key is:

`account_id`

The final `account_features` dataset contains:

- 30,000 rows
- 30,000 unique account IDs
- 0 NULL account IDs

---

## 2. Recovery Definition

An account is classified as recovered when it has at least one valid payment with:

`payment_status = 'SUCCESS'`

after payment records have been deduplicated at the payment-ID level.

The analytical field is:

`recovered_account`

where:

- `1` = at least one valid SUCCESS payment
- `0` = no valid SUCCESS payment

FAILED, PENDING, and REVERSED payments do not qualify an account as recovered.

---

## 3. Recovery Amount

Recovery amount is defined strictly as the monetary value of valid SUCCESS payments.

The calculation is:

`SUM(payment_amount) WHERE payment_status = 'SUCCESS'`

after payment-ID deduplication.

The account-level field is:

`total_payment_amount`

and represents SUCCESS-based recovery only.

The authoritative portfolio recovery amount is approximately:

**₹1,315,583,964.64**

or approximately:

**₹131.56 Cr**

The project does not manually replace recovery values. The authoritative value is generated through the payment transformation and propagated downstream.

---

## 4. Duplicate Payment Treatment

The raw payment data contains approximately 500 duplicate payment IDs.

Duplicate payment IDs were checked for:

- payment status conflicts
- amount conflicts
- event timestamp conflicts

No conflicting values were found for these attributes.

The duplicates are therefore treated as duplicate or re-ingested records.

One record per `payment_id` is retained during the account recovery transformation.

The clean source table itself is not modified to perform this downstream deduplication.

---

## 5. Source Data Preservation

Raw and cleaned source data are preserved.

Transformations create analytical tables or views rather than modifying the raw source data.

This supports:

- reproducibility
- auditability
- lineage
- repeatable downstream analysis

---

## 6. Missing Activity Treatment

When an account has no corresponding call, attempt, disposition, or targeting activity, activity metrics are represented as zero in the final account-level feature dataset.

This allows accounts with no observed collection activity to remain in the analysis.

A zero activity value means that no corresponding activity was observed in the supplied data. It does not necessarily mean that no activity existed outside the supplied data.

---

## 7. Call Exposure

An account is considered call-exposed when:

`total_calls > 0`

The resulting field is:

`call_exposed`

where:

- `1` = at least one call
- `0` = no observed calls

---

## 8. Attempt Exposure

An account is considered attempt-exposed when:

`total_attempts > 0`

The resulting field is:

`attempt_exposed`

where:

- `1` = at least one call attempt
- `0` = no observed call attempts

---

## 9. Targeting Exposure

An account is considered targeted when:

`targeting_events > 0`

The resulting field is:

`targeted_account`

where:

- `1` = at least one targeting event
- `0` = no observed targeting event

---

## 10. Exposure Buckets

Collection exposure is grouped into descriptive bands where appropriate.

For call exposure, the analysis uses:

- `0 calls`
- `1-2 calls`
- `3-4 calls`
- `5+ calls`

For attempt exposure, the analysis uses:

- `0 attempts`
- `1-2 attempts`
- `3-5 attempts`
- `6+ attempts`

These buckets are used for descriptive portfolio analysis.

Very high exposure values are retained but interpreted cautiously when the corresponding population is small.

---

## 11. Risk Segment

The existing risk-segment classification in the source/account layer is used without inventing new risk classifications.

Available risk segments include:

- LOW
- MEDIUM
- HIGH
- NPA

Risk segment is treated as a portfolio characteristic rather than a causal treatment variable.

---

## 12. DPD

Days past due (`dpd`) is treated as the account's delinquency measure.

DPD is used for:

- descriptive portfolio comparisons
- DPD-band analysis
- statistical association testing

The analysis does not assume that DPD itself causes recovery outcomes.

---

## 13. Small Exposure Groups

Very small groups, particularly groups with only a few accounts, are not treated as strong evidence.

Their recovery rates may be highly sensitive to individual accounts.

Examples include very high:

- agent exposure
- vendor exposure
- campaign exposure
- call exposure

groups.

Small groups may be displayed for completeness but should not drive portfolio-wide decisions.

---

## 14. Monthly Analysis

Monthly recovery analysis is based on valid SUCCESS payment activity after payment-ID deduplication.

The available payment activity covers:

**January 1, 2026 through August 8, 2026.**

August 2026 is classified as:

`PARTIAL_MONTH`

because the available data ends on August 8.

Only comparable complete months are used to evaluate the sustained month-on-month recovery claim.

---

## 15. 11% Month-on-Month Claim

The reported business claim is:

> Recovery has improved by 11% month-on-month.

The analysis tests both:

- recovery amount month-on-month change
- recovered-account month-on-month change

The claim is evaluated across comparable FULL_MONTH periods.

March 2026 shows an approximately 11% increase:

- recovered accounts: approximately +11.32%
- recovery amount: approximately +11.03%

However, this improvement is not sustained across subsequent complete months.

Therefore:

**11% sustained month-on-month improvement = NOT SUPPORTED**

The March increase is treated as a specific monthly improvement rather than evidence of a persistent 11% trend.

---

## 16. Recovery-Rate Denominators

Two monthly recovery-rate concepts are retained because they answer different business questions.

### Worked-account recovery rate

Calculated as:

`recovered accounts / accounts with payment activity`

This measures conversion among accounts that had payment activity during the month.

### Portfolio recovery rate

Calculated as:

`recovered accounts / total portfolio accounts`

This measures recovery against the full portfolio population.

These denominators must not be mixed when interpreting monthly performance.

---

## 17. Required Collection Metrics

The project defines and calculates the following required collection metrics where the supplied data supports them:

1. Contact Rate
2. RPC
3. PTP Rate
4. PTP Kept Rate
5. Recovery Rate
6. Recovery per Account
7. Recovery per Agent-Hour
8. Cost per ₹ Recovered
9. Channel Conversion

Current calculated values include:

- Contact Rate: **25.90%**
- RPC Rate: **22.57%**
- PTP Rate: **36.78%**
- PTP Kept Rate: **24.94%**
- Recovery Rate: **44.28%**
- Recovery per Account: **₹99,035.23**
- Recovery per Agent-Hour: **₹16,680.22**

Cost per ₹ Recovered is:

**NOT ESTIMABLE FROM SUPPLIED DATA**

because no reliable collection/intervention cost field is available.

No cost value is invented.

---

## 18. Channel Conversion

The supplied data supports channel conversion analysis for SMS and WhatsApp.

Current observed values:

- SMS conversion: **24.25%**
- WhatsApp conversion: **18.69%**

These are descriptive channel metrics.

They do not establish that SMS or WhatsApp causes higher recovery.

---

## 19. Missing Business Dimensions

The available analytical schema was checked for several requested driver dimensions.

The following fields were not identified as reliable standalone analytical dimensions in the supplied account-level data:

- Client
- Geography
- Language
- Agent tenure

These dimensions are therefore not fabricated or inferred.

If required for production analysis, corresponding source fields would need to be supplied.

---

## 20. Calling Direction and Calling Time

The supplied call data supports analysis of:

- inbound versus outbound direction
- calling time

Observed call direction is available as:

`direction`

Observed call timestamp is available for deriving calling-hour bands.

Calling time is grouped into:

- `00-05`
- `06-11`
- `12-17`
- `18-23`

These analyses are descriptive and do not establish causal effects.

---

## 21. Causal Interpretation

The analysis is primarily observational and descriptive.

Higher recovery rates observed among accounts with greater collection exposure do not prove that the collection activity caused the higher recovery rate.

Collection activity may be related to:

- borrower characteristics
- delinquency
- risk segment
- account status
- portfolio mix
- targeting rules
- collection strategy

Therefore:

**Association ≠ Causation**

Causal conclusions would require an appropriate controlled experimental or quasi-experimental design.

---

## 22. Statistical Analysis

Statistical tests are used to evaluate associations between recovery outcomes and available driver variables.

Statistical significance is not interpreted as proof of causation.

Multiple-testing considerations are applied where appropriate.

The statistical analysis is therefore used to identify evidence of association and potential areas for further investigation.

---

## 23. Counterfactual Analysis

The counterfactual analysis estimates modeled incremental recovery under alternative collection-exposure scenarios.

The scenarios are:

- Scenario A — Conservative / Telephony
- Scenario B — Targeted Opportunity / Collection Agents
- Scenario C — Upside / Borrower Targeting

These estimates are model-based.

They are not guaranteed realized outcomes.

The counterfactual outputs must therefore be interpreted as scenario estimates rather than causal proof.

---

## 24. ₹10 Cr Investment Assumption

The investment case uses:

**₹100,000,000**

equivalent to:

**₹10 Cr**

This amount is an assignment scenario.

It is not an observed implementation cost from the supplied data.

The project does not claim that ₹10 Cr is the actual cost of implementing telephony improvements.

---

## 25. ₹10 Cr Break-Even Assumption

The break-even recovery uplift is calculated as:

`investment_amount / portfolio_outstanding * 100`

Current break-even threshold:

**+0.953377 percentage points**

This represents the recovery-rate uplift required for the incremental recovery value to equal ₹10 Cr.

---

## 26. Telephony Investment Scenario

The Stage 7 counterfactual model estimates:

**Telephony modeled effect: +1.076249 percentage points**

Estimated incremental recovery:

**approximately ₹112.89M**

Estimated incremental recovered accounts:

**approximately 322.87**

The modeled effect exceeds the calculated break-even threshold by:

**+0.122872 percentage points**

However, this is a model-based observational estimate.

It is not treated as a proven causal effect.

---

## 27. Investment Recommendation

The modeled telephony scenario clears the mathematical ₹10 Cr break-even threshold.

However, the investment recommendation remains:

> **Pilot first — do not commit the full ₹10 Cr until incremental recovery is validated.**

A controlled pilot should establish the actual incremental recovery effect before full-scale investment.

The pilot should measure:

- treatment/control recovery-rate difference
- incremental recovery amount
- confidence interval
- implementation cost
- cost per incremental ₹ recovered
- operational scalability

---

## 28. Investment Sensitivity

The investment analysis includes:

- Downside
- Base
- Upside

These scenarios are sensitivity assumptions around the modeled telephony effect.

They are not observed outcomes.

They must not be presented as guaranteed financial forecasts.

---

## 29. Metric Reproducibility

Business metrics are calculated from the account-level analytical dataset and supporting clean tables.

The SQL transformation, metric, analysis, and notebook layers are retained so that the results can be reproduced.

Downstream outputs should be regenerated from source transformations rather than manually edited.

---

## 30. Golden Dataset

`account_features` is treated as the final account-level analytical dataset.

It contains:

- account attributes
- recovery outcomes
- collection activity features
- targeting exposure
- call exposure
- attempt exposure

required for downstream analysis.

---

## 31. Reporting Precision

Currency and aggregate financial values are rounded for presentation where appropriate.

Underlying analytical calculations retain their available numeric precision.

Percentage-point effects and financial values should be reported consistently across notebooks, outputs, dashboards, and reports.

---

## 32. Raw Data Preservation

Raw source data is not modified during downstream analytical processing.

Cleaning, deduplication, feature construction, metrics, statistical analysis, counterfactual analysis, and investment analysis are performed through analytical transformations.

This preserves source lineage and supports auditability.

---

## 33. Analytical Scope

The current analysis focuses on:

- recovery performance
- monthly recovery trends
- portfolio characteristics
- loan type
- risk segment
- account status
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
- counterfactual investment scenarios

The analysis does not claim to estimate:

- guaranteed intervention effects
- optimal collection strategy
- guaranteed ROI
- actual implementation cost
- causal treatment effects without controlled validation

---

## 34. Data Availability Principle

If the supplied dataset does not contain sufficient information to reliably calculate a required metric or driver, the project reports:

**Not estimable from supplied data**

rather than inventing a value.

This principle applies to unavailable:

- cost data
- client dimensions
- geography
- language
- agent tenure
- other unsupported business attributes

This is an analytical limitation, not a fabricated estimate.

---

## 35. Final Analytical Principles

The project follows these principles:

1. Use SUCCESS payments for recovery.
2. Deduplicate payment IDs before payment aggregation.
3. Preserve raw source data.
4. Maintain account-level analytical grain.
5. Use explicit denominators for all rates.
6. Exclude partial months from sustained month-on-month comparisons.
7. Treat small exposure groups cautiously.
8. Distinguish association from causation.
9. Do not invent unavailable metrics.
10. Treat counterfactual estimates as model-based scenarios.
11. Treat ₹10 Cr as an assignment investment scenario rather than observed cost.
12. Validate investment hypotheses through controlled pilots before scaling.