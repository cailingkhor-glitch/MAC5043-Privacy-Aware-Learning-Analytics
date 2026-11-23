
-- MAC5043 Assignment 2
-- Day-60 Random Forest modelling dataset
-- No future outcomes used as input features

CREATE OR REPLACE VIEW day60_model_dataset AS
SELECT
    c.id_student,
    c.code_module,
    c.code_presentation,

    -- Student attributes
    c.gender,
    c.region,
    c.highest_education,
    c.imd_band,
    c.age_band,
    c.num_of_prev_attempts,
    c.studied_credits,
    c.disability,
    c.date_registration,

    -- Learning activity: days 0 to 60
    v.total_clicks,
    v.active_days,
    v.resources_accessed,
    v.clicks_day0_30,
    v.clicks_day31_60,

    -- Future outcome: label only
    c.final_result,

    CASE
        WHEN c.final_result IN ('Fail', 'Withdrawn')
            THEN 1
        WHEN c.final_result IN ('Pass', 'Distinction')
            THEN 0
        ELSE NULL
    END AS at_risk

FROM day60_cohort c
JOIN day60_vle_features v
  ON c.id_student = v.id_student
 AND c.code_module = v.code_module
 AND c.code_presentation = v.code_presentation;

-- Verify total modelling records
SELECT COUNT(*) AS modelling_records
FROM day60_model_dataset;

-- Verify one record per student
SELECT
    COUNT(*) - COUNT(DISTINCT id_student)
        AS duplicate_students
FROM day60_model_dataset;

-- Verify binary prediction labels
SELECT
    at_risk,
    COUNT(*) AS records
FROM day60_model_dataset
GROUP BY at_risk
ORDER BY at_risk;

-- Check for missing prediction labels
SELECT COUNT(*) AS missing_labels
FROM day60_model_dataset
WHERE at_risk IS NULL;
