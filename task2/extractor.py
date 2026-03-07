import os
import requests
from dotenv import load_dotenv
import pandas as pd

# Load the variable(s) from .env file into the current environment
load_dotenv()
# Access the specific variable by its name
api_key = os.getenv("GOLEMIO_API_KEY")
# Check if API key is actually loaded
if not api_key:
    raise ValueError("API Key not found! Did you forget to create the .env file?")

# Get response via API get request
response = requests.get(
    "https://api.golemio.cz/v2/municipallibraries",
    headers={"X-Access-Token": api_key},
    # params={"limit": 1}  # just get 1 record to see structure
)

# Parse response
data = response.json()

# Extract features list
features = data.get("features", [])

# Create library records list
# Define the list
records = []

# Iterate over features
for feature in features:
    # Safely extract features
    props = feature.get("properties", {})
    address = props.get("address", {})
    coords = feature.get("geometry", {}).get("coordinates", [None, None])
    hours = props.get("opening_hours", [])
    # For opening hours -  format them to a readable string
    opening_hours_str = "; ".join([
        f"{h['day_of_week']}: {h['opens']}-{h['closes']}"
        for h in hours
    ])
   
    # Add features to the list
    records.append({
        "id": props.get("id"),
        "name": props.get("name"),
        "street": address.get("street_address"),
        "zip": address.get("postal_code"),
        "city": address.get("address_locality"),
        "region": props.get("district"),
        "country": address.get("address_country"),
        "latitude": coords[1],
        "longitude": coords[0],
        "opening_hours": opening_hours_str
    })

# Create dataframe out of records data
df = pd.DataFrame(records)

# Set display options for the DataFrame columns
pd.set_option('display.max_columns', 10)
pd.set_option('display.max_colwidth', 50)

# Create an output directory if there is no such directory yet
os.makedirs("output", exist_ok=True)
# Export DataFrame to csv
df.to_csv("output/libraries.csv", index=False, encoding="utf-8-sig")
# Print status message
print(f"Saved {len(df)} libraries to output/libraries.csv")