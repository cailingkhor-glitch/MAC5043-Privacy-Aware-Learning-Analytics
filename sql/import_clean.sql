
-- Reproducible OULAD import
-- Run only against seven newly created, empty tables.

\copy courses FROM 'data/courses.csv' WITH (FORMAT csv, HEADER true)
\copy "studentInfo" FROM 'data/studentInfo.csv' WITH (FORMAT csv, HEADER true, FORCE_NULL (imd_band))
\copy "studentRegistration" FROM 'data/studentRegistration.csv' WITH (FORMAT csv, HEADER true, FORCE_NULL (date_registration, date_unregistration))
\copy assessments FROM 'data/assessments.csv' WITH (FORMAT csv, HEADER true, FORCE_NULL (date))
\copy vle FROM 'data/vle.csv' WITH (FORMAT csv, HEADER true, FORCE_NULL (week_from, week_to))
\copy "studentAssessment" FROM 'data/studentAssessment.csv' WITH (FORMAT csv, HEADER true, FORCE_NULL (score))
\copy "studentVle" (code_module, code_presentation, id_student, id_site, date, sum_click) FROM 'data/studentVle.csv' WITH (FORMAT csv, HEADER true)
