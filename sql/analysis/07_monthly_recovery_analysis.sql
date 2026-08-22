-- ============================================================
-- CREDRESOLVE
-- ANALYSIS — MONTHLY RECOVERY & 11% CLAIM
-- ============================================================
-- Purpose:
-- Reconstruct monthly recovery performance and explicitly test:
--
-- "Recovery has improved by 11% month-on-month."
--
-- Recovery is based on SUCCESS payments only.
-- Duplicate payment IDs are removed before aggregation.
--
-- Two recovery-rate denominators are reported:
--
-- 1. Worked-account recovery rate:
--    recovered accounts / accounts with payment activity
--
-- 2. Portfolio recovery rate:
--    recovered accounts / total portfolio accounts
--
-- August 2026 is a partial month and is excluded from the
-- 11% claim verdict.
-- ============================================================


-- ============================================================
-- 1. MONTHLY RECOVERY ANALYSIS
-- ============================================================

CREATE OR REPLACE TABLE monthly_recovery_analysis AS

WITH deduplicated_payments AS (

    SELECT
        payment_id,
        account_id,
        event_at,
        amount,
        payment_status

    FROM (

        SELECT
            cp.*,

            ROW_NUMBER() OVER (
                PARTITION BY payment_id
                ORDER BY event_at, payment_id
            ) AS rn

        FROM clean_payments cp

    )

    WHERE rn = 1
),


monthly_payment_activity AS (

    SELECT

        DATE_TRUNC(
            'month',
            event_at
        ) AS recovery_month,

        COUNT(
            DISTINCT account_id
        ) AS accounts_with_payment_activity,

        COUNT(
            DISTINCT CASE
                WHEN payment_status = 'SUCCESS'
                THEN account_id
            END
        ) AS recovered_accounts,

        SUM(
            CASE
                WHEN payment_status = 'SUCCESS'
                THEN amount
                ELSE 0
            END
        ) AS recovery_amount

    FROM deduplicated_payments

    GROUP BY
        DATE_TRUNC('month', event_at)
),


portfolio_size AS (

    SELECT
        COUNT(DISTINCT account_id)
            AS total_portfolio_accounts

    FROM clean_accounts
),


monthly_with_rates AS (

    SELECT

        m.recovery_month,

        m.accounts_with_payment_activity,

        m.recovered_accounts,

        m.recovery_amount,

        p.total_portfolio_accounts,

        ROUND(
            100.0
            * m.recovered_accounts
            / NULLIF(
                m.accounts_with_payment_activity,
                0
            ),
            2
        ) AS worked_account_recovery_rate_pct,

        ROUND(
            100.0
            * m.recovered_accounts
            / NULLIF(
                p.total_portfolio_accounts,
                0
            ),
            2
        ) AS portfolio_recovery_rate_pct

    FROM monthly_payment_activity m

    CROSS JOIN portfolio_size p
),


monthly_with_previous AS (

    SELECT

        *,

        LAG(recovered_accounts)
            OVER (
                ORDER BY recovery_month
            ) AS previous_recovered_accounts,

        LAG(recovery_amount)
            OVER (
                ORDER BY recovery_month
            ) AS previous_recovery_amount,

        LAG(worked_account_recovery_rate_pct)
            OVER (
                ORDER BY recovery_month
            ) AS previous_worked_account_recovery_rate_pct,

        LAG(portfolio_recovery_rate_pct)
            OVER (
                ORDER BY recovery_month
            ) AS previous_portfolio_recovery_rate_pct

    FROM monthly_with_rates
)


SELECT

    recovery_month,

    accounts_with_payment_activity,

    recovered_accounts,

    ROUND(
        recovery_amount,
        2
    ) AS recovery_amount,

    total_portfolio_accounts,

    worked_account_recovery_rate_pct,

    portfolio_recovery_rate_pct,

    previous_recovered_accounts,

    previous_recovery_amount,

    ROUND(
        100.0
        * (
            recovered_accounts
            - previous_recovered_accounts
        )
        / NULLIF(
            previous_recovered_accounts,
            0
        ),
        2
    ) AS recovered_accounts_mom_pct,

    ROUND(
        100.0
        * (
            recovery_amount
            - previous_recovery_amount
        )
        / NULLIF(
            previous_recovery_amount,
            0
        ),
        2
    ) AS recovery_amount_mom_pct,

    ROUND(
        worked_account_recovery_rate_pct
        - previous_worked_account_recovery_rate_pct,
        2
    ) AS worked_account_recovery_rate_change_pp,

    ROUND(
        portfolio_recovery_rate_pct
        - previous_portfolio_recovery_rate_pct,
        2
    ) AS portfolio_recovery_rate_change_pp,

    CASE
        WHEN recovery_month = DATE '2026-08-01'
        THEN 'PARTIAL_MONTH'
        ELSE 'FULL_MONTH'
    END AS month_status

FROM monthly_with_previous

ORDER BY recovery_month;


-- ============================================================
-- 2. MONTHLY OUTPUT FILE
-- ============================================================

COPY (

    SELECT

        recovery_month,

        accounts_with_payment_activity,

        recovered_accounts,

        recovery_amount,

        total_portfolio_accounts,

        worked_account_recovery_rate_pct,

        portfolio_recovery_rate_pct,

        recovered_accounts_mom_pct,

        recovery_amount_mom_pct,

        worked_account_recovery_rate_change_pp,

        portfolio_recovery_rate_change_pp,

        month_status

    FROM monthly_recovery_analysis

    ORDER BY recovery_month

)
TO 'outputs/monthly_recovery_trend.csv'
WITH (
    HEADER,
    DELIMITER ','
);


-- ============================================================
-- 3. 11% CLAIM VERDICT
-- ============================================================
-- Claim:
-- "Recovery has improved by 11% month-on-month."
--
-- Only comparable FULL_MONTH periods are evaluated.
-- August is excluded because it is a partial month.
--
-- The claim is checked using:
--
-- A. Recovery amount MoM %
-- B. Recovered accounts MoM %
--
-- A claim of consistent 11% improvement is supported only
-- if every comparable full-month MoM period reaches >= 11%.
-- ============================================================

CREATE OR REPLACE TABLE monthly_recovery_claim_verdict AS

WITH full_months AS (

    SELECT

        recovery_month,

        recovered_accounts,

        recovery_amount,

        worked_account_recovery_rate_pct,

        portfolio_recovery_rate_pct,

        recovered_accounts_mom_pct,

        recovery_amount_mom_pct,

        worked_account_recovery_rate_change_pp,

        portfolio_recovery_rate_change_pp

    FROM monthly_recovery_analysis

    WHERE month_status = 'FULL_MONTH'
),


comparison_periods AS (

    SELECT *

    FROM full_months

    WHERE recovery_amount_mom_pct IS NOT NULL
),


claim_summary AS (

    SELECT

        COUNT(*) AS comparable_full_month_periods,

        COUNT(
            CASE
                WHEN recovery_amount_mom_pct >= 11
                THEN 1
            END
        ) AS periods_with_11pct_recovery_amount_growth,

        COUNT(
            CASE
                WHEN recovered_accounts_mom_pct >= 11
                THEN 1
            END
        ) AS periods_with_11pct_account_growth,

        ROUND(
            AVG(recovery_amount_mom_pct),
            2
        ) AS average_recovery_amount_mom_pct,

        ROUND(
            AVG(recovered_accounts_mom_pct),
            2
        ) AS average_recovered_accounts_mom_pct,

        ROUND(
            MAX(recovery_amount_mom_pct),
            2
        ) AS maximum_recovery_amount_mom_pct,

        ROUND(
            MIN(recovery_amount_mom_pct),
            2
        ) AS minimum_recovery_amount_mom_pct

    FROM comparison_periods
)


SELECT

    comparable_full_month_periods,

    periods_with_11pct_recovery_amount_growth,

    periods_with_11pct_account_growth,

    average_recovery_amount_mom_pct,

    average_recovered_accounts_mom_pct,

    maximum_recovery_amount_mom_pct,

    minimum_recovery_amount_mom_pct,

    CASE

        WHEN periods_with_11pct_recovery_amount_growth
             = comparable_full_month_periods

        THEN 'SUPPORTED'

        ELSE 'NOT SUPPORTED'

    END AS recovery_amount_11pct_claim_verdict,

    CASE

        WHEN periods_with_11pct_account_growth
             = comparable_full_month_periods

        THEN 'SUPPORTED'

        ELSE 'NOT SUPPORTED'

    END AS recovered_accounts_11pct_claim_verdict,

    'Only comparable FULL_MONTH MoM periods are evaluated. August 2026 is excluded because it is a PARTIAL_MONTH.'

        AS verdict_basis

FROM claim_summary;


-- ============================================================
-- 4. FULL-MONTH AUDIT TABLE
-- ============================================================

SELECT

    recovery_month,

    recovered_accounts,

    ROUND(
        recovery_amount,
        2
    ) AS recovery_amount,

    worked_account_recovery_rate_pct,

    portfolio_recovery_rate_pct,

    recovered_accounts_mom_pct,

    recovery_amount_mom_pct,

    worked_account_recovery_rate_change_pp,

    portfolio_recovery_rate_change_pp

FROM monthly_recovery_analysis

WHERE month_status = 'FULL_MONTH'

ORDER BY recovery_month;


-- ============================================================
-- 5. FINAL 11% CLAIM RESULT
-- ============================================================

SELECT *

FROM monthly_recovery_claim_verdict;