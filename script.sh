#!/bin/bash

# Command-line arguments
api_token=$1
server_id=$2
site_id=$3
env_file_path=$4
deploy_script_path=$5

# Initial validation
if [[ -z "$server_id" || -z "$site_id" ]]; then
    echo "The \"forge-server-id\" and \"forge-site-id\" values cannot be empty."
    exit 1
fi

# Validate "env-file-path" if supplied
if [[ -n "$env_file_path" && ! -f "$env_file_path" ]]; then
    echo "The supplied \"env-file-path\" is not a valid file."
    exit 1
fi

# Validate "deploy-script-path" if supplied
if [[ -n "$deploy_script_path" && ! -f "$deploy_script_path" ]]; then
    echo "The supplied \"deploy-script-path\" is not a valid file."
    exit 1
fi

# Helper function
function api_request {
    local method=$1
    local endpoint=$2
    local data=${3:-"{}"}

    code=$(curl \
        --request "$method" \
        --header "Authorization: Bearer $api_token" \
        --header "Accept: application/json" \
        --header "Content-Type: application/json" \
        --data "$data" \
        --output /dev/null \
        --write-out "%{http_code}" \
        --silent \
        "https://forge.laravel.com/api/v1/servers/$server_id/sites/$site_id/$endpoint")
    
    if [[ "$code" -ne 200 ]]; then
        echo "Forge API error encountered."
        exit 1
    fi
}

# Update the .env file
if [[ -n "$env_file_path" ]]; then
    # Read the contents of the file into a variable
    file_contents=$(<"$env_file_path")

    # Create a JSON object with "content" property
    data=$(jq -n --arg content "$file_contents" '{content: $content}')

    echo "Updating the .env file..."
    api_request "PUT" "env" "$data"
fi

# Update the deploy script
if [[ -n "$deploy_script_path" ]]; then
    # Read the contents of the file into a variable
    file_contents=$(<"$deploy_script_path")

    # Create a JSON object with "content" property
    data=$(jq -n --arg content "$file_contents" '{content: $content}')

    echo "Updating the deploy script..."
    api_request "PUT" "deployment/script" "$data"
fi

# Trigger the deployment
echo "Deploying..."
api_request "POST" "deployment/deploy"
