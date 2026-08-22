-- ============================================================
-- CREDRESOLVE
-- ANALYSIS — RECOVERY ANALYSIS
-- ============================================================
-- Purpose:
-- Analyze recovery performance across portfolio,
-- risk, and collection-exposure dimensions.
--
-- Business definitions:
--
-- recovered_account:
--     Account has at least one SUCCESS payment.
--
-- recovery_amount:
--     Sum of total payment amount attributed to the account.
--
-- Raw source data is NOT modified.
-- ============================================================


-- ============================================================
-- 1. OVERALL RECOVERY PERFORMANCE
-- ============================================================

SELECT

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    COUNT(*) - SUM(recovered_account)
        AS unrecovered_accounts,

    ROUND(
        100.0 * SUM(recovered_account)
        / NULLIF(COUNT(*), 0),
        2
    ) AS recovery_rate_pct,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount

FROM account_features;


-- ============================================================
-- 2. RECOVERY BY LOAN TYPE
-- ============================================================

SELECT

    loan_type,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    COUNT(*) - SUM(recovered_account)
        AS unrecovered_accounts,

    ROUND(
        100.0 * SUM(recovered_account)
        / NULLIF(COUNT(*), 0),
        2
    ) AS recovery_rate_pct,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        AVG(outstanding_amount),
        2
    ) AS avg_outstanding_amount,

    ROUND(
        AVG(dpd),
        2
    ) AS avg_dpd

FROM account_features

GROUP BY loan_type

ORDER BY recovery_rate_pct DESC;


-- ============================================================
-- 3. RECOVERY BY RISK SEGMENT
-- ============================================================

SELECT

    risk_segment,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    COUNT(*) - SUM(recovered_account)
        AS unrecovered_accounts,

    ROUND(
        100.0 * SUM(recovered_account)
        / NULLIF(COUNT(*), 0),
        2
    ) AS recovery_rate_pct,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        AVG(outstanding_amount),
        2
    ) AS avg_outstanding_amount,

    ROUND(
        AVG(dpd),
        2
    ) AS avg_dpd

FROM account_features

GROUP BY risk_segment

ORDER BY recovery_rate_pct DESC;


-- ============================================================
-- 4. RECOVERY BY CALL EXPOSURE
-- ============================================================

WITH call_banded AS (

    SELECT

        CASE
            WHEN total_calls <= 2
                THEN '0-2 calls'

            WHEN total_calls <= 4
                THEN '3-4 calls'

            ELSE '5+ calls'
        END AS call_exposure_band,

        CASE
            WHEN total_calls <= 2
                THEN 1

            WHEN total_calls <= 4
                THEN 2

            ELSE 3
        END AS band_order,

        recovered_account,
        total_payment_amount,
        dpd

    FROM account_features
)

SELECT

    call_exposure_band,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    COUNT(*) - SUM(recovered_account)
        AS unrecovered_accounts,

    ROUND(
        100.0 * SUM(recovered_account)
        / NULLIF(COUNT(*), 0),
        2
    ) AS recovery_rate_pct,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        AVG(dpd),
        2
    ) AS avg_dpd

FROM call_banded

GROUP BY
    call_exposure_band,
    band_order

ORDER BY
    band_order;


-- ============================================================
-- 5. RECOVERY BY AGENT EXPOSURE
-- ============================================================

SELECT

    agent_count,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    COUNT(*) - SUM(recovered_account)
        AS unrecovered_accounts,

    ROUND(
        100.0 * SUM(recovered_account)
        / NULLIF(COUNT(*), 0),
        2
    ) AS recovery_rate_pct,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        AVG(total_calls),
        2
    ) AS avg_calls

FROM account_features

GROUP BY agent_count

ORDER BY recovery_rate_pct DESC;


-- ============================================================
-- 6. RECOVERY BY CAMPAIGN EXPOSURE
-- ============================================================

SELECT

    call_campaign_count,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    COUNT(*) - SUM(recovered_account)
        AS unrecovered_accounts,

    ROUND(
        100.0 * SUM(recovered_account)
        / NULLIF(COUNT(*), 0),
        2
    ) AS recovery_rate_pct,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        AVG(total_calls),
        2
    ) AS avg_calls

FROM account_features

GROUP BY call_campaign_count

ORDER BY recovery_rate_pct DESC;


-- ============================================================
-- 7. RECOVERY BY VENDOR EXPOSURE
-- ============================================================

SELECT

    vendor_count,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    COUNT(*) - SUM(recovered_account)
        AS unrecovered_accounts,

    ROUND(
        100.0 * SUM(recovered_account)
        / NULLIF(COUNT(*), 0),
        2
    ) AS recovery_rate_pct,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        AVG(total_calls),
        2
    ) AS avg_calls

FROM account_features

GROUP BY vendor_count

ORDER BY recovery_rate_pct DESC;