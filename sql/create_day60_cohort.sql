
-- MAC5043 Assignment 2
-- Day-60 modelling cohort
-- One module-presentation record per student

CREATE OR REPLACE VIEW day60_cohort AS
WITH eligible AS (
    SELECT
        s.id_student,
        s.code_module,
        s.code_presentation,
        s.gender,
        s.region,
        s.highest_education,
        s.imd_band,
        s.age_band,
        s.num_of_prev_attempts,
        s.studied_credits,
        s.disability,
        s.final_result,
        r.date_registration,

        ROW_NUMBER() OVER (
            PARTITION BY s.id_student
            ORDER BY
                s.code_presentation,
                s.code_module
        ) AS rn

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
)

SELECT
    id_student,
    code_module,
    code_presentation,
    gender,
    region,
    highest_education,
    imd_band,
    age_band,
    num_of_prev_attempts,
    studied_credits,
    disability,
    date_registration,
    final_result
FROM eligible
WHERE rn = 1;

-- Verify number of selected records
SELECT COUNT(*) AS cohort_records
FROM day60_cohort;

-- Verify no duplicate students
SELECT
    COUNT(*) - COUNT(DISTINCT id_student)
        AS duplicate_students
FROM day60_cohort;

-- Inspect final outcome distribution
SELECT
    final_result,
    COUNT(*) AS total
FROM day60_cohort
GROUP BY final_result
ORDER BY final_result;
