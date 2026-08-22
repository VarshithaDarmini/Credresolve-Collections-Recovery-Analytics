-- ============================================================
-- CREDRESOLVE
-- METRICS — RECOVERY METRICS
-- ============================================================
-- Purpose:
-- Create reproducible business metrics from the account-level
-- analytical feature dataset.
--
-- Metric definitions:
--
-- recovered_account:
--     Account has at least one SUCCESS payment.
--
-- recovery_amount:
--     Sum of payment amounts retained in clean_payments
--     and attributed to the analyzed account.
--
-- Raw source data is NOT modified.
-- ============================================================


-- ============================================================
-- 1. OVERALL RECOVERY METRICS
-- ============================================================

SELECT

    COUNT(*) AS accounts_analyzed,

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
    ) AS recovery_amount_to_outstanding_ratio

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
        CAST(SUM(recovered_account) AS DOUBLE)
        / NULLIF(COUNT(*), 0),
        6
    ) AS recovery_rate,

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

ORDER BY recovery_rate DESC;


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
        CAST(SUM(recovered_account) AS DOUBLE)
        / NULLIF(COUNT(*), 0),
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
-- 4. RECOVERY BY ACCOUNT STATUS
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
    ) AS recovery_amount

FROM account_features

GROUP BY status

ORDER BY recovery_rate DESC;


-- ============================================================
-- 5. RECOVERY BY CALL EXPOSURE
-- ============================================================

SELECT

    call_exposed,

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
    ) AS avg_attempts

FROM account_features

GROUP BY call_exposed

ORDER BY call_exposed;


-- ============================================================
-- 6. RECOVERY BY CALL EXPOSURE BUCKET
-- ============================================================
-- Buckets:
--     0-2 calls
--     3 calls
--     4 calls
--     5+ calls
--
-- A separate bucket_order field is used so DuckDB can sort
-- the grouped result correctly.
-- ============================================================

WITH bucketed_accounts AS (

    SELECT

        CASE
            WHEN total_calls <= 2
                THEN '0-2 calls'

            WHEN total_calls = 3
                THEN '3 calls'

            WHEN total_calls = 4
                THEN '4 calls'

            ELSE '5+ calls'
        END AS call_exposure_bucket,

        CASE
            WHEN total_calls <= 2
                THEN 1

            WHEN total_calls = 3
                THEN 2

            WHEN total_calls = 4
                THEN 3

            ELSE 4
        END AS bucket_order,

        recovered_account,

        total_payment_amount,

        dpd

    FROM account_features
)

SELECT

    call_exposure_bucket,

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
        AVG(dpd),
        2
    ) AS avg_dpd

FROM bucketed_accounts

GROUP BY
    call_exposure_bucket,
    bucket_order

ORDER BY
    bucket_order;


-- ============================================================
-- 7. AVERAGE RECOVERY PER RECOVERED ACCOUNT
-- ============================================================

SELECT

    ROUND(
        SUM(total_payment_amount)
        / NULLIF(
            SUM(recovered_account),
            0
        ),
        2
    ) AS average_recovery_per_recovered_account

FROM account_features;


-- ============================================================
-- 8. PORTFOLIO SUMMARY
-- ============================================================

SELECT

    COUNT(*) AS accounts,

    COUNT(DISTINCT borrower_id)
        AS borrowers,

    COUNT(DISTINCT loan_type)
        AS loan_types,

    COUNT(DISTINCT risk_segment)
        AS risk_segments,

    ROUND(
        SUM(principal_amount),
        2
    ) AS total_principal_amount,

    ROUND(
        SUM(outstanding_amount),
        2
    ) AS total_outstanding_amount,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS total_recovery_amount,

    ROUND(
        CAST(SUM(recovered_account) AS DOUBLE)
        / NULLIF(COUNT(*), 0),
        6
    ) AS overall_recovery_rate

FROM account_features;


-- ============================================================
-- 9. METRIC DEFINITION REGISTER
-- ============================================================

SELECT

    'accounts_analyzed'
        AS metric_name,

    'COUNT(*)'
        AS calculation,

    'Number of account-level analytical records'
        AS definition

UNION ALL

SELECT

    'recovered_accounts',

    'SUM(recovered_account)',

    'Accounts with at least one SUCCESS payment'

UNION ALL

SELECT

    'unrecovered_accounts',

    'accounts_analyzed - recovered_accounts',

    'Accounts with no SUCCESS payment'

UNION ALL

SELECT

    'recovery_rate',

    'recovered_accounts / accounts_analyzed',

    'Share of analyzed accounts with at least one SUCCESS payment'

UNION ALL

SELECT

    'recovery_amount',

    'SUM(total_payment_amount)',

    'Sum of payment amounts retained in clean_payments and attributed to analyzed accounts'

UNION ALL

SELECT

    'average_recovery_per_recovered_account',

    'recovery_amount / recovered_accounts',

    'Average payment amount per account classified as recovered';