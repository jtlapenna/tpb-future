#!/bin/bash

# Documentation Validation Script
# This script validates the integrity of the documentation structure

echo "Starting documentation validation..."

# Check directory structure
echo "Checking directory structure..."
DIRS=(
  "docs/architecture"
  "docs/architecture/diagrams"
  "docs/guides"
  "docs/patterns/detection"
  "docs/patterns/relationships"
  "docs/patterns/analysis"
  "docs/validation/rules"
  "docs/validation/metrics"
  "docs/validation/reporting"
  "docs/examples/components"
  "docs/examples/themes"
  "docs/reference"
)

for dir in "${DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "✓ Directory exists: $dir"
  else
    echo "✗ Missing directory: $dir"
  fi
done

# Check key files
echo -e "\nChecking key files..."
FILES=(
  "docs/architecture/overview.md"
  "docs/architecture/diagrams/system-overview.mmd"
  "docs/architecture/diagrams/data-flow.mmd"
  "docs/architecture/diagrams/validation-flow.mmd"
  "docs/architecture/diagrams/migration-flow.mmd"
  "docs/guides/quickstart.md"
  "docs/guides/migration-guide.md"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "✓ File exists: $file"
  else
    echo "✗ Missing file: $file"
  fi
done

# Check for orphaned files
echo -e "\nChecking for orphaned files..."
find docs -type f -not -path "*/\.*" | while read file; do
  if [[ "$file" == *".md" || "$file" == *".mmd" ]]; then
    echo "Found file: $file"
  fi
done

# Check Mermaid syntax in diagram files
echo -e "\nValidating Mermaid syntax in diagrams..."
find docs/architecture/diagrams -name "*.mmd" | while read file; do
  if grep -q "graph" "$file"; then
    echo "✓ Valid Mermaid syntax in: $file"
  else
    echo "✗ Invalid or missing Mermaid syntax in: $file"
  fi
done

echo -e "\nValidation complete!" 