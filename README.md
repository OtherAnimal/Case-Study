# GymBeam Data Engineer Case Study

## Language Note
This solution is documented in English as technical terminology 
is most precise in this language. Happy to discuss any points 
in Slovak during a follow-up conversation.

## Overview
Solution to the GymBeam Data Engineer technical assessment.
Completed: March 2026

## Note on Keboola Access
Keboola account was registered under a different email than 
this application. Both evaluators have been added as read-only 
users directly in the Keboola project

## Tasks

### Task 1 — Data Model Design
- ER diagram (7 entities including Address and OrderItem)
- Star Schema for BigQuery
- GCP Architecture flow diagram
- Discussion: SCD Type 2, partitioning and clustering
→ [View Task 1](task1/README.md)

### Task 2 — Data Integration (Golemio API Extractor)
- Python extractor using requests, pandas, python-dotenv
- Extracts 10 fields for 55 Prague municipal libraries
- GCP Native deployment approach documented
- Keboola Generic Extractor alternative described in general
→ [View Task 2](task2/README.md)

### Task 3 — Manual Input & SQL Transformation
- Keboola Storage: manual-input bucket with csv_input table
- BigQuery SQL transformation with 5 data quality steps
- Handles duplicates, nulls, type mismatches, malformed values
- Bonus: BigQuery writer approach documented
→ [View Task 3](task3/README.md)

### Task 4 — SQL Performance Problem
- Root cause analysis
- Diagnostic steps
- Prevention approach
→ [View Task 4](task4/performance_analysis.md)

### Task 5 — Best Practices Assessment
- All 23 statements evaluated with reasoning
- Personal experience added where relevant
→ [View Task 5](task5/best_practices.md)

## Tech Stack Used
- Python (requests, pandas, python-dotenv)
- SQL (BigQuery dialect)
- Keboola (Storage, BigQuery Transformation)
- draw.io (diagrams)
- Git / GitHub