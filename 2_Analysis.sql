USE mediaudit;

-- PATIENT VOLUME BY DEPARTMENT
SELECT
  Department,
  COUNT(*) AS total_patients,
  ROUND(AVG(Stay_Days_Numeric), 1) AS avg_stay_days,
  ROUND(AVG(Admission_Deposit), 0) AS avg_deposit
FROM patient_records
GROUP BY Department
ORDER BY total_patients DESC;

-- Admission type- breakdown per department
SELECT
  Department,
  SUM(CASE WHEN Type_of_Admission = 'EMERGENCY' THEN 1 ELSE 0 END) AS emergency,
  SUM(CASE WHEN Type_of_Admission = 'TRAUMA'    THEN 1 ELSE 0 END) AS trauma,
  SUM(CASE WHEN Type_of_Admission = 'URGENT'    THEN 1 ELSE 0 END) AS urgent,
  COUNT(*) AS total
FROM patient_records
GROUP BY Department
ORDER BY emergency DESC;

-- Ward type carries the most pressure
SELECT
  Ward_Type,
  COUNT(*)                              AS patients,
  ROUND(AVG(Stay_Days_Numeric), 1)      AS avg_stay,
  ROUND(AVG(Admission_Deposit), 0)      AS avg_deposit
FROM patient_records
GROUP BY Ward_Type
ORDER BY patients DESC;

-- Hospital region performance- region under most pressure
SELECT
  Hospital_region_code,
  COUNT(*) AS total_patients,
  COUNT(DISTINCT Hospital_code) AS hospitals_in_region,
  ROUND(AVG(Stay_Days_Numeric), 1) AS avg_stay,
  ROUND(AVG(Admission_Deposit), 0) AS avg_deposit
FROM patient_records
GROUP BY Hospital_region_code
ORDER BY total_patients DESC;

-- Department efficiency scoring- CRITICAL vs STABLE
WITH dept_stats AS (
  SELECT
    Department,
    COUNT(*) AS total_patients,
    ROUND(AVG(Stay_Days_Numeric), 1) AS avg_stay
  FROM patient_records
  GROUP BY Department
),
efficiency_rated AS (
  SELECT *,
    RANK() OVER (ORDER BY avg_stay DESC)        AS stay_rank,
    RANK() OVER (ORDER BY total_patients DESC)  AS volume_rank,
    CASE
      WHEN avg_stay > 35 AND total_patients > 1000 THEN 'CRITICAL'
      WHEN avg_stay > 32 OR  total_patients > 25000 THEN 'NEEDS REVIEW'
      ELSE 'STABLE'
    END AS load_status
  FROM dept_stats
)
SELECT * FROM efficiency_rated
ORDER BY avg_stay DESC;

-- Visitor pattern by severity
-- Serious patients get more visitors-
SELECT
		Severity_of_Illness,
		ROUND(AVG(Visitors_with_Patient), 1) AS avg_visitors,
		MIN(Visitors_with_Patient) AS min_visitors,
		MAX(Visitors_with_Patient) AS max_visitors,
		COUNT(*) AS patients
FROM patient_records
GROUP BY Severity_of_Illness
ORDER BY avg_visitors DESC;

USE mediaudit;

-- Department has most extreme patients-
SELECT Department,
  COUNT(*) AS total_patients,
  SUM(CASE WHEN Severity_of_Illness = 'EXTREME' THEN 1 ELSE 0 END) AS extreme_cases,
  ROUND(SUM(CASE WHEN Severity_of_Illness = 'EXTREME' THEN 1 ELSE 0 END) * 100.0
    / COUNT(*), 1) AS extreme_illness_percentage                                           -- -- (extreme patient/ Total patient)* 100
FROM patient_records
GROUP BY Department
ORDER BY extreme_illness_percentage DESC;


-- Patients who came back multiple times-

SELECT 
PATIENT_ID , COUNT(*) AS TOTAL_VISITS
FROM PATIENT_RECORDS
GROUP BY PATIENT_ID
ORDER BY TOTAL_VISITS DESC
LIMIT 100;

-- Number of patients who visited once vs multiple times?
SELECT
  COUNT(*) AS total_unique_patients,
  SUM(CASE WHEN total_visits = 1  THEN 1 ELSE 0 END)           AS single_visit,
  SUM(CASE WHEN total_visits BETWEEN 2 AND 4 THEN 1 ELSE 0 END) AS low_repeat,
  SUM(CASE WHEN total_visits BETWEEN 5 AND 9 THEN 1 ELSE 0 END) AS moderate_repeat,
  SUM(CASE WHEN total_visits >= 10 THEN 1 ELSE 0 END)           AS high_risk
FROM (
  SELECT
    patient_id,
    COUNT(*) AS total_visits
  FROM patient_records
  GROUP BY patient_id
) AS visit_summary;

SELECT patient_id, COUNT(*) AS visit_count
FROM patient_records
GROUP BY patient_id;

-- Age
-- Age group that has most extreme patients-

select Age_numeric,Age as Age_Group, count(*) as Total_patients,
Sum(case when severity_of_illness = 'extreme' then 1 else 0 end) as EXTREME_cases,
round(
		sum(case when severity_of_illness = 'extreme' then 1 else 0 end) *100
		/count(*), 1
	) as extreme_patient_percentage
From patient_records
group by Age, Age_Numeric
order by Age_numeric;


-- Does extreme patients pay more deposit?
Select Severity_of_Illness,
round(avg(admission_deposit), 0) as AVG_deposit,
round(MAx(admission_deposit), 0) as MAX_deposit,
round(MIN(admission_deposit), 0) as Min_Deposit,
count(*) as Patient

From patient_records
Group by Severity_of_Illness
Order by AVG_Deposit DESC;

-- Stay & analysis
-- Which department has most long stay patients?
describe patient_records;

Select Department, count(*) as Total_patients,
					sum(case when stay_days_numeric >=61 then 1 else 0 end) as Long_stay_Patients,
				round(sum(case when stay_days_numeric >=61 then 1 else 0 end) *100/count(*),1) as long_stay_percentage,
round(AVG(stay_days_numeric), 1)as AVG_stay_days
from patient_records
group by Department
order by Long_stay_percentage;


-- Do better beds mean shorter stays
Select  Bed_grade,
		COUNT(*) AS patients,
		ROUND(AVG(Stay_Days_Numeric), 1) AS AVG_stay,
		ROUND(AVG(Admission_Deposit), 0) AS AVG_deposit
from patient_records
WHERE Bed_Grade IS NOT NULL
  AND Bed_Grade != ''
GROUP BY Bed_Grade
ORDER BY Bed_Grade;

-- What percentage of patients stay more than 60 days?
Select stay as Stay_range, Stay_days_numeric,
		count(*) as Patient,
        Round(count(*)*100/ (Select count(*) from patient_records),1) as Percentage_of_Total
From Patient_records
group by Stay, Stay_days_numeric
order by stay_days_numeric desc;

-- Running total of patients across hospital regions

SELECT Hospital_region_code, Hospital_code,
		COUNT(*) AS patients,
		SUM(COUNT(*)) OVER(PARTITION BY Hospital_region_code
							ORDER BY Hospital_code) AS running_total_in_region
FROM patient_records
GROUP BY Hospital_region_code, Hospital_code
ORDER BY Hospital_region_code, Hospital_code;









    



