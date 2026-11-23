
-- MAC5043 Assignment 2
-- Import the four remaining smaller OULAD tables
-- courses and studentInfo have already been loaded.

-- 1. Student registration
\copy "studentRegistration" FROM 'data/studentRegistration.csv' WITH (FORMAT csv, HEADER true, FORCE_NULL (date_registration, date_unregistration))

-- 2. Assessments
\copy assessments FROM 'data/assessments.csv' WITH (FORMAT csv, HEADER true, FORCE_NULL (date))

-- 3. VLE resource information
\copy vle FROM 'data/vle.csv' WITH (FORMAT csv, HEADER true, FORCE_NULL (week_from, week_to))

-- 4. Student assessment results
\copy "studentAssessment" FROM 'data/studentAssessment.csv' WITH (FORMAT csv, HEADER true, FORCE_NULL (date_submitted, is_banked, score))

-- Correct missing IMD bands imported as empty text
UPDATE "studentInfo"
SET imd_band = NULL
WHERE imd_band = '';
