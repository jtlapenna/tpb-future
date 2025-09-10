#!/bin/bash

# Link Validation Script
# This script checks for broken links in the documentation

echo "Starting link validation..."

# Base directory for documentation
DOCS_DIR="docs"

# Function to check internal links in a file
check_internal_links() {
  local file=$1
  echo "Checking links in $file..."
  
  # Extract markdown links
  links=$(grep -o '\[.*\](.*\.md[^)]*)' "$file" | sed 's/.*(\(.*\))/\1/' | sed 's/#.*//')
  
  # Check each link
  for link in $links; do
    # Handle relative paths
    if [[ "$link" == /* ]]; then
      # Absolute path within docs
      target_file="${DOCS_DIR}${link}"
    else
      # Relative path
      dir=$(dirname "$file")
      target_file="${dir}/${link}"
    fi
    
    # Check if file exists
    if [ -f "$target_file" ]; then
      echo "✓ Valid link: $link"
    else
      echo "✗ Broken link: $link in $file"
    fi
  done
}

# Function to check diagram references
check_diagram_references() {
  local file=$1
  echo "Checking diagram references in $file..."
  
  # Extract diagram references
  refs=$(grep -o '!\[.*\](.*\.mmd[^)]*)' "$file" | sed 's/.*(\(.*\))/\1/')
  
  # Check each reference
  for ref in $refs; do
    # Handle relative paths
    if [[ "$ref" == /* ]]; then
      # Absolute path within docs
      target_file="${DOCS_DIR}${ref}"
    else
      # Relative path
      dir=$(dirname "$file")
      target_file="${dir}/${ref}"
    fi
    
    # Check if file exists
    if [ -f "$target_file" ]; then
      echo "✓ Valid diagram reference: $ref"
    else
      echo "✗ Broken diagram reference: $ref in $file"
    fi
  done
}

# Find all markdown files
find "$DOCS_DIR" -name "*.md" | while read file; do
  check_internal_links "$file"
  check_diagram_references "$file"
  echo "------------------------"
done

echo "Link validation complete!" 