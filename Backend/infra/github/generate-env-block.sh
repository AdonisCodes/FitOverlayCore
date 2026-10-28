#!/bin/bash

# Check if env file is provided as argument
if [ $# -eq 0 ]; then
  echo "Usage: $0 <env-file>"
  echo "Example: $0 .env.local"
  exit 1
fi

GITHUB_ENV_FILE="$1"

if [ ! -f "$GITHUB_ENV_FILE" ]; then
  echo "Error: Could not find env file at $GITHUB_ENV_FILE"
  exit 1
fi

echo "env:"

# Read .env file and process variables
while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip empty lines and comments
  if [[ -z "$line" ]] || [[ "$line" =~ ^# ]]; then
    continue
  fi

  # Extract key and value
  if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
    ENV_NAME="${BASH_REMATCH[1]}"
    ENV_VALUE="${BASH_REMATCH[2]}"

    # Remove possible surrounding quotes from the value
    ENV_VALUE=$(echo "$ENV_VALUE" | sed -e 's/^"//' -e 's/"$//')

    # Generate the env block line
    echo "  $ENV_NAME: \${{ secrets.$ENV_NAME }}"
  fi
done <"$GITHUB_ENV_FILE" 