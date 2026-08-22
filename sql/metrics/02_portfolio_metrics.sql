-- ============================================================
-- CREDRESOLVE
-- METRICS — PORTFOLIO METRICS
-- ============================================================
-- Purpose:
-- Calculate portfolio-level recovery metrics across loan type,
-- risk segment, account status, DPD bands, and call exposure.
--
-- Business definitions:
--
-- recovered_account:
--     Account has at least one SUCCESS payment.
--
-- recovery_amount:
--     Sum of valid SUCCESS payment amounts only,
--     after duplicate payment records have been removed.
--
--     FAILED, PENDING, and REVERSED payments are excluded.
--
-- Raw source data is NOT modified.
-- ============================================================


-- ============================================================
-- 1. LOAN TYPE PORTFOLIO METRICS
-- ============================================================

SELECT

    loan_type,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    COUNT(*) - SUM(recovered_account)
        AS unrecovered_accounts,

    ROUND(
        CAST(SUM(recovered_account) AS DOUBLE)
        / NULLIF(COUNT(*), 0),
        6
    ) AS recovery_rate,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        SUM(outstanding_amount),
        2
    ) AS outstanding_amount,

    ROUND(
        SUM(total_payment_amount)
        / NULLIF(SUM(outstanding_amount), 0),
        6
    ) AS recovery_to_outstanding_ratio,

    ROUND(
        AVG(dpd),
        2
    ) AS avg_dpd

FROM account_features

GROUP BY loan_type

ORDER BY recovery_rate DESC;


-- ============================================================
-- 2. RISK SEGMENT PORTFOLIO METRICS
-- ============================================================

SELECT

    risk_segment,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    COUNT(*) - SUM(recovered_account)
        AS unrecovered_accounts,

    ROUND(
        CAST(SUM(recovered_account) AS DOUBLE)
        / NULLIF(COUNT(*), 0),
        6
    ) AS recovery_rate,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        SUM(outstanding_amount),
        2
    ) AS outstanding_amount,

    ROUND(
        SUM(total_payment_amount)
        / NULLIF(SUM(outstanding_amount), 0),
        6
    ) AS recovery_to_outstanding_ratio,

    ROUND(
        AVG(dpd),
        2
    ) AS avg_dpd

FROM account_features

GROUP BY risk_segment

ORDER BY recovery_rate DESC;


-- ============================================================
-- 3. ACCOUNT STATUS PORTFOLIO METRICS
-- ============================================================

SELECT

    status,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    COUNT(*) - SUM(recovered_account)
        AS unrecovered_accounts,

    ROUND(
        CAST(SUM(recovered_account) AS DOUBLE)
        / NULLIF(COUNT(*), 0),
        6
    ) AS recovery_rate,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        SUM(outstanding_amount),
        2
    ) AS outstanding_amount,

    ROUND(
        SUM(total_payment_amount)
        / NULLIF(SUM(outstanding_amount), 0),
        6
    ) AS recovery_to_outstanding_ratio

FROM account_features

GROUP BY status

ORDER BY recovery_rate DESC;


-- ============================================================
-- 4. DPD RISK BANDS
-- ============================================================
-- DPD bands provide a consistent portfolio-risk view.
--
-- 0-29
-- 30-59
-- 60-89
-- 90-119
-- 120+
-- ============================================================

WITH dpd_banded AS (

    SELECT

        CASE
            WHEN dpd < 30
                THEN '0-29'

            WHEN dpd < 60
                THEN '30-59'

            WHEN dpd < 90
                THEN '60-89'

            WHEN dpd < 120
                THEN '90-119'

            ELSE '120+'
        END AS dpd_band,

        CASE
            WHEN dpd < 30
                THEN 1

            WHEN dpd < 60
                THEN 2

            WHEN dpd < 90
                THEN 3

            WHEN dpd < 120
                THEN 4

            ELSE 5
        END AS band_order,

        recovered_account,
        total_payment_amount,
        outstanding_amount,
        dpd

    FROM account_features
)

SELECT

    dpd_band,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    COUNT(*) - SUM(recovered_account)
        AS unrecovered_accounts,

    ROUND(
        CAST(SUM(recovered_account) AS DOUBLE)
        / NULLIF(COUNT(*), 0),
        6
    ) AS recovery_rate,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        SUM(outstanding_amount),
        2
    ) AS outstanding_amount,

    ROUND(
        AVG(dpd),
        2
    ) AS avg_dpd

FROM dpd_banded

GROUP BY
    dpd_band,
    band_order

ORDER BY
    band_order;


-- ============================================================
-- 5. CALL EXPOSURE PORTFOLIO METRICS
-- ============================================================
-- Call exposure bands:
--
-- 0-2 calls
-- 3-4 calls
-- 5+ calls
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
        total_calls,
        total_attempts,
        total_call_duration_sec

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
        CAST(SUM(recovered_account) AS DOUBLE)
        / NULLIF(COUNT(*), 0),
        6
    ) AS recovery_rate,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        AVG(total_calls),
        2
    ) AS avg_calls,

    ROUND(
        AVG(total_attempts),
        2
    ) AS avg_attempts,

    ROUND(
        AVG(total_call_duration_sec),
        2
    ) AS avg_call_duration_sec

FROM call_banded

GROUP BY
    call_exposure_band,
    band_order

ORDER BY
    band_order;


-- ============================================================
-- 6. COMBINED PORTFOLIO VIEW
-- ============================================================
-- Provides a compact business-facing summary across
-- loan type, risk segment, and account status.
-- ============================================================

SELECT

    loan_type,

    risk_segment,

    status,

    COUNT(*) AS accounts,

    SUM(recovered_account)
        AS recovered_accounts,

    COUNT(*) - SUM(recovered_account)
        AS unrecovered_accounts,

    ROUND(
        CAST(SUM(recovered_account) AS DOUBLE)
        / NULLIF(COUNT(*), 0),
        6
    ) AS recovery_rate,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    ROUND(
        SUM(outstanding_amount),
        2
    ) AS outstanding_amount,

    ROUND(
        SUM(total_payment_amount)
        / NULLIF(SUM(outstanding_amount), 0),
        6
    ) AS recovery_to_outstanding_ratio,

    ROUND(
        AVG(dpd),
        2
    ) AS avg_dpd,

    ROUND(
        AVG(total_calls),
        2
    ) AS avg_calls

FROM account_features

GROUP BY
    loan_type,
    risk_segment,
    status

ORDER BY
    recovery_rate DESC;


-- ============================================================
-- 7. PORTFOLIO RECOVERY CONCENTRATION
-- ============================================================
-- Identifies loan types contributing the largest share
-- of total portfolio recovery amount.
-- ============================================================

WITH loan_recovery AS (

    SELECT

        loan_type,

        SUM(total_payment_amount)
            AS recovery_amount

    FROM account_features

    GROUP BY loan_type

),

portfolio_total AS (

    SELECT

        SUM(total_payment_amount)
            AS total_recovery_amount

    FROM account_features
)

SELECT

    l.loan_type,

    ROUND(
        l.recovery_amount,
        2
    ) AS recovery_amount,

    ROUND(
        100.0
        * l.recovery_amount
        / NULLIF(
            p.total_recovery_amount,
            0
        ),
        2
    ) AS pct_of_total_recovery

FROM loan_recovery l

CROSS JOIN portfolio_total p

ORDER BY
    l.recovery_amount DESC;