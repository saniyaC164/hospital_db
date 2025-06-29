
/*
NeuralBits Technologies Internship SQL Challenge
Solution Queries
*/

/* 1. Average Patients Admitted per Month, Week, Year (per Hospital) */
-- Monthly
SELECT h.hospital_name,
       DATE_TRUNC('month', p.admission_datetime) AS month,
       COUNT(*) AS patient_count
FROM patient p
JOIN hospital h ON p.hospital_id = h.hospital_id
GROUP BY h.hospital_name, month
ORDER BY h.hospital_name, month;

-- Weekly
SELECT h.hospital_name,
       DATE_TRUNC('week', p.admission_datetime) AS week,
       COUNT(*) AS patient_count
FROM patient p
JOIN hospital h ON p.hospital_id = h.hospital_id
GROUP BY h.hospital_name, week
ORDER BY h.hospital_name, week;

-- Yearly
SELECT h.hospital_name,
       DATE_TRUNC('year', p.admission_datetime) AS year,
       COUNT(*) AS patient_count
FROM patient p
JOIN hospital h ON p.hospital_id = h.hospital_id
GROUP BY h.hospital_name, year
ORDER BY h.hospital_name, year;


/* 2. Hospital Occupancy (Daily, Weekly, Monthly, Yearly) */
-- Daily
SELECT DATE(admission_datetime) AS admission_date,
       COUNT(*) AS admissions
FROM patient
GROUP BY admission_date
ORDER BY admission_date;

-- Weekly
SELECT DATE_TRUNC('week', admission_datetime) AS week,
       COUNT(*) AS admissions
FROM patient
GROUP BY week
ORDER BY week;

-- Monthly
SELECT DATE_TRUNC('month', admission_datetime) AS month,
       COUNT(*) AS admissions
FROM patient
GROUP BY month
ORDER BY month;

-- Yearly
SELECT DATE_TRUNC('year', admission_datetime) AS year,
       COUNT(*) AS admissions
FROM patient
GROUP BY year
ORDER BY year;


/* 3. Age-wise Categorization */
SELECT 
  CASE
    WHEN AGE(dob) < INTERVAL '13 years' THEN 'Child'
    WHEN AGE(dob) < INTERVAL '60 years' THEN 'Adult'
    ELSE 'Senior'
  END AS age_group,
  COUNT(*) AS count
FROM patient
GROUP BY age_group;


/* 4. Most Consumed Medicine */
SELECT medicine_name, COUNT(*) AS usage_count
FROM treatment
GROUP BY medicine_name
ORDER BY usage_count DESC
LIMIT 1;


/* 5. Most Consumed Medicine by Diagnosis */
SELECT d.diagnosis_name, t.medicine_name, COUNT(*) AS usage_count
FROM diagnosis d
JOIN treatment t ON d.patient_id = t.patient_id
GROUP BY d.diagnosis_name, t.medicine_name
HAVING COUNT(*) = (
    SELECT MAX(sub.count)
    FROM (
        SELECT COUNT(*) AS count
        FROM diagnosis d2
        JOIN treatment t2 ON d2.patient_id = t2.patient_id
        WHERE d2.diagnosis_name = d.diagnosis_name
        GROUP BY t2.medicine_name
    ) sub
)
ORDER BY d.diagnosis_name;


/* 6. Average Days of Hospitalization */
SELECT 
  ROUND(AVG(discharge_datetime - admission_datetime), 2) AS avg_hospital_days
FROM patient;


/* 7. Monthly and Yearly Income (Cash/Credit Split) */
-- Monthly Income
SELECT 
  DATE_TRUNC('month', p.admission_datetime) AS month,
  b.payment_mode,
  ROUND(SUM(b.bill_amount), 2) AS total_income
FROM billing b
JOIN patient p ON b.patient_id = p.patient_id
GROUP BY month, b.payment_mode
ORDER BY month;

-- Yearly Income
SELECT 
  DATE_TRUNC('year', p.admission_datetime) AS year,
  b.payment_mode,
  ROUND(SUM(b.bill_amount), 2) AS total_income
FROM billing b
JOIN patient p ON b.patient_id = p.patient_id
GROUP BY year, b.payment_mode
ORDER BY year;

