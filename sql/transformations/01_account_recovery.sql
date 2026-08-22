-- ============================================================
-- CREDRESOLVE
-- TRANSFORMATIONS — ACCOUNT RECOVERY
-- ============================================================
-- Purpose:
-- Create the account-level recovery dataset from cleaned
-- payment events.
--
-- Payment records with identical payment_id, status, amount,
-- and event timestamp are treated as duplicate/re-ingested
-- records and counted only once.
--
-- Recovery definition:
--   recovered_account = account has at least one SUCCESS payment
--
-- Recovery amount:
--   sum of valid SUCCESS payment amounts after duplicate
--   payment-ID records have been removed.
-- ============================================================


CREATE OR REPLACE TABLE account_recovery AS

WITH deduplicated_payments AS (

    SELECT
        payment_id,
        account_id,
        borrower_id,
        event_at,
        payment_reference,
        amount,
        payment_status,
        payment_method,
        provider_id

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


payment_metrics AS (

    SELECT
        account_id,

        COUNT(payment_id) AS payment_count,

        -- Recovery amount includes SUCCESS payments only.
        SUM(
            CASE
                WHEN payment_status = 'SUCCESS'
                THEN amount
                ELSE 0
            END
        ) AS total_payment_amount,

        SUM(
            CASE
                WHEN payment_status = 'SUCCESS'
                THEN 1
                ELSE 0
            END
        ) AS successful_payments

    FROM deduplicated_payments

    GROUP BY account_id
)


SELECT

    a.account_id,
    a.borrower_id,
    a.loan_type,
    a.principal_amount,
    a.outstanding_amount,
    a.dpd,
    a.risk_segment,
    a.status,

    COALESCE(
        p.payment_count,
        0
    ) AS payment_count,

    COALESCE(
        p.total_payment_amount,
        0
    ) AS total_payment_amount,

    CASE
        WHEN COALESCE(
            p.successful_payments,
            0
        ) > 0
        THEN 1
        ELSE 0
    END AS recovered_account

FROM clean_accounts a

LEFT JOIN payment_metrics p
    ON a.account_id = p.account_id;


-- ============================================================
-- VALIDATION
-- ============================================================

SELECT

    COUNT(*) AS accounts_analyzed,

    SUM(recovered_account)
        AS recovered_accounts,

    COUNT(*) -
        SUM(recovered_account)
        AS unrecovered_accounts,

    ROUND(
        CAST(
            SUM(recovered_account) AS DOUBLE
        )
        / NULLIF(COUNT(*), 0),
        6
    ) AS recovery_rate,

    ROUND(
        SUM(total_payment_amount),
        2
    ) AS total_recovery_amount

FROM account_recovery;