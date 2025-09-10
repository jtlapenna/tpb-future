#!/bin/bash

# File Migration Script
# This script migrates files from the old phase-based structure to the new content-based structure

echo "Starting file migration process..."

# Create directories if they don't exist
mkdir -p docs/architecture
mkdir -p docs/guides
mkdir -p docs/patterns/detection
mkdir -p docs/patterns/relationships
mkdir -p docs/patterns/analysis
mkdir -p docs/validation/rules
mkdir -p docs/validation/metrics
mkdir -p docs/validation/reporting
mkdir -p docs/examples/components
mkdir -p docs/examples/themes
mkdir -p docs/reference

# Migration mappings
echo "Migrating files..."

# Patterns
if [ -f "output/phase8/technical/patterns/detection_rules.md" ]; then
  cp "output/phase8/technical/patterns/detection_rules.md" "docs/patterns/detection/rules.md"
  echo "✓ Migrated detection rules"
else
  echo "! Detection rules file not found"
fi

if [ -f "output/phase8/technical/patterns/relationships.md" ]; then
  cp "output/phase8/technical/patterns/relationships.md" "docs/patterns/relationships/dependencies.md"
  echo "✓ Migrated relationships"
else
  echo "! Relationships file not found"
fi

if [ -f "output/phase8/technical/patterns/analysis_rules.md" ]; then
  cp "output/phase8/technical/patterns/analysis_rules.md" "docs/patterns/analysis/static-rules.md"
  echo "✓ Migrated analysis rules"
else
  echo "! Analysis rules file not found"
fi

# Validation
if [ -f "output/phase8/technical/validation/rules.md" ]; then
  cp "output/phase8/technical/validation/rules.md" "docs/validation/rules/style-integrity.md"
  echo "✓ Migrated validation rules"
else
  echo "! Validation rules file not found"
fi

if [ -f "output/phase8/technical/validation/metrics.md" ]; then
  cp "output/phase8/technical/validation/metrics.md" "docs/validation/metrics/core-metrics.md"
  echo "✓ Migrated metrics"
else
  echo "! Metrics file not found"
fi

# Main documents
if [ -f "output/phase8/technical/style_migration_summary.md" ]; then
  cp "output/phase8/technical/style_migration_summary.md" "docs/architecture/overview.md"
  echo "✓ Migrated style migration summary"
else
  echo "! Style migration summary file not found"
fi

if [ -f "output/phase8/technical/quickstart_guide.md" ]; then
  cp "output/phase8/technical/quickstart_guide.md" "docs/guides/quickstart.md"
  echo "✓ Migrated quickstart guide"
else
  echo "! Quickstart guide file not found"
fi

# Additional files
if [ -f "output/phase8/technical/style_migration.md" ]; then
  cp "output/phase8/technical/style_migration.md" "docs/guides/migration-guide.md"
  echo "✓ Migrated style migration guide"
else
  echo "! Style migration guide file not found"
fi

echo "Migration complete!"
echo "Please check for any missing files or errors in the migration process." 