\# CredResolve Collections Recovery Analytics

\# Metric Definitions



\## 1. Accounts Analyzed



\*\*Metric:\*\* `accounts\_analyzed`



\*\*Definition:\*\* Number of account-level records in `account\_features`.



\*\*Calculation:\*\*



&#x20;   COUNT(\*)



\---



\## 2. Recovered Accounts



\*\*Metric:\*\* `recovered\_accounts`



\*\*Definition:\*\* Number of accounts with at least one successful payment.



\*\*Calculation:\*\*



&#x20;   SUM(recovered\_account)



Where:



&#x20;   recovered\_account = 1



when the account has at least one payment with:



&#x20;   payment\_status = 'SUCCESS'



\---



\## 3. Unrecovered Accounts



\*\*Metric:\*\* `unrecovered\_accounts`



\*\*Definition:\*\* Accounts without a successful payment.



\*\*Calculation:\*\*



&#x20;   accounts\_analyzed - recovered\_accounts



\---



\## 4. Recovery Rate



\*\*Metric:\*\* `recovery\_rate`



\*\*Definition:\*\* Share of analyzed accounts that have been recovered.



\*\*Calculation:\*\*



&#x20;   recovered\_accounts / accounts\_analyzed



The reporting layer may express this as either a decimal or percentage.



\---



\## 5. Recovery Amount



\*\*Metric:\*\* `recovery\_amount`



\*\*Definition:\*\* Sum of valid payment amounts attributed to the account population

after payment records have been deduplicated at payment-ID level.



\*\*Calculation:\*\*



&#x20;   SUM(total\_payment\_amount)



\---



\## 6. Average Recovery per Recovered Account



\*\*Metric:\*\* `average\_recovery\_per\_recovered\_account`



\*\*Definition:\*\* Average recovered payment amount among accounts classified as

recovered.



\*\*Calculation:\*\*



&#x20;   recovery\_amount / recovered\_accounts



\---



\## 7. Outstanding Amount



\*\*Metric:\*\* `outstanding\_amount`



\*\*Definition:\*\* Outstanding balance represented by the analyzed accounts.



\*\*Calculation:\*\*



&#x20;   SUM(outstanding\_amount)



\---



\## 8. Recovery-to-Outstanding Ratio



\*\*Metric:\*\* `recovery\_to\_outstanding\_ratio`



\*\*Definition:\*\* Recovery amount relative to outstanding amount.



\*\*Calculation:\*\*



&#x20;   SUM(total\_payment\_amount) / SUM(outstanding\_amount)



\---



\## 9. Total Calls



\*\*Metric:\*\* `total\_calls`



\*\*Definition:\*\* Number of distinct calls associated with an account.



\---



\## 10. Total Attempts



\*\*Metric:\*\* `total\_attempts`



\*\*Definition:\*\* Number of distinct call attempts associated with an account.



\---



\## 11. Disposition Events



\*\*Metric:\*\* `disposition\_events`



\*\*Definition:\*\* Number of distinct disposition events associated with an account.



\---



\## 12. Call Campaign Count



\*\*Metric:\*\* `call\_campaign\_count`



\*\*Definition:\*\* Number of distinct campaigns associated with an account's calls.



\---



\## 13. Vendor Count



\*\*Metric:\*\* `vendor\_count`



\*\*Definition:\*\* Number of distinct vendors associated with an account's calls.



\---



\## 14. Agent Count



\*\*Metric:\*\* `agent\_count`



\*\*Definition:\*\* Number of distinct agents associated with an account's calls.



\---



\## 15. Targeting Events



\*\*Metric:\*\* `targeting\_events`



\*\*Definition:\*\* Number of distinct targeting events associated with an account.



\---



\## 16. Targeting Campaigns



\*\*Metric:\*\* `targeting\_campaigns`



\*\*Definition:\*\* Number of distinct targeting campaigns associated with an account.



\---



\## 17. Call Exposed



\*\*Metric:\*\* `call\_exposed`



\*\*Definition:\*\* Binary indicator showing whether an account received at least

one call.



\*\*Calculation:\*\*



&#x20;   1 if total\_calls > 0

&#x20;   0 otherwise



\---



\## 18. Attempt Exposed



\*\*Metric:\*\* `attempt\_exposed`



\*\*Definition:\*\* Binary indicator showing whether an account had at least one

call attempt.



\*\*Calculation:\*\*



&#x20;   1 if total\_attempts > 0

&#x20;   0 otherwise



\---



\## 19. Targeted Account



\*\*Metric:\*\* `targeted\_account`



\*\*Definition:\*\* Binary indicator showing whether an account had at least one

targeting event.



\*\*Calculation:\*\*



&#x20;   1 if targeting\_events > 0

&#x20;   0 otherwise



\---



\## 20. DPD



\*\*Metric:\*\* `dpd`



\*\*Definition:\*\* Days past due for the account.



The analysis uses DPD to describe delinquency and create portfolio risk bands.



\---



\## 21. Recovery by Exposure



Recovery rates by calls, agents, campaigns, or vendors are descriptive

comparisons across exposure groups.



These metrics represent observed associations.



They should not be interpreted as causal estimates of the effect of collection

activity.

