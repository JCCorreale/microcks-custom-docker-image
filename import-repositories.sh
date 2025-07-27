#!/bin/bash
set -e

# Start Microcks in background
/deployments/run-java.sh &

MICROCKS_PID=$!

echo "Raw REPOSITORIES_JSON:"
echo $REPOSITORIES_JSON

# Wait until Microcks is available
echo "Waiting for Microcks to start..."
until curl -s -u admin:microcks http://localhost:8080/api/services > /dev/null; do
  sleep 5
done

echo "Microcks is up!"

# Parse and import repositories from env variable REPOSITORIES_JSON
if [[ -z "$REPOSITORIES_JSON" ]]; then
  echo "No repositories configured in REPOSITORIES_JSON environment variable."
else
  echo "Importing repositories from REPOSITORIES_JSON..."
  
  # Use jq to parse the JSON array and iterate
  echo "$REPOSITORIES_JSON" | jq -c '.repositories[]' | while read -r repo; do
    echo "Creating repository:"
    echo "$repo" | jq .
    
    # curl -s -u admin:microcks -H "Content-Type: application/json" \
    #   -X POST http://localhost:8080/api/jobs \
    #   -d "$repo"

    response=$(curl -s -u admin:microcks -H "Content-Type: application/json" \
        -X POST http://localhost:8080/api/jobs \
        -d "$repo")

    id=$(echo "$response" | jq -r '.id')

    curl -s -u admin:microcks -X PUT "http://localhost:8080/api/jobs/${id}/start"

  done
  echo    
  echo "All repositories imported."
fi

# Wait forever to keep container running
wait $MICROCKS_PID
