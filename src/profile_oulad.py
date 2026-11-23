
from pathlib import Path
import json
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"
RESULTS = ROOT / "results"
RESULTS.mkdir(exist_ok=True)

files = [
    "assessments.csv",
    "courses.csv",
    "studentAssessment.csv",
    "studentInfo.csv",
    "studentRegistration.csv",
    "studentVle.csv",
    "vle.csv",
]

summary = []

for filename in files:
    path = DATA / filename

    if not path.exists():
        raise FileNotFoundError(f"Missing file: {path}")

    print(f"Profiling {filename}...")

    rows = 0
    columns = []
    missing = {}
    types = {}

    for chunk in pd.read_csv(path, chunksize=100000):
        rows += len(chunk)

        if not columns:
            columns = list(chunk.columns)
            missing = {c: 0 for c in columns}
            types = {
                c: str(chunk[c].dtype) for c in columns
            }

        for col, count in chunk.isna().sum().items():
            missing[col] += int(count)

    summary.append({
        "filename": filename,
        "rows": rows,
        "columns": len(columns),
        "column_names": columns,
        "data_types": types,
        "missing_values": missing,
    })

    print(f"  Rows: {rows:,}")
    print(f"  Columns: {len(columns)}")
    print(f"  Missing cells: {sum(missing.values()):,}")

students = pd.read_csv(DATA / "studentInfo.csv")

outcomes = {
    str(k): int(v)
    for k, v in students["final_result"]
        .value_counts(dropna=False).items()
}

output = {
    "tables": summary,
    "final_result_distribution": outcomes,
}

with open(
    RESULTS / "oulad_profile.json",
    "w",
    encoding="utf-8"
) as f:
    json.dump(output, f, indent=2)

print("\nStudent outcome distribution:")
for outcome, count in outcomes.items():
    print(f"  {outcome}: {count:,}")

print("\nSaved: results/oulad_profile.json")
