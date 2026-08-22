-- ============================================================
-- CREDRESOLVE
-- ANALYSIS — CALL EXPOSURE CHECK
-- ============================================================

SELECT
    CASE
        WHEN total_calls <= 2 THEN '0-2 calls'
        WHEN total_calls <= 4 THEN '3-4 calls'
        ELSE '5+ calls'
    END AS call_exposure_band,

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

    ROUND(AVG(dpd), 2) AS avg_dpd,

    ROUND(AVG(total_calls), 2) AS avg_calls,

    ROUND(AVG(total_attempts), 2) AS avg_attempts

FROM account_features

GROUP BY
    CASE
        WHEN total_calls <= 2 THEN '0-2 calls'
        WHEN total_calls <= 4 THEN '3-4 calls'
        ELSE '5+ calls'
    END

ORDER BY MIN(total_calls);