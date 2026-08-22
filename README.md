# CredResolve Collections Recovery Analytics

An end-to-end data analytics project built to independently investigate whether the reported **“11% month-on-month recovery improvement”** is actually supported by the underlying collections data.

The project reconstructs a trustworthy analytical dataset from multiple operational sources, investigates recovery drivers and data-quality issues, evaluates the reported business claim, and assesses where a **₹10 Cr investment** should be deployed.

## What I Built

- Golden Dataset and reproducible data pipeline
- Data cleaning, deduplication and entity-resolution logic
- Recovery performance and driver analysis
- Data-forensics and quality investigation
- Statistical and counterfactual analysis
- ₹10 Cr investment analysis
- Executive decision dashboard
- Production analytics architecture
- Validation and analytical documentation

## Key Findings

| Metric | Result |
|---|---:|
| Total Verified Recovery | **₹131.56 Cr** |
| Recovery Rate | **44.28%** |
| Recovered Accounts | **13,284** |
| Recovery / Recovered Account | **₹99,035.23** |
| March Recovery Change | **+11.03%** |
| March Recovered Accounts Change | **+11.32%** |
| Following Complete Month | **−7.29%** |

### 11% Claim

**NOT SUSTAINED**

March shows approximately 11% recovery growth, but the following complete month declined by 7.29%. The evidence therefore does not support treating the reported 11% improvement as a sustained portfolio-wide trend.

## Recovery Drivers

- **Loan Type:** CONSUMER **45.28%** vs BNPL **43.52%**
- **Risk:** LOW **45.00%** vs HIGH **43.70%**
- **Call Exposure:** **43.22%–44.97%**
- **DPD:** **42.79%–45.81%**, indicating weak standalone signal

These findings are treated as observed associations rather than automatic causal effects.

## ₹10 Cr Investment Decision

**Better Telephony Infrastructure — PILOT FIRST**

- Modeled improvement from 2 → 5 calls: **+0.961489 pp**
- Break-even requirement: **+0.953377 pp**
- Margin above break-even: **+0.008112 pp**
- Adjusted model p-value: **0.051541**

The modeled benefit is only marginally above break-even and is based on observational evidence.

**Recommendation:** Run a controlled pilot before committing the full ₹10 Cr.

## Executive Dashboard

The dashboard is intentionally designed as a **single-screen CEO view**, focused on:

**Current performance → 11% claim → recovery trend → key drivers → decision**

Open:

`dashboard/index.html`

Dashboard values are generated from the analytical backend rather than manually 

## Analytical Pipeline

1. **Raw Data**
2. **Staging**
3. **Clean**
4. **Golden Dataset**
5. **Features**
6. **Metrics**
7. **Analysis**
8. **Dashboard**

## Technology

Python · Pandas · DuckDB · SQL · Jupyter · HTML/CSS/JavaScript · Statistical Analysis

## Important Limitation

The investment analysis is observational. Modeled uplift is not treated as guaranteed causal impact or guaranteed ROI. Where evidence is insufficient, the recommended next step is controlled experimentation rather than unsupported conclusions.

## Final Decision

**The reported 11% improvement is not sustained.**

**Do not treat it as a sustained portfolio-wide improvement. Run a controlled telephony pilot before committing the full ₹10 Cr investment.**