#!/bin/bash

# Cross-reference Update Script
# Version: 1.0
# Last Updated: March 13, 2024

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if we're in the documentation directory
if [[ ! -d "documentation" ]]; then
    echo -e "${RED}Error: Must be run from the root directory containing 'documentation' folder${NC}"
    exit 1
fi

cd documentation

# Old paths to replace
OLD_PATHS=(
    "../../knowledge-base/"
    "../knowledge-base/"
    "./knowledge-base/"
    "../../docs/"
    "../docs/"
    "./docs/"
)

# Function to update paths in a file
update_paths() {
    local file=$1
    echo -e "${YELLOW}Updating references in: $file${NC}"
    
    # Replace old paths with new paths
    for old_path in "${OLD_PATHS[@]}"; do
        # Remove the old path prefix and determine the relative path based on the file location
        relative_path=$(echo $file | sed 's#[^/]*/#../#g' | sed 's#[^/]*$##')
        sed -i '' "s#$old_path#$relative_path#g" "$file"
    done
    
    # Update internal documentation links
    sed -i '' 's#(\.\./knowledge-base/#(../#g' "$file"
    sed -i '' 's#(\.\./docs/#(../#g' "$file"
}

# Find all markdown files and update their references
echo -e "${YELLOW}Searching for markdown files...${NC}"
while IFS= read -r -d '' file; do
    update_paths "$file"
done < <(find . -type f -name "*.md" -print0)

echo -e "${GREEN}Cross-reference update complete!${NC}" 