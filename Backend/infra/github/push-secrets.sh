#!/bin/bash

# Ensure gh CLI is installed
if ! command -v gh &>/dev/null; then
  echo "Error: GitHub CLI (gh) is not installed."
  exit 1
fi

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

# Load variables from .github.env
export $(grep -v '^#' "$GITHUB_ENV_FILE" | xargs)

# Check required variables
if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
  echo "Error: OWNER and REPO must be set in $GITHUB_ENV_FILE"
  exit 1
fi

# Authenticate with GitHub if not already authenticated
if ! gh auth status &>/dev/null; then
  echo "You need to authenticate with GitHub CLI."
  gh auth login
fi

gh secret set -f "$GITHUB_ENV_FILE" --repo "$OWNER/$REPO"

echo ""
echo "Generating env block for GitHub Actions workflow..."
echo ""

script_dir=$(dirname "$0")
"$script_dir/generate-env-block.sh" "$GITHUB_ENV_FILE"
