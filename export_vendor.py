import duckdb

con = duckdb.connect("credresolve.duckdb")

query = """
SELECT
    vendor_count,

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

    ROUND(AVG(dpd), 2)
        AS avg_dpd,

    ROUND(AVG(outstanding_amount), 2)
        AS avg_outstanding_amount

FROM account_features

GROUP BY vendor_count

ORDER BY vendor_count
"""

df = con.execute(query).fetchdf()

df.to_csv(
    "outputs/recovery_by_vendor_exposure.csv",
    index=False
)

print("VENDOR EXPOSURE EXPORTED")
print(df.to_string(index=False))

con.close()