
-- MAC5043 A2: SQL retrieval verification

-- 1. Verify student registration joins
SELECT COUNT(*) AS joined_registrations
FROM "studentInfo" s
JOIN "studentRegistration" r
  ON s.code_module = r.code_module
 AND s.code_presentation = r.code_presentation
 AND s.id_student = r.id_student;

-- 2. Count distinct students
SELECT COUNT(DISTINCT id_student) AS distinct_students
FROM "studentInfo";

-- 3. Count module records still registered at day 60
SELECT COUNT(*) AS eligible_day60_records
FROM "studentRegistration"
WHERE (date_registration IS NULL
       OR date_registration <= 60)
  AND (date_unregistration IS NULL
       OR date_unregistration > 60);

-- 4. Count VLE activity records available by day 60
SELECT COUNT(*) AS vle_records_by_day60
FROM "studentVle"
WHERE date <= 60;
