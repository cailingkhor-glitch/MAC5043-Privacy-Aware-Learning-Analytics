
-- MAC5043 A2: Day-60 cohort verification

-- 1. Check unknown registration dates
SELECT COUNT(*) AS missing_registration_dates
FROM "studentRegistration"
WHERE date_registration IS NULL;

-- 2. Count strictly verifiable day-60 records
SELECT COUNT(*) AS verified_day60_records
FROM "studentRegistration"
WHERE date_registration IS NOT NULL
  AND date_registration <= 60
  AND (
      date_unregistration IS NULL
      OR date_unregistration > 60
  );

-- 3. Count distinct eligible students
SELECT COUNT(DISTINCT id_student)
    AS distinct_eligible_students
FROM "studentRegistration"
WHERE date_registration IS NOT NULL
  AND date_registration <= 60
  AND (
      date_unregistration IS NULL
      OR date_unregistration > 60
  );

-- 4. Find students with multiple eligible records
WITH eligible AS (
    SELECT id_student
    FROM "studentRegistration"
    WHERE date_registration IS NOT NULL
      AND date_registration <= 60
      AND (
          date_unregistration IS NULL
          OR date_unregistration > 60
      )
)
SELECT COUNT(*) AS students_with_multiple_records
FROM (
    SELECT id_student
    FROM eligible
    GROUP BY id_student
    HAVING COUNT(*) > 1
) duplicates;

-- 5. Inspect outcome distribution in eligible records
SELECT s.final_result, COUNT(*) AS records
FROM "studentInfo" s
JOIN "studentRegistration" r
  ON s.code_module = r.code_module
 AND s.code_presentation = r.code_presentation
 AND s.id_student = r.id_student
WHERE r.date_registration IS NOT NULL
  AND r.date_registration <= 60
  AND (
      r.date_unregistration IS NULL
      OR r.date_unregistration > 60
  )
GROUP BY s.final_result
ORDER BY records DESC;
