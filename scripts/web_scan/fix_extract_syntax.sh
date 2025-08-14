#!/bin/bash

# Fix extract syntax in all scripts

CHECKS_DIR="/Users/arturoeliasanton/github.com/arturoeanton/httpdsl/scripts/web_scan/checks"

echo "Fixing extract syntax in all scripts..."

for file in "$CHECKS_DIR"/*.http; do
    if grep -q "extract .* using" "$file"; then
        echo "Fixing: $(basename $file)"
        
        # Fix various extract patterns
        sed -i '' 's/extract \$\([a-zA-Z_]*\) using body/extract body "" as $\1/g' "$file"
        sed -i '' 's/extract \$\([a-zA-Z_]*\) using status/extract status "" as $\1/g' "$file"
        sed -i '' 's/extract \$\([a-zA-Z_]*\) using time/extract time "" as $\1/g' "$file"
        sed -i '' "s/extract \$\([a-zA-Z_]*\) using regex '\([^']*\)'/extract regex \"\2\" as \$\1/g" "$file"
        sed -i '' 's/extract \$\([a-zA-Z_]*\) using regex "\([^"]*\)"/extract regex "\2" as $\1/g' "$file"
        sed -i '' "s/extract \$\([a-zA-Z_]*\) using header '\([^']*\)'/extract header \"\2\" as \$\1/g" "$file"
        sed -i '' 's/extract \$\([a-zA-Z_]*\) using header "\([^"]*\)"/extract header "\2" as $\1/g' "$file"
        sed -i '' "s/extract \$\([a-zA-Z_]*\) using jsonpath '\([^']*\)'/extract jsonpath \"\2\" as \$\1/g" "$file"
        sed -i '' 's/extract \$\([a-zA-Z_]*\) using jsonpath "\([^"]*\)"/extract jsonpath "\2" as $\1/g' "$file"
        
        # Also fix header extraction without quotes
        sed -i '' 's/extract \$\([a-zA-Z_]*\) using header \([A-Za-z-]*\)$/extract header "\2" as $\1/g' "$file"
    fi
done

echo "Done fixing extract syntax!"