
from pathlib import Path
from getpass import getpass
import json
import pandas as pd

from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    accuracy_score,
    roc_auc_score,
    precision_score,
    recall_score,
    f1_score,
    confusion_matrix,
)

ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "results"
RESULTS.mkdir(exist_ok=True)

# Connect securely without storing the password in code
password = getpass("PostgreSQL password: ")

url = URL.create(
    "postgresql+psycopg",
    username="postgres",
    password=password,
    host="localhost",
    port=5432,
    database="mac5043_oulad",
)

engine = create_engine(url)

print("Loading day-60 modelling dataset...")

with engine.connect() as connection:
    df = pd.read_sql_query(
        text("SELECT * FROM day60_model_dataset"),
        connection
    )

engine.dispose()

print(f"Records loaded: {len(df):,}")

assert len(df) == 23977
assert df["id_student"].is_unique
assert df["at_risk"].notna().all()

# Do not use IDs or final outcomes as predictors
categorical = [
    "code_module",
    "code_presentation",
    "gender",
    "region",
    "highest_education",
    "imd_band",
    "age_band",
    "disability",
]

numeric = [
    "num_of_prev_attempts",
    "studied_credits",
    "date_registration",
    "total_clicks",
    "active_days",
    "resources_accessed",
    "clicks_day0_30",
    "clicks_day31_60",
]

X = df[categorical + numeric]
y = df["at_risk"].astype(int)

# 70% training, 15% validation, 15% testing
X_train, X_temp, y_train, y_temp = train_test_split(
    X, y,
    test_size=0.30,
    random_state=42,
    stratify=y
)

X_val, X_test, y_val, y_test = train_test_split(
    X_temp, y_temp,
    test_size=0.50,
    random_state=42,
    stratify=y_temp
)

print(f"Training: {len(X_train):,}")
print(f"Validation: {len(X_val):,}")
print(f"Testing: {len(X_test):,}")

numeric_pipeline = Pipeline([
    ("imputer", SimpleImputer(strategy="median"))
])

categorical_pipeline = Pipeline([
    ("imputer", SimpleImputer(
        strategy="most_frequent"
    )),
    ("encoder", OneHotEncoder(
        handle_unknown="ignore"
    ))
])

preprocessor = ColumnTransformer([
    ("numeric", numeric_pipeline, numeric),
    ("categorical", categorical_pipeline, categorical)
])

model = Pipeline([
    ("preprocessing", preprocessor),
    ("classifier", RandomForestClassifier(
        n_estimators=200,
        random_state=42,
        n_jobs=-1,
        class_weight="balanced"
    ))
])

print("\nTraining Random Forest...")
model.fit(X_train, y_train)

def evaluate(name, features, labels):
    predictions = model.predict(features)
    probabilities = model.predict_proba(features)[:, 1]

    metrics = {
        "accuracy": float(accuracy_score(labels, predictions)),
        "roc_auc": float(roc_auc_score(labels, probabilities)),
        "precision": float(precision_score(
            labels, predictions, zero_division=0
        )),
        "recall": float(recall_score(
            labels, predictions, zero_division=0
        )),
        "f1": float(f1_score(
            labels, predictions, zero_division=0
        )),
        "confusion_matrix": confusion_matrix(
            labels, predictions
        ).tolist()
    }

    print(f"\n{name} results")
    for key, value in metrics.items():
        print(f"{key}: {value}")

    return metrics

validation_metrics = evaluate(
    "Validation", X_val, y_val
)

test_metrics = evaluate(
    "Test", X_test, y_test
)

results = {
    "model": "Random Forest (non-private)",
    "random_seed": 42,
    "observation_window": "Day 0-60",
    "records": len(df),
    "training_records": len(X_train),
    "validation_records": len(X_val),
    "testing_records": len(X_test),
    "features": categorical + numeric,
    "validation": validation_metrics,
    "test": test_metrics
}

output = RESULTS / "random_forest_baseline.json"

with open(output, "w", encoding="utf-8") as file:
    json.dump(results, file, indent=2)

print(f"\nResults saved to: {output}")
