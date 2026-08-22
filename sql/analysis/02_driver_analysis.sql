-- ============================================================
-- CREDRESOLVE
-- ANALYSIS — DRIVER ANALYSIS
-- ============================================================
-- Purpose:
-- Analyze descriptive associations between recovery outcomes
-- and collection-exposure variables.
--
-- IMPORTANT:
-- These results describe observed associations only.
-- They do NOT establish causal effects.
--
-- Business definition:
-- recovered_account = account with at least one SUCCESS payment.
--
-- Recovery amount:
-- total_payment_amount from account_features.
--
-- Small groups:
-- Groups with fewer than 100 accounts are flagged as
-- LOW_SAMPLE and should not be used for strong conclusions.
--
-- Raw source data is NOT modified.
-- ============================================================


-- ============================================================
-- 1. RECOVERY BY CALL EXPOSURE
-- ============================================================

WITH call_groups AS (

    SELECT

        CASE
            WHEN total_calls = 0
                THEN '0 calls'

            WHEN total_calls <= 2
                THEN '1-2 calls'

            WHEN total_calls <= 4
                THEN '3-4 calls'

            ELSE '5+ calls'
        END AS call_exposure_band,

        CASE
            WHEN total_calls = 0
                THEN 1

            WHEN total_calls <= 2
                THEN 2

            WHEN total_calls <= 4
                THEN 3

            ELSE 4
        END AS band_order,

        recovered_account,
        total_payment_amount,
        dpd,
        outstanding_amount

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
    ) AS avg_dpd,

    ROUND(
        AVG(outstanding_amount),
        2
    ) AS avg_outstanding_amount,

    CASE
        WHEN COUNT(*) < 100
            THEN 'LOW_SAMPLE'
        ELSE 'ADEQUATE_SAMPLE'
    END AS sample_flag

FROM call_groups

GROUP BY
    call_exposure_band,
    band_order

ORDER BY
    band_order;


-- ============================================================
-- 2. RECOVERY BY ATTEMPT EXPOSURE
-- ============================================================

WITH attempt_groups AS (

    SELECT

        CASE
            WHEN total_attempts = 0
                THEN '0 attempts'

            WHEN total_attempts <= 2
                THEN '1-2 attempts'

            WHEN total_attempts <= 5
                THEN '3-5 attempts'

            ELSE '6+ attempts'
        END AS attempt_exposure_band,

        recovered_account,
        total_payment_amount,
        dpd,
        outstanding_amount,
        total_attempts

    FROM account_features
)

SELECT

    attempt_exposure_band,

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
    ) AS avg_dpd,

    ROUND(
        AVG(outstanding_amount),
        2
    ) AS avg_outstanding_amount,

    CASE
        WHEN COUNT(*) < 100
            THEN 'LOW_SAMPLE'
        ELSE 'ADEQUATE_SAMPLE'
    END AS sample_flag

FROM attempt_groups

GROUP BY
    attempt_exposure_band

ORDER BY
    MIN(total_attempts);


-- ============================================================
-- 3. RECOVERY BY TARGETING EXPOSURE
-- ============================================================

SELECT

    targeted_account,

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
    ) AS avg_dpd,

    ROUND(
        AVG(outstanding_amount),
        2
    ) AS avg_outstanding_amount,

    CASE
        WHEN COUNT(*) < 100
            THEN 'LOW_SAMPLE'
        ELSE 'ADEQUATE_SAMPLE'
    END AS sample_flag

FROM account_features

GROUP BY targeted_account

ORDER BY targeted_account;


-- ============================================================
-- 4. RECOVERY BY AGENT EXPOSURE
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
        AVG(dpd),
        2
    ) AS avg_dpd,

    ROUND(
        AVG(outstanding_amount),
        2
    ) AS avg_outstanding_amount,

    CASE
        WHEN COUNT(*) < 100
            THEN 'LOW_SAMPLE'
        ELSE 'ADEQUATE_SAMPLE'
    END AS sample_flag

FROM account_features

GROUP BY agent_count

ORDER BY agent_count;


-- ============================================================
-- 5. RECOVERY BY VENDOR EXPOSURE
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
        AVG(dpd),
        2
    ) AS avg_dpd,

    ROUND(
        AVG(outstanding_amount),
        2
    ) AS avg_outstanding_amount,

    CASE
        WHEN COUNT(*) < 100
            THEN 'LOW_SAMPLE'
        ELSE 'ADEQUATE_SAMPLE'
    END AS sample_flag

FROM account_features

GROUP BY vendor_count

ORDER BY vendor_count;


-- ============================================================
-- 6. RECOVERY BY RISK SEGMENT
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
        AVG(dpd),
        2
    ) AS avg_dpd,

    ROUND(
        AVG(outstanding_amount),
        2
    ) AS avg_outstanding_amount,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    CASE
        WHEN COUNT(*) < 100
            THEN 'LOW_SAMPLE'
        ELSE 'ADEQUATE_SAMPLE'
    END AS sample_flag

FROM account_features

GROUP BY risk_segment

ORDER BY recovery_rate_pct DESC;


-- ============================================================
-- 7. RECOVERY BY LOAN TYPE
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
        AVG(dpd),
        2
    ) AS avg_dpd,

    ROUND(
        AVG(outstanding_amount),
        2
    ) AS avg_outstanding_amount,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS recovery_amount,

    CASE
        WHEN COUNT(*) < 100
            THEN 'LOW_SAMPLE'
        ELSE 'ADEQUATE_SAMPLE'
    END AS sample_flag

FROM account_features

GROUP BY loan_type

ORDER BY recovery_rate_pct DESC;


-- ============================================================
-- 8. RECOVERY BY DPD BAND
-- ============================================================

WITH dpd_groups AS (

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
        outstanding_amount

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

    CASE
        WHEN COUNT(*) < 100
            THEN 'LOW_SAMPLE'
        ELSE 'ADEQUATE_SAMPLE'
    END AS sample_flag

FROM dpd_groups

GROUP BY
    dpd_band,
    band_order

ORDER BY
    band_order;


-- ============================================================
-- 9. RECOVERY BY ACCOUNT STATUS
-- ============================================================

SELECT

    status,

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

    CASE
        WHEN COUNT(*) < 100
            THEN 'LOW_SAMPLE'
        ELSE 'ADEQUATE_SAMPLE'
    END AS sample_flag

FROM account_features

GROUP BY status

ORDER BY recovery_rate_pct DESC;


-- ============================================================
-- 10. RECOVERY BY CALL DIRECTION / CHANNEL
-- ============================================================
-- Direction is the available call-level channel indicator.
-- INBOUND and OUTBOUND are compared descriptively.
-- This does NOT establish that one direction causes better recovery.
-- ============================================================

SELECT

    c.direction AS call_direction,

    COUNT(DISTINCT c.account_id)
        AS accounts,

    COUNT(
        DISTINCT CASE
            WHEN a.recovered_account = 1
                THEN c.account_id
        END
    ) AS recovered_accounts,

    COUNT(DISTINCT c.account_id)
    -
    COUNT(
        DISTINCT CASE
            WHEN a.recovered_account = 1
                THEN c.account_id
        END
    ) AS unrecovered_accounts,

    ROUND(
        100.0
        *
        COUNT(
            DISTINCT CASE
                WHEN a.recovered_account = 1
                    THEN c.account_id
            END
        )
        /
        NULLIF(
            COUNT(DISTINCT c.account_id),
            0
        ),
        2
    ) AS recovery_rate_pct,

    ROUND(
        SUM(
            CASE
                WHEN a.recovered_account = 1
                    THEN a.total_payment_amount
                ELSE 0
            END
        ),
        2
    ) AS recovery_amount,

    CASE
        WHEN COUNT(DISTINCT c.account_id) < 100
            THEN 'LOW_SAMPLE'
        ELSE 'ADEQUATE_SAMPLE'
    END AS sample_flag

FROM clean_calls c

LEFT JOIN account_features a
    ON c.account_id = a.account_id

GROUP BY
    c.direction

ORDER BY
    recovery_rate_pct DESC;


-- ============================================================
-- 11. RECOVERY BY CALLING TIME
-- ============================================================
-- Calling time is derived from call event_at.
-- Four broad time bands are used to avoid over-interpreting
-- individual hourly fluctuations.
--
-- This is descriptive only and does NOT establish that
-- calling at a particular time causes better recovery.
-- ============================================================

WITH calling_time_groups AS (

    SELECT

        CASE
            WHEN EXTRACT(HOUR FROM c.event_at)
                 BETWEEN 0 AND 5
                THEN '00-05'

            WHEN EXTRACT(HOUR FROM c.event_at)
                 BETWEEN 6 AND 11
                THEN '06-11'

            WHEN EXTRACT(HOUR FROM c.event_at)
                 BETWEEN 12 AND 17
                THEN '12-17'

            ELSE '18-23'
        END AS calling_time_band,

        CASE
            WHEN EXTRACT(HOUR FROM c.event_at)
                 BETWEEN 0 AND 5
                THEN 1

            WHEN EXTRACT(HOUR FROM c.event_at)
                 BETWEEN 6 AND 11
                THEN 2

            WHEN EXTRACT(HOUR FROM c.event_at)
                 BETWEEN 12 AND 17
                THEN 3

            ELSE 4
        END AS band_order,

        c.account_id,

        a.recovered_account,
        a.total_payment_amount

    FROM clean_calls c

    LEFT JOIN account_features a
        ON c.account_id = a.account_id
)

SELECT

    calling_time_band,

    COUNT(DISTINCT account_id)
        AS accounts,

    COUNT(
        DISTINCT CASE
            WHEN recovered_account = 1
                THEN account_id
        END
    ) AS recovered_accounts,

    COUNT(DISTINCT account_id)
    -
    COUNT(
        DISTINCT CASE
            WHEN recovered_account = 1
                THEN account_id
        END
    ) AS unrecovered_accounts,

    ROUND(
        100.0
        *
        COUNT(
            DISTINCT CASE
                WHEN recovered_account = 1
                    THEN account_id
            END
        )
        /
        NULLIF(
            COUNT(DISTINCT account_id),
            0
        ),
        2
    ) AS recovery_rate_pct,

    ROUND(
        SUM(
            CASE
                WHEN recovered_account = 1
                    THEN total_payment_amount
                ELSE 0
            END
        ),
        2
    ) AS recovery_amount,

    CASE
        WHEN COUNT(DISTINCT account_id) < 100
            THEN 'LOW_SAMPLE'
        ELSE 'ADEQUATE_SAMPLE'
    END AS sample_flag

FROM calling_time_groups

GROUP BY
    calling_time_band,
    band_order

ORDER BY
    band_order;