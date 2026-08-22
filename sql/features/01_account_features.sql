-- ============================================================
-- CREDRESOLVE
-- FEATURES — ACCOUNT LEVEL FEATURES
-- ============================================================
-- Purpose:
-- Create the analytical feature layer used by recovery,
-- driver, portfolio, and statistical analysis.
--
-- Raw source data is NOT modified.
-- ============================================================


-- ============================================================
-- 1. ACCOUNT FEATURE DATASET
-- ============================================================

CREATE OR REPLACE VIEW account_features AS

SELECT

    -- Account identifiers
    r.account_id,
    r.borrower_id,

    -- Portfolio attributes
    r.loan_type,
    r.principal_amount,
    r.outstanding_amount,
    r.dpd,
    r.risk_segment,
    r.status,

    -- Recovery features
    r.payment_count,
    r.total_payment_amount,
    r.recovered_account,

    -- Call exposure features
    COALESCE(
        a.total_calls,
        0
    ) AS total_calls,

    COALESCE(
        a.total_call_duration_sec,
        0
    ) AS total_call_duration_sec,

    COALESCE(
        a.total_attempts,
        0
    ) AS total_attempts,

    COALESCE(
        a.disposition_events,
        0
    ) AS disposition_events,

    COALESCE(
        a.call_campaign_count,
        0
    ) AS call_campaign_count,

    COALESCE(
        a.vendor_count,
        0
    ) AS vendor_count,

    COALESCE(
        a.agent_count,
        0
    ) AS agent_count,

    COALESCE(
        a.targeting_events,
        0
    ) AS targeting_events,

    COALESCE(
        a.targeting_campaigns,
        0
    ) AS targeting_campaigns,

    -- Derived exposure features
    CASE
        WHEN COALESCE(a.total_calls, 0) > 0
        THEN 1
        ELSE 0
    END AS call_exposed,

    CASE
        WHEN COALESCE(a.total_attempts, 0) > 0
        THEN 1
        ELSE 0
    END AS attempt_exposed,

    CASE
        WHEN COALESCE(a.targeting_events, 0) > 0
        THEN 1
        ELSE 0
    END AS targeted_account

FROM account_recovery r

LEFT JOIN account_activity a
    ON r.account_id = a.account_id;


-- ============================================================
-- 2. FEATURE DATASET VALIDATION
-- ============================================================

SELECT

    COUNT(*) AS accounts,

    COUNT(DISTINCT account_id)
        AS unique_accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    SUM(
        CASE
            WHEN recovered_account = 0
            THEN 1
            ELSE 0
        END
    ) AS unrecovered_accounts,

    SUM(total_calls)
        AS total_calls,

    SUM(total_attempts)
        AS total_attempts,

    SUM(total_call_duration_sec)
        AS total_call_duration_sec

FROM account_features;


-- ============================================================
-- 3. RECOVERY RATE BY CALL EXPOSURE
-- ============================================================

SELECT

    call_exposed,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    ROUND(
        CAST(
            SUM(recovered_account) AS DOUBLE
        )
        /
        NULLIF(COUNT(*), 0),
        6
    ) AS recovery_rate,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        AVG(dpd),
        2
    ) AS avg_dpd

FROM account_features

GROUP BY call_exposed

ORDER BY call_exposed;


-- ============================================================
-- 4. RECOVERY RATE BY RISK SEGMENT
-- ============================================================

SELECT

    risk_segment,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    ROUND(
        CAST(
            SUM(recovered_account) AS DOUBLE
        )
        /
        NULLIF(COUNT(*), 0),
        6
    ) AS recovery_rate,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        AVG(dpd),
        2
    ) AS avg_dpd,

    ROUND(
        AVG(outstanding_amount),
        2
    ) AS avg_outstanding_amount

FROM account_features

GROUP BY risk_segment

ORDER BY recovery_rate DESC;


-- ============================================================
-- 5. RECOVERY RATE BY LOAN TYPE
-- ============================================================

SELECT

    loan_type,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    ROUND(
        CAST(
            SUM(recovered_account) AS DOUBLE
        )
        /
        NULLIF(COUNT(*), 0),
        6
    ) AS recovery_rate,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount

FROM account_features

GROUP BY loan_type

ORDER BY recovery_rate DESC;


-- ============================================================
-- 6. FEATURE NULL / COVERAGE CHECK
-- ============================================================

SELECT

    COUNT(*) AS total_accounts,

    SUM(
        CASE
            WHEN account_id IS NULL
            THEN 1
            ELSE 0
        END
    ) AS null_account_id,

    SUM(
        CASE
            WHEN risk_segment IS NULL
            THEN 1
            ELSE 0
        END
    ) AS null_risk_segment,

    SUM(
        CASE
            WHEN loan_type IS NULL
            THEN 1
            ELSE 0
        END
    ) AS null_loan_type

FROM account_features;