
-- MAC5043 Assignment 2
-- OULAD seven-table relational schema
-- PostgreSQL 17.12

-- 1. COURSES
CREATE TABLE IF NOT EXISTS courses (
    code_module VARCHAR(10) NOT NULL,
    code_presentation VARCHAR(10) NOT NULL,
    module_presentation_length INTEGER,
    PRIMARY KEY (code_module, code_presentation)
);

-- 2. STUDENT INFO
CREATE TABLE IF NOT EXISTS "studentInfo" (
    code_module VARCHAR(10) NOT NULL,
    code_presentation VARCHAR(10) NOT NULL,
    id_student INTEGER NOT NULL,
    gender VARCHAR(10),
    region VARCHAR(100),
    highest_education VARCHAR(100),
    imd_band VARCHAR(30),
    age_band VARCHAR(30),
    num_of_prev_attempts INTEGER,
    studied_credits INTEGER,
    disability VARCHAR(10),
    final_result VARCHAR(30),

    PRIMARY KEY (
        code_module, code_presentation, id_student
    ),

    FOREIGN KEY (code_module, code_presentation)
        REFERENCES courses (
            code_module, code_presentation
        )
);

-- 3. STUDENT REGISTRATION
CREATE TABLE IF NOT EXISTS "studentRegistration" (
    code_module VARCHAR(10) NOT NULL,
    code_presentation VARCHAR(10) NOT NULL,
    id_student INTEGER NOT NULL,
    date_registration INTEGER,
    date_unregistration INTEGER,

    PRIMARY KEY (
        code_module, code_presentation, id_student
    ),

    FOREIGN KEY (
        code_module, code_presentation, id_student
    )
    REFERENCES "studentInfo" (
        code_module, code_presentation, id_student
    )
);

-- 4. ASSESSMENTS
CREATE TABLE IF NOT EXISTS assessments (
    code_module VARCHAR(10) NOT NULL,
    code_presentation VARCHAR(10) NOT NULL,
    id_assessment INTEGER PRIMARY KEY,
    assessment_type VARCHAR(20),
    date INTEGER,
    weight NUMERIC(8,2),

    FOREIGN KEY (code_module, code_presentation)
        REFERENCES courses (
            code_module, code_presentation
        )
);

-- 5. VLE
CREATE TABLE IF NOT EXISTS vle (
    id_site INTEGER PRIMARY KEY,
    code_module VARCHAR(10) NOT NULL,
    code_presentation VARCHAR(10) NOT NULL,
    activity_type VARCHAR(100),
    week_from INTEGER,
    week_to INTEGER,

    UNIQUE (id_site, code_module, code_presentation),

    FOREIGN KEY (code_module, code_presentation)
        REFERENCES courses (
            code_module, code_presentation
        )
);

-- 6. STUDENT ASSESSMENT
CREATE TABLE IF NOT EXISTS "studentAssessment" (
    id_assessment INTEGER NOT NULL,
    id_student INTEGER NOT NULL,
    date_submitted INTEGER,
    is_banked INTEGER,
    score NUMERIC(8,2),

    FOREIGN KEY (id_assessment)
        REFERENCES assessments (id_assessment)
);

-- 7. STUDENT VLE
CREATE TABLE IF NOT EXISTS "studentVle" (
    record_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code_module VARCHAR(10) NOT NULL,
    code_presentation VARCHAR(10) NOT NULL,
    id_student INTEGER NOT NULL,
    id_site INTEGER NOT NULL,
    date INTEGER,
    sum_click INTEGER,

    FOREIGN KEY (
        code_module, code_presentation, id_student
    )
    REFERENCES "studentInfo" (
        code_module, code_presentation, id_student
    ),

    FOREIGN KEY (
        id_site, code_module, code_presentation
    )
    REFERENCES vle (
        id_site, code_module, code_presentation
    )
);
