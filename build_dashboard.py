from pathlib import Path
import duckdb
import json
import pandas as pd
import re


# ============================================================
# PATHS
# ============================================================

ROOT = Path(__file__).resolve().parent

DB = ROOT / "credresolve.duckdb"
HTML = ROOT / "dashboard" / "index.html"
OUT = ROOT / "outputs" / "tables"


# ============================================================
# HELPERS
# ============================================================

def table_exists(con, table_name):

    return (
        con.execute(
            """
            SELECT COUNT(*)
            FROM information_schema.tables
            WHERE table_schema = 'main'
              AND table_name = ?
            """,
            [table_name]
        ).fetchone()[0] > 0
    )


def to_records(df):

    if df is None or df.empty:
        return []

    return json.loads(
        df.to_json(
            orient="records",
            date_format="iso"
        )
    )


def read_csv_records(filename):

    path = OUT / filename

    if not path.exists():
        return []

    return json.loads(
        pd.read_csv(path).to_json(
            orient="records"
        )
    )


# ============================================================
# CHECK FILES
# ============================================================

if not DB.exists():

    raise FileNotFoundError(
        f"\nDatabase not found:\n{DB}"
    )


if not HTML.exists():

    raise FileNotFoundError(
        f"\nDashboard not found:\n{HTML}"
    )


# ============================================================
# CONNECT TO DUCKDB
# ============================================================

con = duckdb.connect(
    str(DB),
    read_only=True
)


# ============================================================
# CHECK REQUIRED BACKEND TABLES
# ============================================================

required_tables = [
    "account_features",
    "clean_payments",
    "monthly_recovery_analysis"
]


for table in required_tables:

    if not table_exists(con, table):

        raise RuntimeError(
            f"\nRequired backend table is missing: {table}"
        )


# ============================================================
# 1. PORTFOLIO
# ============================================================

portfolio_row = con.execute(
    """
    SELECT

        COUNT(*) AS accounts,

        SUM(
            COALESCE(
                recovered_account,
                0
            )
        ) AS recovered_accounts,

        ROUND(
            100.0
            *
            SUM(
                COALESCE(
                    recovered_account,
                    0
                )
            )
            /
            NULLIF(
                COUNT(*),
                0
            ),
            2
        ) AS recovery_rate_pct,

        ROUND(
            SUM(
                COALESCE(
                    total_payment_amount,
                    0
                )
            ),
            2
        ) AS recovery_amount

    FROM account_features
    """
).fetchone()


if portfolio_row is None:

    raise RuntimeError(
        "Portfolio query returned no result."
    )


portfolio = {

    "accounts":
        int(portfolio_row[0]),

    "recovered_accounts":
        int(portfolio_row[1]),

    "recovery_rate_pct":
        float(portfolio_row[2]),

    "recovery_amount":
        float(portfolio_row[3])

}


if portfolio["recovered_accounts"] <= 0:

    raise RuntimeError(
        "Backend returned zero recovered accounts."
    )


portfolio[
    "recovery_per_recovered_account"
] = round(

    portfolio["recovery_amount"]
    /
    portfolio["recovered_accounts"],

    2
)


# ============================================================
# 2. LOAN TYPE
# ============================================================

loan_type = to_records(
    con.execute(
        """
        SELECT

            loan_type,

            COUNT(*) AS accounts,

            ROUND(
                100.0
                *
                SUM(
                    COALESCE(
                        recovered_account,
                        0
                    )
                )
                /
                NULLIF(
                    COUNT(*),
                    0
                ),
                2
            ) AS recovery_rate_pct

        FROM account_features

        WHERE loan_type IS NOT NULL

        GROUP BY loan_type

        ORDER BY recovery_rate_pct DESC
        """
    ).fetchdf()
)


# ============================================================
# 3. RISK SEGMENT
# ============================================================

risk_segment = to_records(
    con.execute(
        """
        SELECT

            risk_segment,

            COUNT(*) AS accounts,

            ROUND(
                100.0
                *
                SUM(
                    COALESCE(
                        recovered_account,
                        0
                    )
                )
                /
                NULLIF(
                    COUNT(*),
                    0
                ),
                2
            ) AS recovery_rate_pct

        FROM account_features

        WHERE risk_segment IS NOT NULL

        GROUP BY risk_segment

        ORDER BY recovery_rate_pct DESC
        """
    ).fetchdf()
)


# ============================================================
# 4. MONTHLY RECOVERY
#
# IMPORTANT:
#
# recovery_amount and MoM values come from the existing
# validated monthly_recovery_analysis table.
#
# is_partial is NOT assumed to exist in that table.
#
# Instead, it is derived from the actual SUCCESS payment
# dates in clean_payments.
# ============================================================

monthly_recovery = to_records(
    con.execute(
        """
        WITH payment_dates AS (

            SELECT

                DATE_TRUNC(
                    'month',
                    event_at
                ) AS recovery_month,

                MAX(event_at)
                    AS max_event_at

            FROM clean_payments

            WHERE UPPER(
                COALESCE(
                    payment_status,
                    ''
                )
            ) = 'SUCCESS'

            GROUP BY 1
        )

        SELECT

            m.recovery_month,

            m.recovery_amount,

            m.recovery_amount_mom_pct,

            CASE

                WHEN p.max_event_at IS NULL

                    THEN FALSE

                WHEN p.max_event_at
                    <
                    DATE_TRUNC(
                        'month',
                        m.recovery_month
                    )
                    +
                    INTERVAL '1 month'
                    -
                    INTERVAL '1 day'

                    THEN TRUE

                ELSE FALSE

            END AS is_partial

        FROM monthly_recovery_analysis m

        LEFT JOIN payment_dates p

            ON p.recovery_month =
               m.recovery_month

        ORDER BY m.recovery_month
        """
    ).fetchdf()
)


if not monthly_recovery:

    raise RuntimeError(
        "monthly_recovery_analysis contains no rows."
    )


# ============================================================
# 5. MONTHLY RECOVERED ACCOUNTS
#
# Calculated from deduplicated SUCCESS payments.
# ============================================================

monthly_recovered_accounts = to_records(
    con.execute(
        """
        WITH dedup AS (

            SELECT

                *,

                ROW_NUMBER() OVER (

                    PARTITION BY payment_id

                    ORDER BY
                        event_at,
                        payment_id

                ) AS rn

            FROM clean_payments
        ),

        monthly AS (

            SELECT

                DATE_TRUNC(
                    'month',
                    event_at
                ) AS recovery_month,

                COUNT(
                    DISTINCT account_id
                ) AS recovered_accounts

            FROM dedup

            WHERE rn = 1

            AND UPPER(
                COALESCE(
                    payment_status,
                    ''
                )
            ) = 'SUCCESS'

            GROUP BY 1
        )

        SELECT

            recovery_month,

            recovered_accounts,

            ROUND(

                100.0
                *
                (
                    recovered_accounts
                    /
                    LAG(
                        recovered_accounts
                    ) OVER(
                        ORDER BY recovery_month
                    )
                    - 1
                ),

                2

            ) AS recovered_accounts_mom_pct

        FROM monthly

        ORDER BY recovery_month
        """
    ).fetchdf()
)


# ============================================================
# 6. CALL EXPOSURE
#
# Recovered account:
# calls BEFORE first SUCCESS.
#
# Unrecovered account:
# all observed calls.
#
# Duplicate call IDs are removed.
# ============================================================

call_exposure = []


if table_exists(con, "clean_calls"):

    call_exposure = to_records(
        con.execute(
            """
            WITH dedup_calls AS (

                SELECT

                    *,

                    ROW_NUMBER() OVER (

                        PARTITION BY call_id

                        ORDER BY
                            event_at,
                            call_id

                    ) AS rn

                FROM clean_calls
            ),

            dedup_payments AS (

                SELECT

                    *,

                    ROW_NUMBER() OVER (

                        PARTITION BY payment_id

                        ORDER BY
                            event_at,
                            payment_id

                    ) AS rn

                FROM clean_payments
            ),

            first_success AS (

                SELECT

                    account_id,

                    MIN(event_at)
                        AS first_success_at

                FROM dedup_payments

                WHERE rn = 1

                AND UPPER(
                    COALESCE(
                        payment_status,
                        ''
                    )
                ) = 'SUCCESS'

                GROUP BY account_id
            ),

            account_exposure AS (

                SELECT

                    af.account_id,

                    af.recovered_account,

                    CASE

                        WHEN fs.first_success_at
                             IS NOT NULL

                        THEN COALESCE(

                            SUM(

                                CASE

                                    WHEN
                                        dc.event_at
                                        <
                                        fs.first_success_at

                                    THEN 1

                                    ELSE 0

                                END

                            ),

                            0

                        )

                        ELSE COUNT(
                            dc.call_id
                        )

                    END AS call_count

                FROM account_features af

                LEFT JOIN first_success fs

                    ON fs.account_id =
                       af.account_id

                LEFT JOIN dedup_calls dc

                    ON dc.account_id =
                       af.account_id

                    AND dc.rn = 1

                GROUP BY

                    af.account_id,

                    af.recovered_account,

                    fs.first_success_at
            ),

            bands AS (

                SELECT

                    account_id,

                    recovered_account,

                    CASE

                        WHEN call_count = 0
                            THEN '0 calls'

                        WHEN call_count <= 2
                            THEN '1–2 calls'

                        WHEN call_count <= 4
                            THEN '3–4 calls'

                        ELSE '5+ calls'

                    END AS exposure_band

                FROM account_exposure
            )

            SELECT

                exposure_band,

                COUNT(*) AS accounts,

                SUM(
                    COALESCE(
                        recovered_account,
                        0
                    )
                ) AS recovered_accounts,

                ROUND(

                    100.0
                    *
                    SUM(
                        COALESCE(
                            recovered_account,
                            0
                        )
                    )
                    /
                    NULLIF(
                        COUNT(*),
                        0
                    ),

                    2

                ) AS recovery_rate_pct

            FROM bands

            GROUP BY exposure_band

            ORDER BY

                CASE exposure_band

                    WHEN '0 calls'
                        THEN 1

                    WHEN '1–2 calls'
                        THEN 2

                    WHEN '3–4 calls'
                        THEN 3

                    WHEN '5+ calls'
                        THEN 4

                END
            """
        ).fetchdf()
    )


# ============================================================
# 7. DPD
# ============================================================

dpd = to_records(
    con.execute(
        """
        SELECT

            dpd,

            COUNT(*) AS accounts,

            ROUND(

                100.0
                *
                SUM(
                    COALESCE(
                        recovered_account,
                        0
                    )
                )
                /
                NULLIF(
                    COUNT(*),
                    0
                ),

                2

            ) AS recovery_rate_pct

        FROM account_features

        GROUP BY dpd

        ORDER BY dpd
        """
    ).fetchdf()
)


# ============================================================
# 8. INVESTMENT OUTPUT
#
# This is read from your existing analytical output.
# No investment values are invented here.
# ============================================================

investment = read_csv_records(
    "investment_10cr_break_even.csv"
)


# ============================================================
# 9. CORE RECONCILIATION CHECK
#
# The validated SUCCESS recovery total is:
# ₹1,315,583,964.64
#
# If your current backend differs, STOP.
# ============================================================

validated_recovery_total = 1315583964.64

difference = (
    portfolio["recovery_amount"]
    -
    validated_recovery_total
)


if abs(difference) > 0.01:

    con.close()

    raise RuntimeError(
        "\n"
        "==================================================\n"
        "STOP — BACKEND RECONCILIATION FAILED\n"
        "==================================================\n"
        f"Backend recovery : "
        f"₹{portfolio['recovery_amount']:,.2f}\n"
        f"Validated total  : "
        f"₹{validated_recovery_total:,.2f}\n"
        f"Difference       : "
        f"₹{difference:,.2f}\n"
        "\n"
        "Dashboard was NOT updated.\n"
        "Do not submit until this is investigated.\n"
        "=================================================="
    )


# ============================================================
# 10. BACKEND PAYLOAD
# ============================================================

data = {

    "source": {

        "generated_from_backend":
            True,

        "database":
            "credresolve.duckdb",

        "recovery_reconciled":
            True
    },

    "portfolio":
        portfolio,

    "loan_type":
        loan_type,

    "risk_segment":
        risk_segment,

    "monthly_recovery":
        monthly_recovery,

    "monthly_recovered_accounts":
        monthly_recovered_accounts,

    "call_exposure":
        call_exposure,

    "dpd":
        dpd,

    "investment_10cr_break_even":
        investment
}


# ============================================================
# 11. INSERT DATA INTO INDEX.HTML
# ============================================================

html = HTML.read_text(
    encoding="utf-8"
)


payload = json.dumps(
    data,
    ensure_ascii=False,
    separators=(",", ":")
)


pattern = re.compile(
    r"window\.BACKEND_DATA\s*=\s*\{.*?\};",
    re.DOTALL
)


replacement = (
    "window.BACKEND_DATA = "
    +
    payload
    +
    ";"
)


html, replacements = pattern.subn(
    replacement,
    html,
    count=1
)


if replacements != 1:

    con.close()

    raise RuntimeError(
        "\n"
        "BACKEND_DATA placeholder was not found "
        "inside dashboard/index.html.\n"
        "The dashboard was NOT updated."
    )


# ============================================================
# 12. WRITE HTML
# ============================================================

HTML.write_text(
    html,
    encoding="utf-8"
)


# ============================================================
# 13. FINAL VALIDATION OUTPUT
# ============================================================

print()
print("=" * 65)
print("CREDRESOLVE DASHBOARD UPDATED")
print("=" * 65)

print()

print(
    "Backend database:",
    DB
)

print(
    "Recovery amount:",
    f"₹{portfolio['recovery_amount']:,.2f}"
)

print(
    "Recovery rate:",
    f"{portfolio['recovery_rate_pct']:.2f}%"
)

print(
    "Recovered accounts:",
    f"{portfolio['recovered_accounts']:,}"
)

print(
    "Recovery / recovered account:",
    f"₹{portfolio['recovery_per_recovered_account']:,.2f}"
)

print()

print(
    "Recovery reconciliation: PASS"
)

print(
    "Monthly recovery rows:",
    len(monthly_recovery)
)

print(
    "Loan type rows:",
    len(loan_type)
)

print(
    "Risk segment rows:",
    len(risk_segment)
)

print(
    "Call exposure rows:",
    len(call_exposure)
)

print(
    "DPD rows:",
    len(dpd)
)

# Check partial month
partial_months = [

    x
    for x in monthly_recovery

    if x.get("is_partial") is True
]


print(
    "Partial month(s):",
    len(partial_months)
)

for row in partial_months:

    print(
        "  -",
        row["recovery_month"]
    )

print()

print(
    "Dashboard updated:"
)

print(
    HTML
)

print()

print(
    "Open with:"
)

print(
    r"start dashboard\index.html"
)

print("=" * 65)

con.close()