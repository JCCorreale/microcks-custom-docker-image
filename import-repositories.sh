#!/bin/bash
set -e

# Start Microcks in background
/deployments/run-java.sh --server.port=$PORT &

MICROCKS_PID=$!

# Wait until Microcks is available
until curl -s -u admin:microcks http://localhost:$PORT/api/services > /dev/null; do
  echo "Waiting for Microcks to start..."
  sleep 5
done

echo "Microcks is up!"

# Parse and import repositories from env variable REPOSITORIES_JSON
if [[ -z "$REPOSITORIES_JSON" ]]; then
  echo "No repositories configured in REPOSITORIES_JSON environment variable."
else
  echo "Importing repositories from REPOSITORIES_JSON..."

  echo "Raw REPOSITORIES_JSON:"
  echo "$REPOSITORIES_JSON"
  
  # Use jq to parse the JSON array and iterate
  echo "$REPOSITORIES_JSON" | jq -c '.repositories[]' | while read -r repo; do
    echo "Creating repository:"
    echo "$repo" | jq .

    response=$(curl -s -u admin:microcks -H "Content-Type: application/json" \
        -X POST http://localhost:$PORT/api/jobs \
        -d "$repo")

    id=$(echo "$response" | jq -r '.id')

    curl -s -u admin:microcks -X PUT "http://localhost:$PORT/api/jobs/${id}/start"

  done
  echo    
  echo "All repositories imported."
fi

# Wait forever to keep container running
wait $MICROCKS_PID
