
# MAC5043 Assignment 2
# Reproduce OULAD database and Random Forest baseline
# Run from the Assignment 2 project root.

$ErrorActionPreference = "Stop"

$psql = "C:\Program Files\PostgreSQL\17\bin\psql.exe"
$db = "mac5043_oulad_repro"
$python = ".\.venv\Scripts\python.exe"

try {
    # 1. Confirm dataset files exist
    $files = @(
        "courses.csv",
        "studentInfo.csv",
        "studentRegistration.csv",
        "assessments.csv",
        "studentAssessment.csv",
        "vle.csv",
        "studentVle.csv"
    )

    foreach ($file in $files) {
        if (-not (Test-Path "data\$file")) {
            throw "Missing data\$file"
        }
    }

    if (-not (Test-Path $psql)) {
        throw "PostgreSQL 17 psql.exe not found"
    }

    # 2. Recreate Python environment if necessary
    if (-not (Test-Path $python)) {
        py -3.13 -m venv .venv
        if ($LASTEXITCODE -ne 0) {
            throw "Python environment creation failed"
        }
    }

    & $python -m pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        throw "Dependency installation failed"
    }

    # 3. Obtain PostgreSQL password securely
    $secure = Read-Host "PostgreSQL password" -AsSecureString
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)

    try {
        $env:PGPASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }

    # 4. Refuse to overwrite an existing database
    $existing = & $psql -X -U postgres -h localhost -p 5432 `
        -d postgres -tA -c "SELECT 1 FROM pg_database WHERE datname='$db'"

    if ($LASTEXITCODE -ne 0) {
        throw "Cannot connect to PostgreSQL"
    }

    if (($existing | Out-String).Trim() -eq "1") {
        throw "$db already exists. No changes were made."
    }

    # 5. Create a separate reproduction database
    & $psql -X -U postgres -h localhost -p 5432 `
        -d postgres -v ON_ERROR_STOP=1 `
        -c "CREATE DATABASE $db;"

    if ($LASTEXITCODE -ne 0) {
        throw "Database creation failed"
    }

    # 6. Run the SQL files in dependency order
    $scripts = @(
        "sql\create_tables.sql",
        "sql\import_clean.sql",
        "sql\create_day60_cohort.sql",
        "sql\create_day60_features.sql",
        "sql\create_model_dataset.sql"
    )

    foreach ($script in $scripts) {
        Write-Host "Running $script"

        & $psql -X -U postgres -h localhost -p 5432 `
            -d $db -v ON_ERROR_STOP=1 -1 -f $script

        if ($LASTEXITCODE -ne 0) {
            throw "Failed at $script"
        }
    }

    # 7. Train baseline using reproduction database
    $env:OULAD_DB = $db

    Write-Host "Training Random Forest..."

    & $python src\train_baseline.py

    if ($LASTEXITCODE -ne 0) {
        throw "Model training failed"
    }

    Write-Host "Reproduction completed."
}
finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
    Remove-Item Env:\OULAD_DB -ErrorAction SilentlyContinue
}
