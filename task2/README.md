Task 2 was implemented as Option B (Python + GCP Native approach). Keboola Generic Extractor would be a valid alternative for Option A - using JSON configuration file defining the API endpoint, authentication, and response mapping. The Python approach was chosen as more flexible & portable.

# Task 2 - Golemio Municipal Libraries Extractor

## Overview
Python-based extractor for Prague municipal libraries data from the Golemio API. Extracts 10 fields per library and saves to CSV.

## Output Fields
1. id - Library ID
2. name - Library name
3. street - Street address
4. zip - Postal code
5. city - City/locality
6. region - District (closest available field to Kraj in API)
7. country - Country
8. latitude - Geographic latitude
9. longitude - Geographic longitude
10. opening_hours - Opening hours per day of week

## Setup & Configuration

### Requirements
```bash
pip install requests pandas python-dotenv
```

### API Key
1. Register at api.golemio.cz/api-keys
2. Copy .env.example to .env
3. Add your API key to .env:
```
GOLEMIO_API_KEY=your_actual_key_here
```

### Run
```bash
python extractor.py
```
Output CSV saved to `output/libraries.csv`

## Scheduling

### Option A - Local cron job
```
0 7 * * * /usr/bin/python3 /path/to/extractor.py
```
Timezone: Europe/Prague (CET/CEST)

### Option B - GCP Native (Cloud Scheduler + Cloud Functions) (Možnosť B (GCP Native): Navrhnite riešenie pomocou Google Cloud Functions a Secret Manager na uloženie API kľúčov.)
1. Deploy script as Google Cloud Function, save extraction results to GCS or BigQuery
2. Store API key in GCP Secret Manager. Google Cloud Function request the key when needed & Secret Manager returns it securely. Call is never stored anywhere in code.
3. Create Cloud Scheduler job:
   - Cron: `0 7 * * *`
   - Timezone: `Europe/Prague`
   - Target: Cloud Function HTTP trigger URL

## Notes

- API key is loaded locally from .env file via python-dotenv. In a production GCP deployment, the API key would be stored in GCP Secret Manager and accessed programmatically. This follows GCP best practices for secret management. This topic is also described in Q.21 in Task 5.
- Never commit .env to version control (see .gitignore)
- Region field mapped from `district` property - Golemio API 
  does not provide an explicit region/kraj field
- Opening hours flattened from nested JSON to readable string

## Sample Output (sample row)

| id | name | street | zip | city | region | country | latitude | longitude | opening_hours |
|----|------|--------|-----|------|--------|---------|----------|-----------|---------------|
| 38 | Dům čtení | Ruská 1455/192 | 10000 | Praha 10 | praha-10 | Česko | 50.072703 | 14.483362 | Monday: 13:00-19:00; Tuesday: 09:00-16:00; Wednesday: 12:00-19:00; Thursday: 12:00-19:00; Friday: 09:00-16:00; Saturday: 09:00-13:00 |