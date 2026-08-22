-- ============================================================
-- CREDRESOLVE
-- ANALYSIS — AGENT EXPOSURE CHECK
-- ============================================================

SELECT
    agent_count,

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

GROUP BY agent_count

ORDER BY agent_count;