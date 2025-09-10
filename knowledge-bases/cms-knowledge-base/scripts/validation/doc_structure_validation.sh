#!/bin/bash

# Documentation Structure Validation Script
# Version: 1.0
# Last Updated: March 13, 2024

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Required directories
REQUIRED_DIRS=(
    "architecture/overview"
    "architecture/components"
    "architecture/patterns"
    "implementation/guides"
    "implementation/examples"
    "implementation/patterns"
    "implementation/best-practices"
    "analysis/business-logic"
    "analysis/performance"
    "analysis/security"
    "analysis/integration"
    "reference/api"
    "reference/models"
    "reference/configurations"
    "diagrams/architecture"
    "diagrams/flows"
    "diagrams/models"
    "templates"
    "scripts/validation"
    "tracking/progress"
    "tracking/status"
    "tracking/roadmap"
)

# Required files
REQUIRED_FILES=(
    "README.md"
    "tracking/progress/progress_tracking.md"
    "tracking/status/implementation_status.md"
    "tracking/roadmap/next_steps.md"
    "scripts/validation/link_validation.sh"
    "scripts/validation/validation_script.sh"
    "scripts/validation/migration_script.sh"
)

# Check if we're in the documentation directory
if [[ ! -d "documentation" ]]; then
    echo -e "${RED}Error: Must be run from the root directory containing 'documentation' folder${NC}"
    exit 1
fi

cd documentation

# Check required directories
echo -e "${YELLOW}Checking required directories...${NC}"
missing_dirs=0
for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        echo -e "${RED}Missing directory: $dir${NC}"
        missing_dirs=$((missing_dirs + 1))
    fi
done

if [[ $missing_dirs -eq 0 ]]; then
    echo -e "${GREEN}All required directories present${NC}"
else
    echo -e "${RED}Missing $missing_dirs required directories${NC}"
fi

# Check required files
echo -e "\n${YELLOW}Checking required files...${NC}"
missing_files=0
for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}Missing file: $file${NC}"
        missing_files=$((missing_files + 1))
    fi
done

if [[ $missing_files -eq 0 ]]; then
    echo -e "${GREEN}All required files present${NC}"
else
    echo -e "${RED}Missing $missing_files required files${NC}"
fi

# Check for empty directories
echo -e "\n${YELLOW}Checking for empty directories...${NC}"
empty_dirs=0
while IFS= read -r -d '' dir; do
    if [[ -z "$(ls -A "$dir")" ]]; then
        echo -e "${RED}Empty directory: $dir${NC}"
        empty_dirs=$((empty_dirs + 1))
    fi
done < <(find . -type d -empty -print0)

if [[ $empty_dirs -eq 0 ]]; then
    echo -e "${GREEN}No empty directories found${NC}"
else
    echo -e "${RED}Found $empty_dirs empty directories${NC}"
fi

# Final status
echo -e "\n${YELLOW}Validation Summary:${NC}"
if [[ $missing_dirs -eq 0 && $missing_files -eq 0 && $empty_dirs -eq 0 ]]; then
    echo -e "${GREEN}All checks passed successfully!${NC}"
    exit 0
else
    echo -e "${RED}Validation failed:${NC}"
    [[ $missing_dirs -gt 0 ]] && echo -e "${RED}- Missing directories: $missing_dirs${NC}"
    [[ $missing_files -gt 0 ]] && echo -e "${RED}- Missing files: $missing_files${NC}"
    [[ $empty_dirs -gt 0 ]] && echo -e "${RED}- Empty directories: $empty_dirs${NC}"
    exit 1
fi 