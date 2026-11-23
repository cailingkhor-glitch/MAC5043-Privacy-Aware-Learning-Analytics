

\## Reproducibility



\### Prerequisites

\- Windows PowerShell 5.1

\- Python 3.13.5

\- PostgreSQL 17.12

\- Seven original OULAD CSV files in data/



\### Run the Complete Workflow



From the project root:



powershell -ExecutionPolicy Bypass -File scripts\\reproduce.ps1



The script creates a separate PostgreSQL database,

mac5043\_oulad\_repro, imports all seven OULAD tables,

prepares day-60 modelling features and trains the

non-private Random Forest baseline.



The reproduction database must not already exist.

The original mac5043\_oulad database is not modified.



\### Reproduced Results



\- Modelling records: 23,977

\- Training records: 16,783

\- Validation records: 3,597

\- Testing records: 3,597

\- Test accuracy: 0.7123

\- Test ROC-AUC: 0.7650

\- Test F1-score: 0.6182



Results are available in:

results/random\_forest\_baseline.json

results/random\_forest\_reproduction.json



\### Remaining Work



The full DP-SGD implementation, simulated FedAvg,

membership-inference evaluation and compliance

verification remain planned for the later Case Study.



