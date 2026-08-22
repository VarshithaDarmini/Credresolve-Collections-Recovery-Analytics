-- ============================================================
-- CREDRESOLVE
-- CLEANING — CLEAN ANALYTICAL TABLES
-- ============================================================
-- Purpose:
-- Create reproducible analytical tables from raw source data.
--
-- Raw staging tables are never modified.
--
-- This layer applies deterministic data-quality rules:
--   - required identifiers
--   - required timestamps where analytically necessary
--   - invalid numeric values
--   - field normalization
--
-- Duplicate payment events are NOT silently removed here.
-- They are investigated separately as part of the Golden
-- Dataset / Data Forensics process.
-- ============================================================


-- ============================================================
-- 1. CLEAN ACCOUNTS
-- ============================================================

CREATE OR REPLACE TABLE clean_accounts AS

SELECT
    TRIM(account_id) AS account_id,
    TRIM(borrower_id) AS borrower_id,
    TRIM(loan_type) AS loan_type,
    principal_amount,
    outstanding_amount,
    dpd,
    UPPER(TRIM(risk_segment)) AS risk_segment,
    UPPER(TRIM(status)) AS status,
    opened_at,
    TRIM(timezone) AS timezone,
    TRIM(schema_version) AS schema_version

FROM accounts

WHERE account_id IS NOT NULL
  AND principal_amount IS NOT NULL
  AND principal_amount >= 0
  AND outstanding_amount IS NOT NULL
  AND outstanding_amount >= 0
  AND dpd IS NOT NULL
  AND dpd >= 0;


-- ============================================================
-- 2. CLEAN PAYMENTS
-- ============================================================

CREATE OR REPLACE TABLE clean_payments AS

SELECT
    TRIM(payment_id) AS payment_id,
    TRIM(account_id) AS account_id,
    TRIM(borrower_id) AS borrower_id,
    event_at,
    TRIM(payment_reference) AS payment_reference,
    amount,
    UPPER(TRIM(payment_status)) AS payment_status,
    TRIM(payment_method) AS payment_method,
    TRIM(provider_id) AS provider_id

FROM payments

WHERE payment_id IS NOT NULL
  AND account_id IS NOT NULL
  AND amount IS NOT NULL
  AND amount >= 0
  AND event_at IS NOT NULL;


-- ============================================================
-- 3. CLEAN CALLS
-- ============================================================

CREATE OR REPLACE TABLE clean_calls AS

SELECT
    TRIM(call_id) AS call_id,
    TRIM(account_id) AS account_id,
    TRIM(borrower_id) AS borrower_id,
    event_at,
    TRIM(agent_id) AS agent_id,
    TRIM(campaign_id) AS campaign_id,
    TRIM(direction) AS direction,
    TRIM(vendor_id) AS vendor_id,
    UPPER(TRIM(call_status)) AS call_status,
    duration_sec,
    TRIM(timezone) AS timezone

FROM calls

WHERE call_id IS NOT NULL
  AND account_id IS NOT NULL
  AND event_at IS NOT NULL
  AND (duration_sec IS NULL OR duration_sec >= 0);


-- ============================================================
-- 4. CLEAN CALL ATTEMPTS
-- ============================================================

CREATE OR REPLACE TABLE clean_call_attempts AS

SELECT
    TRIM(attempt_id) AS attempt_id,
    TRIM(account_id) AS account_id,
    TRIM(borrower_id) AS borrower_id,
    event_at,
    TRIM(call_id) AS call_id,
    TRIM(agent_id) AS agent_id,
    attempt_no,
    TRIM(vendor_id) AS vendor_id,
    UPPER(TRIM(attempt_status)) AS attempt_status

FROM call_attempts

WHERE attempt_id IS NOT NULL
  AND account_id IS NOT NULL
  AND event_at IS NOT NULL;


-- ============================================================
-- 5. CLEAN CALL DISPOSITIONS
-- ============================================================

CREATE OR REPLACE TABLE clean_call_dispositions AS

SELECT
    TRIM(disposition_id) AS disposition_id,
    TRIM(account_id) AS account_id,
    TRIM(borrower_id) AS borrower_id,
    event_at,
    TRIM(call_id) AS call_id,
    TRIM(agent_id) AS agent_id,
    TRIM(disposition_code) AS disposition_code,
    TRIM(disposition_version) AS disposition_version

FROM call_dispositions

WHERE disposition_id IS NOT NULL
  AND account_id IS NOT NULL
  AND event_at IS NOT NULL;


-- ============================================================
-- 6. CLEAN DAILY TARGETING
-- ============================================================

CREATE OR REPLACE TABLE clean_daily_targeting AS

SELECT
    TRIM(target_id) AS target_id,
    TRIM(account_id) AS account_id,
    TRIM(campaign_id) AS campaign_id,
    target_date,
    priority,
    TRIM(recommended_channel) AS recommended_channel,
    UPPER(TRIM(status)) AS status

FROM daily_targeting

WHERE target_id IS NOT NULL
  AND account_id IS NOT NULL
  AND target_date IS NOT NULL;


-- ============================================================
-- 7. VALIDATION
-- ============================================================

SELECT
    'accounts' AS table_name,
    COUNT(*) AS row_count
FROM clean_accounts

UNION ALL

SELECT
    'payments',
    COUNT(*)
FROM clean_payments

UNION ALL

SELECT
    'calls',
    COUNT(*)
FROM clean_calls

UNION ALL

SELECT
    'call_attempts',
    COUNT(*)
FROM clean_call_attempts

UNION ALL

SELECT
    'call_dispositions',
    COUNT(*)
FROM clean_call_dispositions

UNION ALL

SELECT
    'daily_targeting',
    COUNT(*)
FROM clean_daily_targeting

ORDER BY table_name;