
-- MAC5043 Assignment 2
-- Day-60 VLE activity features
-- Keeps activity recorded on or before day 60.
-- Does not include future academic outcomes as features.

CREATE OR REPLACE VIEW day60_vle_features AS
SELECT
    c.id_student,
    c.code_module,
    c.code_presentation,

    COALESCE(SUM(v.sum_click), 0)::BIGINT
        AS total_clicks,

    COUNT(DISTINCT v.date)
        AS active_days,

    COUNT(DISTINCT v.id_site)
        AS resources_accessed,

    COALESCE(
        SUM(v.sum_click) FILTER (
            WHERE v.date BETWEEN 0 AND 30
        ), 0
    )::BIGINT AS clicks_day0_30,

    COALESCE(
        SUM(v.sum_click) FILTER (
            WHERE v.date BETWEEN 31 AND 60
        ), 0
    )::BIGINT AS clicks_day31_60

FROM day60_cohort c

LEFT JOIN "studentVle" v
    ON c.id_student = v.id_student
   AND c.code_module = v.code_module
   AND c.code_presentation = v.code_presentation
   AND v.date BETWEEN 0 AND 60

GROUP BY
    c.id_student,
    c.code_module,
    c.code_presentation;

-- Verify the final feature count
SELECT COUNT(*) AS feature_records
FROM day60_vle_features;

-- Check zero-activity students
SELECT COUNT(*) AS students_with_zero_clicks
FROM day60_vle_features
WHERE total_clicks = 0;

-- Inspect summary statistics
SELECT
    ROUND(AVG(total_clicks), 2) AS avg_clicks,
    ROUND(AVG(active_days), 2) AS avg_active_days,
    ROUND(AVG(resources_accessed), 2)
        AS avg_resources
FROM day60_vle_features;
