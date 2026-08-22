-- ============================================================
-- CREDRESOLVE
-- REQUIRED COLLECTION METRICS
-- ============================================================
-- Purpose:
-- Calculate assignment-required collection metrics using the
-- cleaned source tables.
--
-- Required metrics:
-- 1. Contact Rate
-- 2. RPC Rate
-- 3. PTP Rate
-- 4. PTP Kept Rate
-- 5. Recovery Rate
-- 6. Recovery per Account
-- 7. Recovery per Agent-Hour
-- 8. Cost per ₹ Recovered
-- 9. Channel Conversion
--
-- Definitions are based only on fields available in the data.
--
-- IMPORTANT:
-- Cost per ₹ recovered is NOT estimated because the supplied
-- data contains no reliable collection/intervention cost field.
--
-- Raw source data is NOT modified.
-- ============================================================


-- ============================================================
-- 1. CALL CONTACT / RPC / PTP METRICS
-- ============================================================

CREATE OR REPLACE TABLE required_collection_metrics AS

WITH call_base AS (

    SELECT
        c.call_id,
        c.account_id,
        c.event_at

    FROM clean_calls c
),


disposition_flags AS (

    SELECT

        d.call_id,

        MAX(
            CASE
                WHEN d.disposition_code NOT IN (
                    'NO_CONTACT',
                    'WRONG_NUMBER'
                )
                THEN 1
                ELSE 0
            END
        ) AS contacted,

        MAX(
            CASE
                WHEN d.disposition_code IN (
                    'CALLBACK',
                    'DISPUTE',
                    'PAID',
                    'REFUSED',
                    'PROMISE_TO_PAY',
                    'PTP'
                )
                THEN 1
                ELSE 0
            END
        ) AS rpc,

        MAX(
            CASE
                WHEN d.disposition_code IN (
                    'PROMISE_TO_PAY',
                    'PTP'
                )
                THEN 1
                ELSE 0
            END
        ) AS ptp_event

    FROM clean_call_dispositions d

    GROUP BY d.call_id
),


call_metrics AS (

    SELECT

        COUNT(DISTINCT c.call_id)
            AS total_calls,

        COUNT(
            DISTINCT CASE
                WHEN COALESCE(f.contacted, 0) = 1
                THEN c.call_id
            END
        ) AS contacted_calls,

        COUNT(
            DISTINCT CASE
                WHEN COALESCE(f.rpc, 0) = 1
                THEN c.call_id
            END
        ) AS rpc_calls,

        COUNT(
            DISTINCT CASE
                WHEN COALESCE(f.ptp_event, 0) = 1
                THEN c.call_id
            END
        ) AS ptp_calls

    FROM call_base c

    LEFT JOIN disposition_flags f
        ON c.call_id = f.call_id
),


ptp_metrics AS (

    SELECT

        COUNT(*) AS total_ptps,

        COUNT(
            CASE
                WHEN status = 'KEPT'
                THEN 1
            END
        ) AS kept_ptps,

        COUNT(
            CASE
                WHEN status = 'BROKEN'
                THEN 1
            END
        ) AS broken_ptps

    FROM promises_to_pay
),


agent_hours AS (

    SELECT

        SUM(
            EXTRACT(
                EPOCH FROM (
                    logout_at - login_at
                )
            )
        ) / 3600.0 AS total_agent_hours

    FROM agent_sessions

    WHERE login_at IS NOT NULL
      AND logout_at IS NOT NULL
      AND logout_at >= login_at
),


recovery AS (

    SELECT

        SUM(recovered_account)
            AS recovered_accounts,

        SUM(total_payment_amount)
            AS recovery_amount

    FROM account_features
)


SELECT

    -- ========================================================
    -- CALL METRICS
    -- ========================================================

    c.total_calls,

    c.contacted_calls,

    c.rpc_calls,

    c.ptp_calls,


    -- Contact Rate
    ROUND(
        100.0
        * c.contacted_calls
        / NULLIF(c.total_calls, 0),
        2
    ) AS contact_rate_pct,


    -- RPC Rate
    ROUND(
        100.0
        * c.rpc_calls
        / NULLIF(c.total_calls, 0),
        2
    ) AS rpc_rate_pct,


    -- PTP Rate
    ROUND(
        100.0
        * c.ptp_calls
        / NULLIF(c.rpc_calls, 0),
        2
    ) AS ptp_rate_pct,


    -- ========================================================
    -- PTP METRICS
    -- ========================================================

    p.total_ptps,

    p.kept_ptps,

    p.broken_ptps,


    -- PTP Kept Rate
    ROUND(
        100.0
        * p.kept_ptps
        / NULLIF(p.total_ptps, 0),
        2
    ) AS ptp_kept_rate_pct,


    -- ========================================================
    -- RECOVERY METRICS
    -- ========================================================

    r.recovered_accounts,

    r.recovery_amount,


    -- Recovery Rate
    ROUND(
        100.0
        * r.recovered_accounts
        / NULLIF(
            (
                SELECT COUNT(*)
                FROM account_features
            ),
            0
        ),
        2
    ) AS recovery_rate_pct,


    -- Recovery per Account
    ROUND(
        r.recovery_amount
        / NULLIF(r.recovered_accounts, 0),
        2
    ) AS recovery_per_account,


    -- ========================================================
    -- AGENT PRODUCTIVITY
    -- ========================================================

    a.total_agent_hours,

    ROUND(
        r.recovery_amount
        / NULLIF(a.total_agent_hours, 0),
        2
    ) AS recovery_per_agent_hour,


    -- ========================================================
    -- COST METRIC
    -- ========================================================
    --
    -- No reliable cost field exists in the supplied data.
    -- Therefore this metric is intentionally NULL.
    -- ========================================================

    CAST(NULL AS DOUBLE)
        AS cost_per_rupee_recovered,

    'NOT ESTIMABLE FROM SUPPLIED DATA: no reliable collection/intervention cost field is available'
        AS cost_metric_note


FROM call_metrics c

CROSS JOIN ptp_metrics p

CROSS JOIN agent_hours a

CROSS JOIN recovery r;



-- ============================================================
-- 2. CHANNEL CONVERSION
-- ============================================================
--
-- Channel conversion is calculated at UNIQUE MESSAGE level.
--
-- SMS:
--     unique delivered messages
--     → unique delivered messages that were clicked
--
-- WhatsApp:
--     unique delivered messages
--     → unique delivered messages with PAYMENT_CLICK
--
-- This prevents multiple event rows for the same message from
-- producing conversion rates above 100%.
-- ============================================================


CREATE OR REPLACE TABLE channel_conversion_metrics AS

WITH sms_messages AS (

    SELECT

        message_id,

        MAX(
            CASE
                WHEN event_type = 'SENT'
                THEN 1
                ELSE 0
            END
        ) AS sent,

        MAX(
            CASE
                WHEN event_type = 'DELIVERED'
                THEN 1
                ELSE 0
            END
        ) AS delivered,

        MAX(
            CASE
                WHEN event_type = 'CLICKED'
                THEN 1
                ELSE 0
            END
        ) AS clicked

    FROM sms_events

    WHERE message_id IS NOT NULL

    GROUP BY message_id
),


sms_summary AS (

    SELECT

        'SMS' AS channel,

        COUNT(
            CASE
                WHEN sent = 1
                THEN 1
            END
        ) AS sent_messages,

        COUNT(
            CASE
                WHEN delivered = 1
                THEN 1
            END
        ) AS delivered_messages,

        COUNT(
            CASE
                WHEN delivered = 1
                 AND clicked = 1
                THEN 1
            END
        ) AS conversion_events

    FROM sms_messages
),


whatsapp_messages AS (

    SELECT

        message_id,

        MAX(
            CASE
                WHEN event_type = 'SENT'
                THEN 1
                ELSE 0
            END
        ) AS sent,

        MAX(
            CASE
                WHEN event_type = 'DELIVERED'
                THEN 1
                ELSE 0
            END
        ) AS delivered,

        MAX(
            CASE
                WHEN event_type = 'PAYMENT_CLICK'
                THEN 1
                ELSE 0
            END
        ) AS payment_click

    FROM whatsapp_events

    WHERE message_id IS NOT NULL

    GROUP BY message_id
),


whatsapp_summary AS (

    SELECT

        'WHATSAPP' AS channel,

        COUNT(
            CASE
                WHEN sent = 1
                THEN 1
            END
        ) AS sent_messages,

        COUNT(
            CASE
                WHEN delivered = 1
                THEN 1
            END
        ) AS delivered_messages,

        COUNT(
            CASE
                WHEN delivered = 1
                 AND payment_click = 1
                THEN 1
            END
        ) AS conversion_events

    FROM whatsapp_messages
)


SELECT

    channel,

    sent_messages,

    delivered_messages,

    conversion_events,

    ROUND(
        100.0
        * delivered_messages
        / NULLIF(sent_messages, 0),
        2
    ) AS delivery_rate_pct,

    ROUND(
        100.0
        * conversion_events
        / NULLIF(delivered_messages, 0),
        2
    ) AS channel_conversion_rate_pct

FROM sms_summary


UNION ALL


SELECT

    channel,

    sent_messages,

    delivered_messages,

    conversion_events,

    ROUND(
        100.0
        * delivered_messages
        / NULLIF(sent_messages, 0),
        2
    ) AS delivery_rate_pct,

    ROUND(
        100.0
        * conversion_events
        / NULLIF(delivered_messages, 0),
        2
    ) AS channel_conversion_rate_pct

FROM whatsapp_summary;



-- ============================================================
-- 3. METRIC DEFINITION REGISTER
-- ============================================================

CREATE OR REPLACE TABLE required_metric_definitions AS


-- ------------------------------------------------------------
-- Contact Rate
-- ------------------------------------------------------------

SELECT

    'contact_rate' AS metric_name,

    'contacted calls / total calls' AS calculation,

    'Share of calls with a disposition indicating borrower contact rather than NO_CONTACT or WRONG_NUMBER.'
        AS definition


UNION ALL


-- ------------------------------------------------------------
-- RPC Rate
-- ------------------------------------------------------------

SELECT

    'rpc_rate',

    'RPC calls / total calls',

    'Share of calls with a disposition indicating a substantive borrower interaction.'


UNION ALL


-- ------------------------------------------------------------
-- PTP Rate
-- ------------------------------------------------------------

SELECT

    'ptp_rate',

    'PTP calls / RPC calls',

    'Share of RPC calls resulting in a promise-to-pay disposition.'


UNION ALL


-- ------------------------------------------------------------
-- PTP Kept Rate
-- ------------------------------------------------------------

SELECT

    'ptp_kept_rate',

    'KEPT PTPs / total PTPs',

    'Share of recorded promises-to-pay with status KEPT.'


UNION ALL


-- ------------------------------------------------------------
-- Recovery Rate
-- ------------------------------------------------------------

SELECT

    'recovery_rate',

    'recovered accounts / total accounts',

    'Share of portfolio accounts with at least one SUCCESS payment.'


UNION ALL


-- ------------------------------------------------------------
-- Recovery per Account
-- ------------------------------------------------------------

SELECT

    'recovery_per_account',

    'SUCCESS recovery amount / recovered accounts',

    'Average SUCCESS-based recovery amount per recovered account.'


UNION ALL


-- ------------------------------------------------------------
-- Recovery per Agent-Hour
-- ------------------------------------------------------------

SELECT

    'recovery_per_agent_hour',

    'SUCCESS recovery amount / agent hours',

    'Recovery amount generated per recorded agent session hour.'


UNION ALL


-- ------------------------------------------------------------
-- Cost per ₹ Recovered
-- ------------------------------------------------------------

SELECT

    'cost_per_rupee_recovered',

    'collection/intervention cost / SUCCESS recovery amount',

    'Not estimable from supplied data because no reliable collection or intervention cost field is available.'


UNION ALL


-- ------------------------------------------------------------
-- Channel Conversion
-- ------------------------------------------------------------

SELECT

    'channel_conversion',

    'conversion events / delivered messages',

    'For SMS, unique CLICKED messages / unique DELIVERED messages. For WhatsApp, unique PAYMENT_CLICK messages / unique DELIVERED messages.';