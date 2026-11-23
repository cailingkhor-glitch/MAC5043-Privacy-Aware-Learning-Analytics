

\# Privacy-Aware Learning Analytics Data Management Framework



\## MAC5043 Assignment 2



This project implements the initial proof of setup for

a privacy-aware learning analytics framework using OULAD.



\## Technologies



\- Python 3.13.5

\- PostgreSQL 17.12

\- pandas 3.1.1

\- scikit-learn 1.9.1

\- Git



\## Dataset



Open University Learning Analytics Dataset (OULAD).



Source:

https://archive.ics.uci.edu/dataset/349/open+university+learning+analytics+dataset



Licence: CC BY 4.0



See data/README.md for download instructions.



\## Environment Setup



Run the following commands in PowerShell:



py -3.13 -m venv .venv



.\\.venv\\Scripts\\python.exe -m pip install -r requirements.txt



\## Implementation



The project contains:

\- OULAD dataset profiling and validation

\- Seven-table PostgreSQL database

\- Day-60 student cohort preparation

\- VLE feature engineering

\- Non-private Random Forest baseline



Database setup requires PostgreSQL 17 and the SQL scripts

in the sql/ folder. Import scripts must not be rerun

on tables that already contain data.



\## Running the Baseline



After preparing the database, run:



.\\.venv\\Scripts\\python.exe src\\train\_baseline.py



The program prompts for the PostgreSQL password.



\## Initial Experimental Results



Dataset: 23,977 student records

Random seed: 42

Train/validation/test: 70/15/15



Test accuracy: 0.7123

Test ROC-AUC: 0.7650

Test F1-score: 0.6182



Results: results/random\_forest\_baseline.json



\## Implementation Limitations



DP-SGD, simulated FedAvg, membership-inference testing

and complete privacy compliance verification remain

planned work.



\## AI-Assistance Declaration



Generative AI assistance was used for Python and SQL

code drafting, troubleshooting, and documentation.

The implementation was executed locally, and generated

code must be reviewed and understood by the student.
