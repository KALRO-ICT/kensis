# A ETL workflow for soil observation data

Assumes a set of .csv files with soil data.
Assumes a metadata file for each file describing the data file.
The scripts picks up the files in the folder and uploads them to a postgres database


## Metadata format (updated)

Each data CSV should have a matching metadata file named <csv-basename>-metadata.csv living in the same folder. Each row in the metadata file describes one column in the CSV.

Required columns:

- colname — exact column name as in the CSV
- role — one of: location, sample, parameter (case-insensitive)

Optional but recommended columns:

- unit — unit of measurement for parameter columns (e.g. mg/kg)
- method — short text describing the procedure, protocol, or lab method used to obtain the measurement (e.g. Walkley-Black, ICP-MS, Field pH probe)
- type — numeric, character, date etc (used for inference if you want)

Example (CSV campaign1.csv → metadata campaign1-metadata.csv):

```
colname,role,unit,method,type
sample_id,sample,,
location_id,location,,
site_label,location,,
latitude,location,,
longitude,location,,
date,sample,,ISO8601,date
depth,sample,cm,,
N,parameter,mg/kg,Kjeldahl,numeric
P,parameter,mg/kg,Bray-1,numeric
K,parameter,mg/kg,AmmoniumAcetate,numeric
pH,parameter,,Field pH probe,numeric
```

The script will store the method value alongside each observation in the observations.method column.

Notes & recommendations

- The script uses dbWriteTable() to write observations to a temporary table and then INSERTs to the final table for performance and transactional safety. For very large imports, consider using Postgres COPY or RPostgres::dbCopyTable() features.
- The script stores flexible attributes (extra) as jsonb in Postgres. You can expand the schema (add campaign_id, analyst, lab_id, etc.) as needed.
- Time columns (sample_date) are attempted to be stored as TIMESTAMP WITH TIME ZONE when provided; consider normalizing date formats in metadata or CSVs (ISO8601 recommended).
- Ensure pg_user and pg_password are passed securely when calling the script (e.g., via environment variables or a secret manager in production).

