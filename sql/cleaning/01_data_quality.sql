-- ============================================================
-- CREDRESOLVE
-- CLEANING — DATA QUALITY VALIDATION
-- ============================================================
-- Purpose:
-- Identify major data-quality and integrity issues before
-- analytical use.
--
-- This layer detects issues; it does not silently delete data.
-- Raw source tables remain unchanged.
-- ============================================================


-- ============================================================
-- 1. ACCOUNTS: DUPLICATE PRIMARY KEYS
-- ============================================================

SELECT
    account_id,
    COUNT(*) AS duplicate_count
FROM accounts
GROUP BY account_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 2. PAYMENTS: DUPLICATE PRIMARY KEYS
-- ============================================================

SELECT
    payment_id,
    COUNT(*) AS duplicate_count
FROM payments
GROUP BY payment_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. CALLS: DUPLICATE PRIMARY KEYS
-- ============================================================

SELECT
    call_id,
    COUNT(*) AS duplicate_count
FROM calls
GROUP BY call_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. CALL ATTEMPTS: DUPLICATE PRIMARY KEYS
-- ============================================================

SELECT
    attempt_id,
    COUNT(*) AS duplicate_count
FROM call_attempts
GROUP BY attempt_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 5. CALL DISPOSITIONS: DUPLICATE PRIMARY KEYS
-- ============================================================

SELECT
    disposition_id,
    COUNT(*) AS duplicate_count
FROM call_dispositions
GROUP BY disposition_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 6. AGENTS: DUPLICATE PRIMARY KEYS
-- ============================================================

SELECT
    agent_id,
    COUNT(*) AS duplicate_count
FROM agents
GROUP BY agent_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 7. CAMPAIGNS: DUPLICATE PRIMARY KEYS
-- ============================================================

SELECT
    campaign_id,
    COUNT(*) AS duplicate_count
FROM campaigns
GROUP BY campaign_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 8. PAYMENTS: ORPHAN ACCOUNTS
-- ============================================================

SELECT
    COUNT(*) AS orphan_payment_records
FROM payments p
LEFT JOIN accounts a
    ON p.account_id = a.account_id
WHERE a.account_id IS NULL;


-- ============================================================
-- 9. CALLS: ORPHAN ACCOUNTS
-- ============================================================

SELECT
    COUNT(*) AS orphan_call_records
FROM calls c
LEFT JOIN accounts a
    ON c.account_id = a.account_id
WHERE a.account_id IS NULL;


-- ============================================================
-- 10. CALL ATTEMPTS: ORPHAN CALLS
-- ============================================================

SELECT
    COUNT(*) AS orphan_attempt_records
FROM call_attempts ca
LEFT JOIN calls c
    ON ca.call_id = c.call_id
WHERE c.call_id IS NULL;


-- ============================================================
-- 11. CALL DISPOSITIONS: ORPHAN CALLS
-- ============================================================

SELECT
    COUNT(*) AS orphan_disposition_records
FROM call_dispositions cd
LEFT JOIN calls c
    ON cd.call_id = c.call_id
WHERE c.call_id IS NULL;


-- ============================================================
-- 12. DAILY TARGETING: ORPHAN ACCOUNTS
-- ============================================================

SELECT
    COUNT(*) AS orphan_target_records
FROM daily_targeting dt
LEFT JOIN accounts a
    ON dt.account_id = a.account_id
WHERE a.account_id IS NULL;


-- ============================================================
-- 13. DAILY TARGETING: ORPHAN CAMPAIGNS
-- ============================================================

SELECT
    COUNT(*) AS orphan_campaign_target_records
FROM daily_targeting dt
LEFT JOIN campaigns c
    ON dt.campaign_id = c.campaign_id
WHERE c.campaign_id IS NULL;


-- ============================================================
-- 14. ACCOUNTS: MISSING CRITICAL FIELDS
-- ============================================================

SELECT
    COUNT(*) AS missing_account_id
FROM accounts
WHERE account_id IS NULL;


SELECT
    COUNT(*) AS missing_borrower_id
FROM accounts
WHERE borrower_id IS NULL;


-- ============================================================
-- 15. PAYMENTS: MISSING CRITICAL FIELDS
-- ============================================================

SELECT
    COUNT(*) AS missing_payment_id
FROM payments
WHERE payment_id IS NULL;


SELECT
    COUNT(*) AS missing_payment_amount
FROM payments
WHERE amount IS NULL;


SELECT
    COUNT(*) AS missing_payment_timestamp
FROM payments
WHERE event_at IS NULL;


-- ============================================================
-- 16. CALLS: MISSING CRITICAL FIELDS
-- ============================================================

SELECT
    COUNT(*) AS missing_call_id
FROM calls
WHERE call_id IS NULL;


SELECT
    COUNT(*) AS missing_call_account
FROM calls
WHERE account_id IS NULL;


SELECT
    COUNT(*) AS missing_call_timestamp
FROM calls
WHERE event_at IS NULL;


-- ============================================================
-- 17. ACCOUNTS: INVALID NUMERIC VALUES
-- ============================================================

SELECT
    COUNT(*) AS invalid_principal_amount
FROM accounts
WHERE principal_amount < 0;


SELECT
    COUNT(*) AS invalid_outstanding_amount
FROM accounts
WHERE outstanding_amount < 0;


SELECT
    COUNT(*) AS invalid_dpd
FROM accounts
WHERE dpd < 0;


-- ============================================================
-- 18. PAYMENTS: INVALID AMOUNTS
-- ============================================================

SELECT
    COUNT(*) AS invalid_payment_amount
FROM payments
WHERE amount < 0;


-- ============================================================
-- 19. CALLS: INVALID DURATIONS
-- ============================================================

SELECT
    COUNT(*) AS invalid_call_duration
FROM calls
WHERE duration_sec < 0;


-- ============================================================
-- 20. AGENT SESSIONS: INVALID TIME ORDER
-- ============================================================

SELECT
    COUNT(*) AS invalid_agent_sessions
FROM agent_sessions
WHERE logout_at IS NOT NULL
  AND login_at IS NOT NULL
  AND logout_at < login_at;


-- ============================================================
-- 21. PAYMENTS: DUPLICATE EVENT PATTERNS
-- ============================================================
-- Detect potentially duplicated payment events using account,
-- timestamp, amount, and payment reference.

SELECT
    account_id,
    event_at,
    amount,
    payment_reference,
    COUNT(*) AS duplicate_event_count
FROM payments
GROUP BY
    account_id,
    event_at,
    amount,
    payment_reference
HAVING COUNT(*) > 1
ORDER BY duplicate_event_count DESC;


-- ============================================================
-- 22. PAYMENTS: DUPLICATE REFERENCES
-- ============================================================

SELECT
    payment_reference,
    COUNT(*) AS reference_count,
    COUNT(DISTINCT payment_id) AS payment_id_count,
    ROUND(SUM(amount), 2) AS total_amount
FROM payments
WHERE payment_reference IS NOT NULL
GROUP BY payment_reference
HAVING COUNT(*) > 1
ORDER BY reference_count DESC;


-- ============================================================
-- 23. PAYMENTS: STATUS AND AMOUNT PROFILE
-- ============================================================

SELECT
    payment_status,
    COUNT(*) AS payment_records,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS average_amount
FROM payments
GROUP BY payment_status
ORDER BY payment_records DESC;


-- ============================================================
-- 24. CALLS: UNKNOWN AGENTS
-- ============================================================

SELECT
    COUNT(*) AS unknown_call_agent_records
FROM calls c
LEFT JOIN agents a
    ON c.agent_id = a.agent_id
WHERE c.agent_id IS NOT NULL
  AND a.agent_id IS NULL;


-- ============================================================
-- 25. CALLS: UNKNOWN VENDORS
-- ============================================================

SELECT
    COUNT(*) AS unknown_call_vendor_records
FROM calls c
LEFT JOIN vendor_telephony v
    ON c.vendor_id = v.vendor_id
WHERE c.vendor_id IS NOT NULL
  AND v.vendor_id IS NULL;


-- ============================================================
-- 26. CALLS: TIMEZONE PROFILE
-- ============================================================

SELECT
    timezone,
    COUNT(*) AS call_records
FROM calls
GROUP BY timezone
ORDER BY call_records DESC;


-- ============================================================
-- 27. PAYMENTS: TIMESTAMP PROFILE
-- ============================================================

SELECT
    COUNT(*) AS payment_records,
    COUNT(event_at) AS populated_payment_timestamps,
    MIN(event_at) AS earliest_payment_event,
    MAX(event_at) AS latest_payment_event
FROM payments;


-- ============================================================
-- 28. CALLS: TIMESTAMP PROFILE
-- ============================================================

SELECT
    COUNT(*) AS call_records,
    COUNT(event_at) AS populated_call_timestamps,
    MIN(event_at) AS earliest_call_event,
    MAX(event_at) AS latest_call_event
FROM calls;


-- ============================================================
-- 29. PAYMENTS: STATUS DISTRIBUTION
-- ============================================================

SELECT
    payment_status,
    COUNT(*) AS record_count
FROM payments
GROUP BY payment_status
ORDER BY record_count DESC;


-- ============================================================
-- 30. ACCOUNTS: RISK SEGMENT DISTRIBUTION
-- ============================================================

SELECT
    risk_segment,
    COUNT(*) AS account_count
FROM accounts
GROUP BY risk_segment
ORDER BY account_count DESC;


-- ============================================================
-- 31. ACCOUNTS: STATUS DISTRIBUTION
-- ============================================================

SELECT
    status,
    COUNT(*) AS account_count
FROM accounts
GROUP BY status
ORDER BY account_count DESC;


-- ============================================================
-- 32. DATA QUALITY SUMMARY
-- ============================================================
-- Compact source-table summary of row counts, distinct keys,
-- and null primary keys.
-- ============================================================

SELECT
    'accounts' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT account_id) AS distinct_primary_keys,
    SUM(
        CASE
            WHEN account_id IS NULL THEN 1
            ELSE 0
        END
    ) AS null_primary_keys
FROM accounts

UNION ALL

SELECT
    'payments',
    COUNT(*),
    COUNT(DISTINCT payment_id),
    SUM(
        CASE
            WHEN payment_id IS NULL THEN 1
            ELSE 0
        END
    )
FROM payments

UNION ALL

SELECT
    'calls',
    COUNT(*),
    COUNT(DISTINCT call_id),
    SUM(
        CASE
            WHEN call_id IS NULL THEN 1
            ELSE 0
        END
    )
FROM calls

UNION ALL

SELECT
    'call_attempts',
    COUNT(*),
    COUNT(DISTINCT attempt_id),
    SUM(
        CASE
            WHEN attempt_id IS NULL THEN 1
            ELSE 0
        END
    )
FROM call_attempts

UNION ALL

SELECT
    'call_dispositions',
    COUNT(*),
    COUNT(DISTINCT disposition_id),
    SUM(
        CASE
            WHEN disposition_id IS NULL THEN 1
            ELSE 0
        END
    )
FROM call_dispositions

UNION ALL

SELECT
    'agents',
    COUNT(*),
    COUNT(DISTINCT agent_id),
    SUM(
        CASE
            WHEN agent_id IS NULL THEN 1
            ELSE 0
        END
    )
FROM agents

UNION ALL

SELECT
    'campaigns',
    COUNT(*),
    COUNT(DISTINCT campaign_id),
    SUM(
        CASE
            WHEN campaign_id IS NULL THEN 1
            ELSE 0
        END
    )
FROM campaigns;