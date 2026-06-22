use mediaudit;

-- VIEW 
CREATE or REPLACE VIEW VIEW_DEPARTMENT_KPI AS 
SELECT 
		DEPARTMENT,
        COUNT(*) as TOTAL_PATIENTS,
        ROUND(AVG(Stay_days_numeric), 1) as AVG_Stay_Days, 
        ROUND(AVG(Admission_Deposit), 0) as AVG_Admission_Deposit,
        Sum(CASE WHEN Severity_of_illness = 'Extreme' THEN 1 ELSE 0 END) as Extreme_Cases,
        ROUND(SUM(CASE WHEN Severity_of_illness = 'Extreme' THEN 1 ELSE 0 END) * 100/COUNT(*), 1) as EXTREME_CASES_PERCENTAGES,
        
CASE WHEN AVG(STAY_DAYS_NUMERIC) > 35 AND COUNT(*) > 1000 THEN 'CRITICAL'
	WHEN AVG(STAY_DAYS_NUMERIC) > 32 OR  COUNT(*) > 25000 THEN 'NEED A REVIEW'
    ELSE 'STABLE'
END AS DEPARTMENT_STATUS

FROM patient_records
GROUP BY DEPARTMENT;

SELECT * FROM VIEW_DEPARTMENT_KPI;

-- HIGH RISK
select * from patient_records;

CREATE OR REPLACE VIEW VIEW_HIGH_RISK_PATIENTS AS 
SELECT CASE_ID, PATIENT_ID, DEPARTMENT, AGE, SEVERITY_OF_ILLNESS, ADMISSION_DEPOSIT, STAY, STAY_DAYS_NUMERIC
FROM patient_records
WHERE SEVERITY_OF_ILLNESS = 'EXTREME' AND STAY_DAYS_NUMERIC >=61;

SELECT COUNT(*) AS HIGH_RISK_COUNT 
FROM VIEW_HIGH_RISK_PATIENTS ;

-- DEPARTMENT ON DEMAND

DELIMITER //
CREATE PROCEDURE RunDepartmentAudit(IN dept_name VARCHAR(50))
BEGIN
  SELECT
    Severity_of_Illness,
    Type_of_Admission,
    COUNT(*)                            AS patients,
    ROUND(AVG(Stay_Days_Numeric), 1)    AS avg_stay,
    ROUND(AVG(Age_Numeric), 1)          AS avg_age,
    ROUND(AVG(Admission_Deposit), 0)    AS avg_deposit
  FROM patient_records
  WHERE Department = dept_name
  GROUP BY Severity_of_Illness, Type_of_Admission
  ORDER BY patients DESC;
END //
DELIMITER ;


CALL RunDepartmentAudit('SURGERY');
CALL RunDepartmentAudit('GYNECOLOGY');


-- TRIGGER
CREATE TABLE IF NOT EXISTS audit_log (
  log_id        INT AUTO_INCREMENT PRIMARY KEY,
  case_id       INT,
  changed_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
  changed_field VARCHAR(100),
  old_value     VARCHAR(200),
  new_value     VARCHAR(200)
);


DELIMITER //
CREATE TRIGGER trg_patient_update
AFTER UPDATE ON patient_records
FOR EACH ROW
BEGIN
  IF OLD.Severity_of_Illness != NEW.Severity_of_Illness THEN
    INSERT INTO audit_log
      (case_id, changed_field, old_value, new_value)
    VALUES
      (OLD.case_id, 'Severity_of_Illness',
       OLD.Severity_of_Illness, NEW.Severity_of_Illness);
  END IF;
END //
DELIMITER ;

UPDATE patient_records
SET Severity_of_Illness = 'MINOR'
WHERE case_id = 1;

SELECT * FROM audit_log;