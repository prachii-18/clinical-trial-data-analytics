# Clinical Trial Data Analytics

Analysis of a synthetic clinical trial dataset using Excel, SQL (MySQL) and Power BI.

## Overview

Analyzed dropout, adverse events, enrollment trends and patient vitals across 1,000 subjects, 50 sites and 3 treatment groups (Drug A, Drug B, Placebo), with enrollment from January 2022 to September 2024. Similar questions were answered in all three tools, and the results match.

## Dataset

Synthetic data with 1,000 rows and these columns: Subject_ID, Site_ID, Age, Gender, Enrollment_Date, Treatment_Group, Adverse_Events (count), Dropout (0/1), Systolic_BP, Diastolic_BP, Cholesterol_Level.

## Tools and Work Done

**Excel**
- Cleaned the data (fixed inconsistent date formats, checked for blanks and duplicate Subject IDs)
- Built pivot tables for dropout, adverse events, enrollment, vitals by treatment group, dropout vs vitals, and site analysis
- Created a 5-chart dashboard

**SQL (MySQL)**
- Created the database and table and converted the mixed-format Enrollment_Date column to a proper DATE column
- Wrote queries covering data quality checks, group summaries, dropout and adverse events, enrollment trends and site rankings
- Used aggregations with GROUP BY, CASE, subqueries, a CTE and a window function

**Power BI**
- Built DAX measures (Dropout Rate, Avg Adverse Events)
- Created a single-page interactive dashboard with KPI cards, Year and Treatment Group slicers, and charts for dropout, adverse events, site performance, vitals, cholesterol by age group and enrollment

## Key Insights

- 1,000 subjects, 161 dropouts, overall dropout rate of 16.1%; average adverse events 1.05 per subject
- Drug B had the highest dropout rate (18.4%) despite the lowest average adverse events (0.95); the difference is mainly among female subjects (22.6% vs 13.9% for male)
- Age, blood pressure and cholesterol were similar across treatment groups and between subjects who dropped out and those who did not
- Dropout was higher in younger subjects (20.2% under 30, 14.4% over 60), though the under-30 group has only 89 subjects
- Placebo had the most enrollments (363 subjects)
- Enrollment was steady at about 90 subjects per quarter across the whole period; 2024 totals are lower only because the data ends in September 2024
- Site 27 had the highest dropout rate (34.8%, 23 subjects) and Site 34 had the most subjects (33)

## Limitations

- Results are descriptive only; no statistical tests were run, so differences between groups may not be significant
- The data is synthetic

## Files

- `dataset/raw_clinical_trial_data.csv`: raw synthetic dataset 
- `clinical_trial_excel_analytics.xlsx`: Excel analysis and dashboard
- `clinical_trials_analytics.sql`: SQL script
- `clinical_trials_dashboard_pbi.pbix`: Power BI dashboard
- `images/`: dashboard screenshots

## Note

Synthetic data used for learning purposes. No real patient data is used.
