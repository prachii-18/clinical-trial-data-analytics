
-- Creating Database and Setting Up Table
CREATE DATABASE IF NOT EXISTS clinical_trials;
USE clinical_trials;

CREATE TABLE IF NOT EXISTS clinical_trial_data (
     Subject_ID INT,
     Site_ID INT,
     Age INT,
     Gender VARCHAR(10),
     Enrollment_Date VARCHAR(10),
     Treatment_Group VARCHAR(20),
     Adverse_Events INT,
     Dropout INT,
     Systolic_BP INT,
     Diastolic_BP INT,
     Cholesterol_Level INT
   );
   
SELECT COUNT(*) FROM clinical_trial_data;

-- Fixing the inconsistency in the Enrollment_Date column
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE clinical_trial_data ADD COLUMN Enrollment_DT DATE;
UPDATE clinical_trial_data
SET Enrollment_DT = 
CASE WHEN Enrollment_Date LIKE '%-%' THEN STR_TO_DATE(Enrollment_Date, '%m-%d-%Y')
       ELSE STR_TO_DATE(Enrollment_Date, '%m/%d/%y')
END;
SET SQL_SAFE_UPDATES = 1;
SELECT COUNT(*), MIN(Enrollment_DT), MAX(Enrollment_DT), COUNT(Enrollment_DT) FROM clinical_trial_data;

-- Displaying first 5 rows of the table
SELECT *
FROM clinical_trial_data
LIMIT 5;

-- Basic Data Quality Check
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT Subject_ID) AS unique_subjects,
       SUM(Age IS NULL OR Gender IS NULL OR Treatment_Group IS NULL OR Dropout IS NULL) AS rows_with_nulls
FROM clinical_trial_data;

-- Queries for Data Analysis
-- 1. Total number of subjects and distinct sites
SELECT COUNT(Subject_ID) AS total_subjects, 
COUNT(DISTINCT Site_ID) AS total_sites
FROM clinical_trial_data;

-- 2. Overall dropout rate as a percentage and overall average adverse events, rounded to 2 decimals
SELECT ROUND((100* (SUM(Dropout))/COUNT(*)),2) AS Dropout_rate, 
ROUND(AVG(Adverse_Events), 2) AS avg_adverse_events
FROM clinical_trial_data;

-- 3. Number of subjects by treatment group and gender
SELECT Treatment_Group, Gender, COUNT(Subject_ID) AS number_of_subjects
FROM clinical_trial_data
GROUP BY Treatment_Group, Gender
ORDER BY number_of_subjects DESC;

-- 4. Average age, systolic BP, diastolic BP and cholesterol by treatment group, rounded to 2 decimals
SELECT Treatment_Group, ROUND(AVG(Age),2) AS avg_age, ROUND(AVG(Systolic_BP),2) AS avg_systolic_bp, ROUND(AVG(Diastolic_BP),2) AS avg_diastolic_bp, 
ROUND(AVG(Cholesterol_Level),2) AS avg_cholesterol_level
FROM clinical_trial_data
GROUP BY Treatment_Group;

-- 5. Dropout rate (%) and average adverse events by treatment group
SELECT Treatment_Group, 
ROUND((100* (SUM(Dropout))/COUNT(*)),2) AS Dropout_rate, 
ROUND (AVG(Adverse_Events), 2) AS avg_adverse_events
FROM clinical_trial_data
GROUP BY Treatment_Group;

-- 6. Dropout rate (%) by treatment group and gender
SELECT Treatment_Group, Gender,
ROUND((100* (SUM(Dropout))/COUNT(*)),2) AS Dropout_rate
FROM clinical_trial_data
GROUP BY Treatment_Group, Gender;

-- 7.Enrollment count by year and treatment group
SELECT Treatment_Group, YEAR(Enrollment_DT) AS year, COUNT(Subject_ID) AS Enrollment_Count
FROM clinical_trial_data
GROUP BY Treatment_Group, YEAR(Enrollment_DT)
ORDER BY  year, Treatment_Group; 

-- 8. Enrollment count by year and quarter
SELECT YEAR(Enrollment_DT) AS year, QUARTER(Enrollment_DT) AS quarter,
COUNT(Subject_ID) AS Enrollment_Count
FROM clinical_trial_data
GROUP BY year, quarter
ORDER BY year, quarter;

-- 9. Top 10 sites by subject count
SELECT Site_ID, COUNT(Subject_ID) AS subject_count
FROM clinical_trial_data
GROUP BY Site_ID
ORDER BY subject_count DESC
LIMIT 10;

-- 10. Top 10 sites by dropout rate (%)
SELECT Site_ID, ROUND(100 * (SUM(Dropout)/ COUNT(Dropout)), 2) AS Dropout_rate
FROM clinical_trial_data
GROUP BY Site_ID
ORDER BY Dropout_rate DESC, Site_ID
LIMIT 10;

-- 11. Subject count, average cholesterol and dropout rate per age group
WITH age_group AS 
(SELECT Subject_ID, Age, Cholesterol_Level, Dropout, 
CASE 
WHEN Age < 30 THEN '<30' 
WHEN Age BETWEEN 30 AND 45 THEN '30-45'
WHEN Age BETWEEN 46 AND 60 THEN '46-60'
WHEN Age > 60 THEN '>60' 
ELSE 'Unknown'
END AS Age_Group
FROM clinical_trial_data)

SELECT Age_Group, 
COUNT(Subject_ID) AS subject_count, 
ROUND(AVG(Cholesterol_Level),2) AS avg_cholesterol, 
ROUND(100*(SUM(Dropout)/COUNT(Dropout)), 2) AS Dropout_rate
FROM age_group
GROUP BY Age_Group
ORDER BY MIN(Age);

-- 12. Subjects with above-average adverse events, per treatment group (count and % of group)
SELECT Treatment_Group,
       SUM(Adverse_Events > (SELECT AVG(Adverse_Events) FROM clinical_trial_data)) AS ae_above_average,
       COUNT(*) AS group_size,
       ROUND(100 * SUM(Adverse_Events > (SELECT AVG(Adverse_Events) FROM clinical_trial_data)) / COUNT(*), 2) AS pct_above_average
FROM clinical_trial_data
GROUP BY Treatment_Group;

-- 13. Average age, vitals and cholesterol by dropout status
SELECT CASE WHEN Dropout = 1 THEN 'Dropped Out' ELSE 'No Dropout' END AS dropout_status,
       COUNT(*) AS subjects,
       ROUND(AVG(Age),2) AS avg_age,
       ROUND(AVG(Systolic_BP),2) AS avg_systolic_bp,
       ROUND(AVG(Diastolic_BP),2) AS avg_diastolic_bp,
       ROUND(AVG(Cholesterol_Level),2) AS avg_cholesterol
FROM clinical_trial_data
GROUP BY Dropout;

-- 14. Sites with at least 20 subjects, ranked by dropout rate (avoids tiny-sample sites)
SELECT Site_ID, COUNT(*) AS subjects,
       ROUND(100 * SUM(Dropout)/COUNT(*), 2) AS dropout_rate,
       ROUND(AVG(Adverse_Events), 2) AS avg_adverse_events,
       RANK() OVER (ORDER BY SUM(Dropout)/COUNT(*) DESC) AS dropout_rank
FROM clinical_trial_data
GROUP BY Site_ID
HAVING COUNT(*) >= 20
ORDER BY dropout_rank
LIMIT 10;