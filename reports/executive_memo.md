# CredResolve Collections Recovery Analytics

# Executive Memo

## Executive Summary

The analysis independently reconstructs collections recovery from the underlying operational data rather than relying on the existing reporting definition.

The final analytical dataset contains **30,000 accounts**, of which **13,284 are recovered**, giving an overall recovery rate of **44.28%**.

After payment-ID deduplication, verified SUCCESS-based recovery is:

**₹1,315,583,964.64 (~₹131.56 Cr)**

The reported **11% month-on-month recovery improvement is NOT SUSTAINED**.

March 2026 recorded:

- **+11.03% recovery amount**
- **+11.32% recovered accounts**

However, the following complete month declined by **7.29%**. August 2026 is a partial month and is excluded from the sustained-trend conclusion.

---

## 1. What Happened?

The portfolio's verified recovery performance is:

- **30,000 accounts analyzed**
- **13,284 recovered accounts**
- **16,716 unrecovered accounts**
- **44.28% recovery rate**
- **₹131.56 Cr SUCCESS-based recovery**
- **₹99,035.23 recovery per recovered account**

The March increase is a genuine observed month-on-month increase, but it does not continue into the following complete month.

### Conclusion

**The reported 11% improvement should not be treated as a sustained portfolio-wide trend.**

---

## 2. Why Did It Happen?

The analysis investigated portfolio, borrower, risk, and collection-exposure dimensions.

### Key observed differences

- **Loan Type:** CONSUMER 45.28% vs BNPL 43.52%
- **Risk:** LOW 45.00% vs HIGH 43.70%
- **Call Exposure:** 43.22% for 0 calls → 44.97% for 5+ calls
- **DPD:** 42.79%–45.81%, indicating weak standalone separation

Call, agent, campaign, vendor, targeting, and other collection-exposure dimensions show some variation, but the observed relationships are not sufficient to establish causation.

The analysis therefore distinguishes between **observed association and causal effect**.

---

## 3. Data Quality and Reliability

Payment data contained:

- **25,500 raw payment rows**
- **25,000 unique payment IDs**
- **500 duplicate payment IDs**

The duplicate payment records were investigated and showed no conflicting payment status, amount, or event timestamp. One record per payment ID was retained for recovery calculation.

Recovery is therefore based on:

**SUCCESS payments after payment-ID deduplication.**

FAILED, PENDING, and REVERSED payments are excluded.

This provides the basis for the verified **₹131.56 Cr** recovery figure.

---

## 4. How Confident Are We?

### High confidence

- Account population and recovered-account counts
- SUCCESS-based recovery after payment deduplication
- Overall recovery rate
- March month-on-month recovery movement
- The following complete month's decline
- The conclusion that the 11% improvement is not sustained

### Moderate / observational evidence

- Loan-type differences
- Risk-segment differences
- Call exposure
- Agent exposure
- Campaign exposure
- Vendor exposure
- Targeting relationships

These relationships may be affected by borrower characteristics, portfolio mix, delinquency, targeting strategy, or selection effects.

### Causal confidence

**Not established.**

The available observational data does not prove that additional collection activity causes higher recovery.

---

## 5. ₹10 Cr Investment Decision

### Recommendation: PILOT FIRST

**Better Telephony Infrastructure** is the leading candidate for a controlled pilot.

The modeled analysis estimates:

- Improvement from 2 → 5 calls: **+0.961489 percentage points**
- ₹10 Cr break-even requirement: **+0.953377 percentage points**
- Margin above break-even: **+0.008112 percentage points**
- Adjusted model p-value: **0.051541**
- Modeled incremental recovery: **approximately ₹11.29 Cr**

The modeled improvement is only marginally above the calculated break-even requirement.

### Expected Financial Impact

The modeled scenario indicates approximately:

**₹11.29 Cr incremental recovery**

against a:

**₹10 Cr investment**

However, this is a **model estimate, not guaranteed incremental recovery or guaranteed ROI**.

### Downside

If the actual incremental recovery uplift is below **+0.953377 percentage points**, the investment would not reach the calculated break-even point.

---

## Final Decision

**DO NOT TREAT THE 11% CLAIM AS A SUSTAINED TREND.**

**RUN A CONTROLLED TELEPHONY PILOT BEFORE COMMITTING THE FULL ₹10 Cr.**

The pilot should use a comparable control group and measure incremental recovery before full-scale deployment.

The investment should be scaled only if the observed uplift is sufficiently above the break-even requirement and is supported by statistically credible evidence.