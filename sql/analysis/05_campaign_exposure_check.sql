-- ============================================================
-- CREDRESOLVE
-- ANALYSIS — CAMPAIGN EXPOSURE CHECK
-- ============================================================

SELECT
    call_campaign_count,

    COUNT(*) AS accounts,

    SUM(recovered_account) AS recovered_accounts,

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

    ROUND(AVG(total_calls), 2)
        AS avg_calls,

    ROUND(AVG(total_attempts), 2)
        AS avg_attempts

FROM account_features

GROUP BY call_campaign_count

ORDER BY call_campaign_count;