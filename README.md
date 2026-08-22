## Project Structure

```text
CredResolve Collections Recovery Analytics/
│
├── README.md
│
├── data/
│   ├── raw/
│   │   ├── account_status_history.csv
│   │   ├── accounts.csv
│   │   ├── agent_sessions.csv
│   │   ├── agents.csv
│   │   ├── borrowers.csv
│   │   ├── call_attempts.csv
│   │   ├── call_dispositions.csv
│   │   ├── calls.csv
│   │   ├── campaigns.csv
│   │   ├── complaints.csv
│   │   ├── daily_targeting.csv
│   │   ├── data_dictionary.csv
│   │   ├── field_visits.csv
│   │   ├── payments.csv
│   │   ├── promises_to_pay.csv
│   │   ├── sms_events.csv
│   │   ├── vendor_telephony.csv
│   │   └── whatsapp_events.csv
│   │
│   └── golden/
│       ├── account_status_history_golden.csv
│       ├── accounts_golden.csv
│       ├── agent_sessions_golden.csv
│       ├── agents_golden.csv
│       ├── borrowers_golden.csv
│       ├── call_attempts_golden.csv
│       ├── call_dispositions_golden.csv
│       ├── calls_golden.csv
│       ├── campaigns_golden.csv
│       ├── complaints_golden.csv
│       ├── daily_targeting_golden.csv
│       ├── data_dictionary_golden.csv
│       ├── field_visits_golden.csv
│       ├── payments_golden.csv
│       ├── promises_to_pay_golden.csv
│       ├── sms_events_golden.csv
│       ├── vendor_telephony_golden.csv
│       └── whatsapp_events_golden.csv
│
├── sql/── ⭐ 1. SQL REPOSITORY
│   ├── analysis/
│   │   ├── 01_recovery_analysis.sql
│   │   ├── 02_driver_analysis.sql
│   │   ├── 03_call_exposure_check.sql
│   │   ├── 04_agent_exposure_check.sql
│   │   ├── 05_campaign_exposure_check.sql
│   │   ├── 06_vendor_exposure_check.sql
│   │   └── 07_monthly_recovery_analysis.sql
│   │
│   ├── cleaning/
│   │   ├── 01_data_quality.sql
│   │   └── 02_clean_tables.sql
│   │
│   ├── features/
│   │   └── 01_account_features.sql
│   │
│   ├── metrics/
│   │   ├── 01_recovery_metrics.sql
│   │   ├── 02_portfolio_metrics.sql
│   │   └── 03_required_collection_metrics.sql
│   │
│   ├── staging/
│   │   ├── 00_load_raw_data.sql
│   │   └── 01_source_tables.sql
│   │
│   └── transformations/
│       ├── 01_account_recovery.sql
│       └── 02_call_activity.sql
│       
│
├── notebooks/── ⭐ 2. ANALYSIS NOTEBOOKS
│   ├── 01_data_profiling.ipynb
│   ├── 02_data_quality.ipynb
│   ├── 03_golden_dataset.ipynb
│   ├── 04_recovery_analysis.ipynb
│   ├── 05_driver_analysis.ipynb
│   ├── 06_statistical_analysis.ipynb
│   ├── 07_counterfactual_analysis.ipynb
│   └── 08_investment_analysis.ipynb
│       
│
├── outputs/
│   ├── golden_dataset.csv── ⭐ 3. GOLDEN DATASET
│   │   
│   │
│   ├── data_quality_forensics.csv
│   ├── monthly_recovery_trend.csv
│   ├── recovery_by_agent_exposure.csv
│   ├── recovery_by_call_exposure.csv
│   ├── recovery_by_campaign_exposure.csv
│   ├── recovery_by_loan_type.csv
│   ├── recovery_by_risk_segment.csv
│   ├── recovery_by_vendor_exposure.csv
│   ├── investment_agent_analysis.csv
│   ├── investment_break_even.csv
│   ├── investment_economic_screen.csv
│   ├── investment_evidence.csv
│   ├── investment_targeting_analysis.csv
│   ├── investment_telephony_analysis.csv
│   │
│   └── tables/
│       ├── candidate_keys.csv
│       ├── column_profile.csv
│       ├── counterfactual_account_level_dataset.csv
│       ├── counterfactual_analysis_summary.csv
│       ├── counterfactual_assumptions.csv
│       ├── counterfactual_baseline.csv
│       ├── counterfactual_low_exposure.csv
│       ├── counterfactual_scenarios.csv
│       ├── counterfactual_sensitivity.csv
│       ├── investment_10cr_break_even.csv
│       ├── investment_10cr_sensitivity.csv
│       ├── investment_assumptions.csv
│       ├── investment_baseline_metrics.csv
│       ├── investment_business_case.csv
│       ├── investment_case_summary.csv
│       ├── investment_roi_sensitivity.csv
│       ├── investment_scenario_economics.csv
│       ├── statistical_account_level_dataset.csv
│       ├── statistical_analysis_summary.csv
│       ├── statistical_call_exposure.csv
│       └── statistical_overall_recovery.csv
│
├── reports/
│   ├── assumptions.md
│   ├── data_quality_report.md ⭐ 4. DATA QUALITY REPORT
│   │   
│   ├── executive_memo.md ── ⭐ 6. EXECUTIVE MEMO
│   │   
│   ├── final_findings.md
│   └── metric_definitions.md
│
├── dashboard/
│   └── index.html - ⭐ 5. EXECUTIVE DASHBOARD
│       
│
├── architecture/
│   ├── architecture_diagram.png ── ⭐ 7. ARCHITECTURE DIAGRAM
│   │   
│   └── architecture_decisions.md
│
├── build_dashboard.py
├── export_agent.py
├── export_call.py
├── export_campaign.py
├── export_vendor.py
├── requirements.txt
└── .gitignore
```


# CredResolve Collections Recovery Analytics

An end-to-end data analytics project built to independently investigate whether the reported **“11% month-on-month recovery improvement”** is actually supported by the underlying collections data.

The project reconstructs a trustworthy analytical dataset from multiple operational sources, investigates recovery drivers and data-quality issues, evaluates the reported business claim, and assesses where a **₹10 Cr investment** should be deployed.

## What I Built

- Golden Dataset and reproducible analytical pipeline
- Data cleaning, deduplication and entity-resolution logic
- Recovery performance and driver analysis
- Data forensics and quality investigation
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

## 11% Claim

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

- Modeled improvement from 2 → 5 calls: **+0.961489 percentage points**
- Break-even requirement: **+0.953377 percentage points**
- Margin above break-even: **+0.008112 percentage points**
- Adjusted model p-value: **0.051541**

The modeled benefit is only marginally above break-even and is based on observational evidence.

**Recommendation:** Run a controlled pilot before committing the full ₹10 Cr.

## Executive Dashboard

The dashboard is intentionally designed as a **single-screen CEO view**, focused on:

**Current performance → 11% claim → recovery trend → key drivers → investment decision**

Open:

`dashboard/index.html`

Dashboard values are generated from the analytical backend and are not manually hardcoded.

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
