-- ============================================================
-- CREDRESOLVE
-- STAGING — LOAD RAW CSV DATA
-- ============================================================

CREATE OR REPLACE TABLE accounts AS
SELECT *
FROM read_csv_auto('data/raw/accounts.csv');

CREATE OR REPLACE TABLE account_status_history AS
SELECT *
FROM read_csv_auto('data/raw/account_status_history.csv');

CREATE OR REPLACE TABLE agents AS
SELECT *
FROM read_csv_auto('data/raw/agents.csv');

CREATE OR REPLACE TABLE agent_sessions AS
SELECT *
FROM read_csv_auto('data/raw/agent_sessions.csv');

CREATE OR REPLACE TABLE borrowers AS
SELECT *
FROM read_csv_auto('data/raw/borrowers.csv');

CREATE OR REPLACE TABLE calls AS
SELECT *
FROM read_csv_auto('data/raw/calls.csv');

CREATE OR REPLACE TABLE call_attempts AS
SELECT *
FROM read_csv_auto('data/raw/call_attempts.csv');

CREATE OR REPLACE TABLE call_dispositions AS
SELECT *
FROM read_csv_auto('data/raw/call_dispositions.csv');

CREATE OR REPLACE TABLE campaigns AS
SELECT *
FROM read_csv_auto('data/raw/campaigns.csv');

CREATE OR REPLACE TABLE complaints AS
SELECT *
FROM read_csv_auto('data/raw/complaints.csv');

CREATE OR REPLACE TABLE daily_targeting AS
SELECT *
FROM read_csv_auto('data/raw/daily_targeting.csv');

CREATE OR REPLACE TABLE field_visits AS
SELECT *
FROM read_csv_auto('data/raw/field_visits.csv');

CREATE OR REPLACE TABLE payments AS
SELECT *
FROM read_csv_auto('data/raw/payments.csv');

CREATE OR REPLACE TABLE promises_to_pay AS
SELECT *
FROM read_csv_auto('data/raw/promises_to_pay.csv');

CREATE OR REPLACE TABLE sms_events AS
SELECT *
FROM read_csv_auto('data/raw/sms_events.csv');

CREATE OR REPLACE TABLE vendor_telephony AS
SELECT *
FROM read_csv_auto('data/raw/vendor_telephony.csv');

CREATE OR REPLACE TABLE whatsapp_events AS
SELECT *
FROM read_csv_auto('data/raw/whatsapp_events.csv');


-- ============================================================
-- VALIDATE LOADED TABLES
-- ============================================================

SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'main'
ORDER BY table_name;