-- ============================================================
-- CREDRESOLVE
-- STAGING — SOURCE TABLE DEFINITIONS
-- ============================================================
-- Purpose:
-- Document and validate the raw source-table layer used by
-- the analytical SQL pipeline.
--
-- Raw source data is NOT modified in this layer.
-- ============================================================


-- ============================================================
-- 1. SOURCE TABLE INVENTORY
-- ============================================================

SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'main'
  AND table_name IN (
      'accounts',
      'account_status_history',
      'agents',
      'agent_sessions',
      'borrowers',
      'calls',
      'call_attempts',
      'call_dispositions',
      'campaigns',
      'complaints',
      'daily_targeting',
      'field_visits',
      'payments',
      'promises_to_pay',
      'sms_events',
      'vendor_telephony',
      'whatsapp_events'
  )
ORDER BY table_name;


-- ============================================================
-- 2. SOURCE-LEVEL ROW COUNTS
-- ============================================================
-- These queries provide reproducible source-table checks.
-- They do not modify source data.
-- ============================================================

SELECT
    'accounts' AS table_name,
    COUNT(*) AS row_count
FROM accounts

UNION ALL

SELECT
    'payments',
    COUNT(*)
FROM payments

UNION ALL

SELECT
    'calls',
    COUNT(*)
FROM calls

UNION ALL

SELECT
    'call_attempts',
    COUNT(*)
FROM call_attempts

UNION ALL

SELECT
    'call_dispositions',
    COUNT(*)
FROM call_dispositions

UNION ALL

SELECT
    'agents',
    COUNT(*)
FROM agents

UNION ALL

SELECT
    'agent_sessions',
    COUNT(*)
FROM agent_sessions

UNION ALL

SELECT
    'campaigns',
    COUNT(*)
FROM campaigns

UNION ALL

SELECT
    'daily_targeting',
    COUNT(*)
FROM daily_targeting

UNION ALL

SELECT
    'vendor_telephony',
    COUNT(*)
FROM vendor_telephony

ORDER BY table_name;


-- ============================================================
-- 3. KEY SOURCE SCHEMA VALIDATION
-- ============================================================
-- Confirms that the critical columns required by the
-- analytical pipeline exist in the raw source tables.
-- ============================================================

SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'main'
  AND (
        (
            table_name = 'accounts'
            AND column_name IN (
                'account_id',
                'borrower_id',
                'loan_type',
                'principal_amount',
                'outstanding_amount',
                'dpd',
                'risk_segment',
                'status'
            )
        )

        OR

        (
            table_name = 'payments'
            AND column_name IN (
                'payment_id',
                'account_id',
                'amount',
                'payment_status',
                'event_at'
            )
        )

        OR

        (
            table_name = 'calls'
            AND column_name IN (
                'call_id',
                'account_id',
                'event_at',
                'agent_id',
                'campaign_id',
                'vendor_id',
                'duration_sec'
            )
        )

        OR

        (
            table_name = 'call_attempts'
            AND column_name IN (
                'attempt_id',
                'account_id',
                'call_id'
            )
        )

        OR

        (
            table_name = 'call_dispositions'
            AND column_name IN (
                'disposition_id',
                'account_id',
                'call_id'
            )
        )

        OR

        (
            table_name = 'daily_targeting'
            AND column_name IN (
                'target_id',
                'account_id',
                'campaign_id'
            )
        )
      )
ORDER BY
    table_name,
    column_name;