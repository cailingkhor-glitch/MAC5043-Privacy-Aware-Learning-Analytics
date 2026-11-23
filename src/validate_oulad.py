
from pathlib import Path
import pandas as pd

DATA = Path(__file__).resolve().parents[1] / "data"

files = {
    "courses": "courses.csv",
    "studentInfo": "studentInfo.csv",
    "studentRegistration": "studentRegistration.csv",
    "assessments": "assessments.csv",
    "studentAssessment": "studentAssessment.csv",
    "vle": "vle.csv",
}

tables = {
    name: pd.read_csv(DATA / filename)
    for name, filename in files.items()
}

keys = {
    "courses": ["code_module", "code_presentation"],
    "studentInfo": [
        "code_module", "code_presentation", "id_student"
    ],
    "studentRegistration": [
        "code_module", "code_presentation", "id_student"
    ],
    "assessments": ["id_assessment"],
    "vle": ["id_site"],
}

print("=== PRIMARY KEY VALIDATION ===")

for name, key in keys.items():
    df = tables[name]
    duplicates = df.duplicated(subset=key).sum()
    missing = df[key].isna().any(axis=1).sum()

    print(f"\n{name}")
    print(f"  Rows: {len(df):,}")
    print(f"  Duplicate keys: {duplicates:,}")
    print(f"  Missing keys: {missing:,}")

print("\n=== STUDENT REGISTRATION RELATIONSHIP ===")

student_keys = keys["studentInfo"]

info = tables["studentInfo"][student_keys].drop_duplicates()
registration = tables["studentRegistration"][student_keys]

check = registration.merge(
    info,
    on=student_keys,
    how="left",
    indicator=True
)

orphans = (check["_merge"] == "left_only").sum()
print(f"Unmatched registration records: {orphans:,}")

print("\n=== MISSING VALUES BY COLUMN ===")

for name, df in tables.items():
    missing = df.isna().sum()
    missing = missing[missing > 0]

    if not missing.empty:
        print(f"\n{name}")
        print(missing.to_string())

print("\nInitial relational validation completed.")
