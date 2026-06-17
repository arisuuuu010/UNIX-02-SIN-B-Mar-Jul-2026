#!/bin/bash



# Assign input arguments to descriptive variables
NAME="${1}"
DOMAIN="${2}"
OUTPUT_FILE="results.csv"

# 1. VALIDATION: Check if both expected arguments are provided
if [[ -z "${NAME}" ]] || [[ -z "${DOMAIN}" ]]; then
  echo "You must provide two arguments to this script."
  echo "Example: ${0} mysite nostarch.com"
  exit 1
fi

# 2. INITIALIZATION: Write/Overwrite the CSV header to the output file
echo "status,name,domain,timestamp" > ${OUTPUT_FILE}

# 3. EXECUTION: Ping the domain once (-c 1) and suppress terminal output (&> /dev/null)
if ping -c 1 "${DOMAIN}" &> /dev/null; then
  # If ping succeeds (Exit code 0)
  echo "success,${NAME},${DOMAIN},$(date)" >> "${OUTPUT_FILE}"
else
  # If ping fails (Exit code non-zero)
  echo "failure,${NAME},${DOMAIN},$(date)" >> "${OUTPUT_FILE}"
fi