# CredResolve Collections Recovery Analytics

End-to-end data analytics project for collections recovery performance,
data quality, recovery drivers, statistical analysis, counterfactual
analysis, and ₹10 Cr investment decision support.

## Project Objective

Analyze collections recovery performance, identify measurable recovery
drivers, build a trustworthy Golden Dataset, and evaluate investment
options using statistical and economic evidence.

## Analytical Workflow

Raw Data
→ Staging
→ Clean
→ Golden Dataset
→ Features
→ Metrics
→ Dashboard

## Key Analysis

- Data profiling and quality assessment
- Data forensics and entity resolution
- Golden Dataset construction
- Recovery performance analysis
- Recovery driver analysis
- Statistical analysis
- Counterfactual analysis
- ₹10 Cr investment analysis
- Executive dashboard

## Investment Decision

The analysis identifies **Better Telephony Infrastructure** as the
leading directly measurable candidate for a controlled pilot.

Model-based recovery improvement from 2 → 5 calls:

**+0.961489 percentage points**

Calculated ₹10 Cr break-even requirement:

**+0.953377 percentage points**

Margin above break-even:

**+0.008112 percentage points**

Adjusted telephony model p-value:

**0.051541**

Because the estimated margin is very small and the analysis is
observational, the recommendation is to run a controlled pilot before
committing the full ₹10 Cr investment.

## Repository Structure

- `data/` — raw and Golden datasets
- `notebooks/` — end-to-end analytical workflow
- `sql/` — staging, cleaning, transformation, feature and metric SQL
- `outputs/` — generated analytical outputs
- `reports/` — data-quality, assumptions, findings and executive reports
- `dashboard/` — executive HTML dashboard
- `architecture/` — production architecture and architecture diagram
- `tests/` — validation tests

## Architecture

See:

`architecture/architecture_diagram.png`

and

`architecture/architecture_decisions.md`

## Dashboard

Open:

`dashboard/index.html`

The dashboard presents portfolio recovery performance, recovery drivers,
and the ₹10 Cr investment analysis.

## Technology

- Python
- Pandas
- DuckDB
- SQL
- Jupyter Notebook
- HTML/CSS/JavaScript
- Statistical modelling

## Important Analytical Limitation

The investment analysis is observational and should not be interpreted
as proof of causal effects. Options without direct intervention outcome
and cost information are treated as not directly estimable rather than
being assigned unsupported ROI estimates.
