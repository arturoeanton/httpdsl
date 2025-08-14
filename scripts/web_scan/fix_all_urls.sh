#!/bin/bash

# Fix all URL references in scripts

CHECKS_DIR="/Users/arturoeliasanton/github.com/arturoeanton/httpdsl/scripts/web_scan/checks"

echo "Fixing all URL references in scripts..."

for file in "$CHECKS_DIR"/*.http; do
    echo "Fixing: $(basename $file)"
    
    # Fix GET/POST/etc without quotes on URLs with paths
    sed -i '' 's|^GET \$target/|GET "$target/|g' "$file"
    sed -i '' 's|^POST \$target/|POST "$target/|g' "$file"
    sed -i '' 's|^PUT \$target/|PUT "$target/|g' "$file"
    sed -i '' 's|^DELETE \$target/|DELETE "$target/|g' "$file"
    sed -i '' 's|^PATCH \$target/|PATCH "$target/|g' "$file"
    sed -i '' 's|^HEAD \$target/|HEAD "$target/|g' "$file"
    sed -i '' 's|^OPTIONS \$target/|OPTIONS "$target/|g' "$file"
    
    # Fix cases where there's already one quote but missing the closing one
    sed -i '' 's|^GET "\$target/\([^"]*\)$|GET "$target/\1"|g' "$file"
    sed -i '' 's|^POST "\$target/\([^"]*\)$|POST "$target/\1"|g' "$file"
    sed -i '' 's|^PUT "\$target/\([^"]*\)$|PUT "$target/\1"|g' "$file"
    sed -i '' 's|^DELETE "\$target/\([^"]*\)$|DELETE "$target/\1"|g' "$file"
    sed -i '' 's|^PATCH "\$target/\([^"]*\)$|PATCH "$target/\1"|g' "$file"
    sed -i '' 's|^HEAD "\$target/\([^"]*\)$|HEAD "$target/\1"|g' "$file"
    sed -i '' 's|^OPTIONS "\$target/\([^"]*\)$|OPTIONS "$target/\1"|g' "$file"
    
    # Fix URLs with query parameters
    sed -i '' 's|^GET \$target?\([^"]*\)$|GET "$target?\1"|g' "$file"
    sed -i '' 's|^POST \$target?\([^"]*\)$|POST "$target?\1"|g' "$file"
done

echo "Done fixing all URL references!"