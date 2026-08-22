-- ============================================================
-- CREDRESOLVE
-- TRANSFORMATIONS — CALL ACTIVITY
-- ============================================================
-- Purpose:
-- Aggregate calls, attempts, dispositions, and targeting
-- independently at account level.
--
-- Each activity source is aggregated BEFORE joining so that
-- one-to-many relationships do not inflate metrics.
--
-- Raw source data is NOT modified.
-- ============================================================


-- ============================================================
-- 1. CALL ACTIVITY BY ACCOUNT
-- ============================================================

CREATE OR REPLACE VIEW account_call_activity AS

WITH call_summary AS (

    SELECT
        account_id,

        COUNT(DISTINCT call_id)
            AS total_calls,

        COALESCE(
            SUM(duration_sec),
            0
        ) AS total_call_duration_sec,

        COUNT(DISTINCT campaign_id)
            AS call_campaign_count,

        COUNT(DISTINCT vendor_id)
            AS vendor_count,

        COUNT(DISTINCT agent_id)
            AS agent_count

    FROM clean_calls

    GROUP BY account_id
),

attempt_summary AS (

    SELECT
        account_id,

        COUNT(DISTINCT attempt_id)
            AS total_attempts

    FROM clean_call_attempts

    GROUP BY account_id
),

disposition_summary AS (

    SELECT
        account_id,

        COUNT(DISTINCT disposition_id)
            AS disposition_events

    FROM clean_call_dispositions

    GROUP BY account_id
)

SELECT

    a.account_id,

    COALESCE(
        c.total_calls,
        0
    ) AS total_calls,

    COALESCE(
        c.total_call_duration_sec,
        0
    ) AS total_call_duration_sec,

    COALESCE(
        ats.total_attempts,
        0
    ) AS total_attempts,

    COALESCE(
        d.disposition_events,
        0
    ) AS disposition_events,

    COALESCE(
        c.call_campaign_count,
        0
    ) AS call_campaign_count,

    COALESCE(
        c.vendor_count,
        0
    ) AS vendor_count,

    COALESCE(
        c.agent_count,
        0
    ) AS agent_count

FROM clean_accounts a

LEFT JOIN call_summary c
    ON a.account_id = c.account_id

LEFT JOIN attempt_summary ats
    ON a.account_id = ats.account_id

LEFT JOIN disposition_summary d
    ON a.account_id = d.account_id;


-- ============================================================
-- 2. TARGETING ACTIVITY BY ACCOUNT
-- ============================================================

CREATE OR REPLACE VIEW account_targeting_activity AS

SELECT

    a.account_id,

    COUNT(DISTINCT dt.target_id)
        AS targeting_events,

    COUNT(DISTINCT dt.campaign_id)
        AS targeting_campaigns

FROM clean_accounts a

LEFT JOIN clean_daily_targeting dt
    ON a.account_id = dt.account_id

GROUP BY
    a.account_id;


-- ============================================================
-- 3. COMBINED ACCOUNT ACTIVITY
-- ============================================================

CREATE OR REPLACE VIEW account_activity AS

SELECT

    a.account_id,

    COALESCE(
        c.total_calls,
        0
    ) AS total_calls,

    COALESCE(
        c.total_call_duration_sec,
        0
    ) AS total_call_duration_sec,

    COALESCE(
        c.total_attempts,
        0
    ) AS total_attempts,

    COALESCE(
        c.disposition_events,
        0
    ) AS disposition_events,

    COALESCE(
        c.call_campaign_count,
        0
    ) AS call_campaign_count,

    COALESCE(
        c.vendor_count,
        0
    ) AS vendor_count,

    COALESCE(
        c.agent_count,
        0
    ) AS agent_count,

    COALESCE(
        t.targeting_events,
        0
    ) AS targeting_events,

    COALESCE(
        t.targeting_campaigns,
        0
    ) AS targeting_campaigns

FROM clean_accounts a

LEFT JOIN account_call_activity c
    ON a.account_id = c.account_id

LEFT JOIN account_targeting_activity t
    ON a.account_id = t.account_id;


-- ============================================================
-- 4. CALL EXPOSURE SUMMARY
-- ============================================================

SELECT

    total_calls,

    COUNT(*) AS accounts,

    SUM(
        CASE
            WHEN total_calls > 0
            THEN 1
            ELSE 0
        END
    ) AS accounts_with_calls,

    ROUND(
        AVG(total_call_duration_sec),
        2
    ) AS avg_call_duration_sec,

    ROUND(
        AVG(total_attempts),
        2
    ) AS avg_attempts

FROM account_activity

GROUP BY total_calls

ORDER BY total_calls;


-- ============================================================
-- 5. OVERALL ACTIVITY SUMMARY
-- ============================================================

SELECT

    COUNT(*) AS accounts,

    SUM(total_calls)
        AS total_calls,

    SUM(total_attempts)
        AS total_attempts,

    SUM(total_call_duration_sec)
        AS total_call_duration_sec,

    SUM(disposition_events)
        AS total_disposition_events,

    SUM(call_campaign_count)
        AS total_call_campaign_count,

    SUM(vendor_count)
        AS total_vendor_exposure,

    SUM(agent_count)
        AS total_agent_exposure,

    SUM(targeting_events)
        AS total_targeting_events

FROM account_activity;