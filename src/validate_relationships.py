
from pathlib import Path
import pandas as pd

DATA = Path(__file__).resolve().parents[1] / "data"

print("=== STUDENT ASSESSMENT VALIDATION ===")

assessments = pd.read_csv(DATA / "assessments.csv")

student_assessments = pd.read_csv(
    DATA / "studentAssessment.csv"
)

students = pd.read_csv(
    DATA / "studentInfo.csv",
    usecols=["code_module", "code_presentation", "id_student"]
)

# Check whether assessments exist
assessment_check = student_assessments.merge(
    assessments[
        ["id_assessment", "code_module", "code_presentation"]
    ],
    on="id_assessment",
    how="left",
    indicator="assessment_status",
    validate="many_to_one"
)

missing_assessment = (
    assessment_check["assessment_status"] == "left_only"
).sum()

# Check whether students exist in the correct module
student_check = assessment_check.merge(
    students.drop_duplicates(),
    on=["code_module", "code_presentation", "id_student"],
    how="left",
    indicator="student_status",
    validate="many_to_one"
)

missing_student = (
    student_check["student_status"] == "left_only"
).sum()

print(f"Missing assessment references: {missing_assessment:,}")
print(f"Missing student references: {missing_student:,}")

print("\n=== STUDENT VLE VALIDATION ===")

vle = pd.read_csv(
    DATA / "vle.csv",
    usecols=["id_site", "code_module", "code_presentation"]
)

site_keys = pd.MultiIndex.from_frame(
    vle[["id_site", "code_module", "code_presentation"]]
)

student_keys = pd.MultiIndex.from_frame(
    students[["code_module", "code_presentation", "id_student"]]
)

invalid_sites = 0
invalid_students = 0
total = 0

for chunk in pd.read_csv(
    DATA / "studentVle.csv",
    chunksize=100_000
):
    total += len(chunk)

    chunk_sites = pd.MultiIndex.from_frame(
        chunk[["id_site", "code_module", "code_presentation"]]
    )

    chunk_students = pd.MultiIndex.from_frame(
        chunk[["code_module", "code_presentation", "id_student"]]
    )

    invalid_sites += int(
        (~chunk_sites.isin(site_keys)).sum()
    )

    invalid_students += int(
        (~chunk_students.isin(student_keys)).sum()
    )

print(f"VLE records checked: {total:,}")
print(f"Invalid site references: {invalid_sites:,}")
print(f"Invalid student references: {invalid_students:,}")

print("\nRelationship validation completed.")
