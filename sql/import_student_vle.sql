
-- MAC5043 Assignment 2
-- Import OULAD studentVle.csv
-- PostgreSQL 17.12

\copy "studentVle" (code_module, code_presentation, id_student, id_site, date, sum_click) FROM 'data/studentVle.csv' WITH (FORMAT csv, HEADER true)
