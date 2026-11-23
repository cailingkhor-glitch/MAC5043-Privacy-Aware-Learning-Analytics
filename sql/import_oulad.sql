
-- MAC5043 Assignment 2
-- Import OULAD CSV files
-- Run from the Assignment 2 project folder.

\copy courses FROM 'data/courses.csv' WITH (FORMAT csv, HEADER true)

\copy "studentInfo" FROM 'data/studentInfo.csv' WITH (FORMAT csv, HEADER true)

\copy "studentRegistration" FROM 'data/studentRegistration.csv' WITH (FORMAT csv, HEADER true)

\copy assessments FROM 'data/assessments.csv' WITH (FORMAT csv, HEADER true)

\copy vle FROM 'data/vle.csv' WITH (FORMAT csv, HEADER true)

\copy "studentAssessment" FROM 'data/studentAssessment.csv' WITH (FORMAT csv, HEADER true)
