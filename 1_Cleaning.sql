CREATE DATABASE mediaudit;
USE mediaudit;

CREATE TABLE patient_records (
    case_id               INT            NOT NULL,
    Hospital_code         INT,
    Hospital_type_code    VARCHAR(2),
    City_Code_Hospital    INT,
    Hospital_region_code  VARCHAR(2),
    Available_Extra_Rooms INT,
    Department            VARCHAR(25),
    Ward_Type             VARCHAR(2),
    Ward_Facility_Code    VARCHAR(2),
    Bed_Grade             VARCHAR(5),
    patient_id            INT,
    City_Code_Patient     VARCHAR(10),
    Type_of_Admission     VARCHAR(15),
    Severity_of_Illness   VARCHAR(15),
    Visitors_with_Patient INT,
    Age                   VARCHAR(10),
    Admission_Deposit     DECIMAL(10,2),
    Stay                  VARCHAR(25),
    PRIMARY KEY (case_id)
);

USE mediaudit;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/train_data.csv'
INTO TABLE patient_records
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_rows FROM patient_records;


SELECT * FROM patient_records LIMIT 5;

-- Checking Stay values (look for Nov-20 Excel bug)
SELECT DISTINCT Stay, COUNT(*) AS cnt
FROM patient_records
GROUP BY Stay
ORDER BY Stay;

-- Checking Age values
SELECT DISTINCT Age, COUNT(*) AS cnt
FROM patient_records
GROUP BY Age
ORDER BY Age;

SELECT
  SUM(CASE WHEN case_id IS NULL THEN 1 ELSE 0 END)             AS null_case_id,
  SUM(CASE WHEN Department IS NULL THEN 1 ELSE 0 END)           AS null_dept,
  SUM(CASE WHEN Severity_of_Illness IS NULL THEN 1 ELSE 0 END)  AS null_severity,
  SUM(CASE WHEN Stay IS NULL THEN 1 ELSE 0 END)                 AS null_stay,
  SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END)                  AS null_age,
  SUM(CASE WHEN Admission_Deposit IS NULL THEN 1 ELSE 0 END)    AS null_deposit
FROM patient_records;

SELECT case_id, COUNT(*) AS duplicate_count
FROM patient_records
GROUP BY case_id
HAVING COUNT(*) > 1;

SET SQL_SAFE_UPDATES = 0;

UPDATE patient_records SET Department          = TRIM(UPPER(Department));
UPDATE patient_records SET Severity_of_Illness = TRIM(UPPER(Severity_of_Illness));
UPDATE patient_records SET Type_of_Admission   = TRIM(UPPER(Type_of_Admission));
UPDATE patient_records SET Ward_Type           = TRIM(UPPER(Ward_Type));

-- 

SELECT DISTINCT Department        FROM patient_records;
SELECT DISTINCT Severity_of_Illness FROM patient_records;
SELECT DISTINCT Type_of_Admission FROM patient_records;

ALTER TABLE patient_records ADD COLUMN Stay_Days_Numeric INT;
ALTER TABLE patient_records ADD COLUMN Age_Numeric INT;

SET SQL_SAFE_UPDATES = 0;

UPDATE patient_records
SET Stay_Days_Numeric =
  CASE Stay
    WHEN '0-10'               THEN 5
    WHEN '11-20'              THEN 15
    WHEN '21-30'              THEN 25
    WHEN '31-40'              THEN 35
    WHEN '41-50'              THEN 45
    WHEN '51-60'              THEN 55
    WHEN '61-70'              THEN 65
    WHEN '71-80'              THEN 75
    WHEN '81-90'              THEN 85
    WHEN '91-100'             THEN 95
    WHEN 'MORE THAN 100 DAYS' THEN 105
    ELSE NULL
  END;

-- Fixing date issue
UPDATE patient_records
SET Stay_Days_Numeric = 15
WHERE Stay LIKE 'NOV%'
   OR Stay LIKE 'Nov%'
   OR Stay = '11-20';

-- Verification
SELECT
  SUM(CASE WHEN Stay_Days_Numeric IS NULL THEN 1 ELSE 0 END) AS null_stay_numeric,
  COUNT(*) AS total
FROM patient_records;


UPDATE patient_records
SET Age_Numeric =
  CASE Age
    WHEN '0-10'   THEN 5
    WHEN '11-20'  THEN 15
    WHEN '21-30'  THEN 25
    WHEN '31-40'  THEN 35
    WHEN '41-50'  THEN 45
    WHEN '51-60'  THEN 55
    WHEN '61-70'  THEN 65
    WHEN '71-80'  THEN 75
    WHEN '81-90'  THEN 85
    WHEN '91-100' THEN 95
    ELSE NULL
  END;

-- age issue
UPDATE patient_records
SET Age_Numeric = 15
WHERE Age LIKE 'NOV%'
   OR Age LIKE 'Nov%'
   OR Age = '11-20';

-- Verification
SELECT
  SUM(CASE WHEN Age_Numeric IS NULL THEN 1 ELSE 0 END) AS null_age_numeric,
  COUNT(*) AS total
FROM patient_records;

SELECT
  COUNT(*)                            AS total_rows,
  COUNT(DISTINCT Department)          AS departments,
  COUNT(DISTINCT Hospital_code)       AS hospitals,
  COUNT(DISTINCT patient_id)          AS unique_patients,
  ROUND(AVG(Stay_Days_Numeric), 1)    AS avg_stay_days,
  ROUND(AVG(Age_Numeric), 1)          AS avg_age
FROM patient_records;

SELECT
  SUM(CASE WHEN Stay_Days_Numeric IS NULL THEN 1 ELSE 0 END) AS null_stay,
  SUM(CASE WHEN Age_Numeric IS NULL THEN 1 ELSE 0 END)       AS null_age,
  COUNT(*)                                                    AS total_rows
FROM patient_records;

SELECT
  COUNT(*)                            AS total_rows,
  COUNT(DISTINCT Department)          AS departments,
  COUNT(DISTINCT Hospital_code)       AS hospitals,
  COUNT(DISTINCT patient_id)          AS unique_patients,
  ROUND(AVG(Stay_Days_Numeric), 1)    AS avg_stay_days,
  ROUND(AVG(Age_Numeric), 1)          AS avg_age
FROM patient_records;

SELECT Stay, COUNT(*) AS cnt
FROM patient_records
WHERE Stay_Days_Numeric IS NULL
GROUP BY Stay;

SELECT
  COUNT(*)                            AS total_rows,
  COUNT(DISTINCT Department)          AS departments,
  COUNT(DISTINCT Hospital_code)       AS hospitals,
  COUNT(DISTINCT patient_id)          AS unique_patients,
  ROUND(AVG(Stay_Days_Numeric), 1)    AS avg_stay_days,
  ROUND(AVG(Age_Numeric), 1)          AS avg_age
FROM patient_records;


