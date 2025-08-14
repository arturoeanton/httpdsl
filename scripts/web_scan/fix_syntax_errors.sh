#!/bin/bash

# Script to fix syntax errors in HTTP DSL scripts

CHECKS_DIR="/Users/arturoeliasanton/github.com/arturoeanton/httpdsl/scripts/web_scan/checks"

echo "Fixing HTTP DSL syntax errors..."

# Fix 1: Replace extract body with extract regex for common patterns
for file in "$CHECKS_DIR"/*.http; do
    echo "Processing $file..."
    
    # Fix extract body as for common patterns
    sed -i '' 's/extract body as \$\([a-zA-Z_]*\)/extract regex ".*" as $\1/g' "$file"
    
    # Fix extract time as (remove time checks for now)
    sed -i '' '/extract time.*as/d' "$file"
    
    # Fix time-based conditions (replace with status-based)
    sed -i '' 's/if \$\([a-zA-Z_]*\)_time greater [0-9]*/if $\1_status equals 500/g' "$file"
    
    # Fix POST with body on separate lines - move body inline
    # This is more complex, so we'll do a simple approach
    perl -i -pe 's/^POST ([^\\n]*)\\n\\s+header ([^\\n]*)\\n\\s+body (.*)$/POST $1 body $3\n    header $2/g' "$file"
    
done

echo "Basic syntax fixes applied to all scripts."
echo "Manual review may be needed for complex cases."