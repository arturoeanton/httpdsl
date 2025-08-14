#!/bin/bash

# Update all vulnerability scripts with standardized completion message
# Format: [✓] Completed: <script_name> - Found X of Y vulnerabilities tested

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKS_DIR="$SCRIPT_DIR/checks"

echo "Updating vulnerability scripts with standardized completion messages..."

# Process each script
for script in "$CHECKS_DIR"/*.http; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script" .http)
        
        # Count the number of tests (look for common patterns)
        test_count=$(grep -c "# Test [0-9]" "$script" 2>/dev/null || echo 0)
        
        # If no numbered tests, try other patterns
        if [ "$test_count" -eq 0 ]; then
            test_count=$(grep -c "^GET\|^POST\|^PUT\|^DELETE\|^PATCH\|^OPTIONS\|^HEAD" "$script" 2>/dev/null || echo 0)
            # Estimate based on HTTP requests (divide by 2 as rough estimate for tests)
            test_count=$((test_count / 2))
            if [ "$test_count" -eq 0 ]; then
                test_count=10  # Default estimate
            fi
        fi
        
        # Check if script already has the correct format
        if grep -q "\[✓\] Completed:" "$script"; then
            echo "✓ $script_name already updated"
            continue
        fi
        
        # Get the variable name used for counting vulnerabilities
        vuln_var=$(grep -o '\$[a-z_]*vulns' "$script" | head -1 | tr -d '$')
        
        if [ -z "$vuln_var" ]; then
            # Try to find other counting patterns
            vuln_var=$(grep -o 'set \$[a-z_]* \$[a-z_]* + 1' "$script" | grep -o '\$[a-z_]*' | head -1 | tr -d '$')
        fi
        
        if [ -z "$vuln_var" ]; then
            vuln_var="vulns"  # Default variable name
        fi
        
        # Replace existing print statements at the end
        if grep -q "print.*\[RESULT\]" "$script"; then
            # Replace [RESULT] line with new format
            sed -i.bak "s/print.*\[RESULT\].*/print \"[✓] Completed: $script_name - Found \$$vuln_var of $test_count vulnerabilities tested\"/" "$script"
        elif grep -q "print.*Found.*vulnerabilities" "$script"; then
            # Replace other result formats
            sed -i.bak "/print.*Found.*vulnerabilities/c\\
print \"[✓] Completed: $script_name - Found \$$vuln_var of $test_count vulnerabilities tested\"" "$script"
        else
            # Add the line at the end if no result line exists
            echo "" >> "$script"
            echo "print \"[✓] Completed: $script_name - Found \$$vuln_var of $test_count vulnerabilities tested\"" >> "$script"
        fi
        
        # Clean up backup files
        rm -f "$script.bak"
        
        echo "✓ Updated $script_name (Tests: $test_count, Variable: \$$vuln_var)"
    fi
done

echo ""
echo "✓ All scripts updated with standardized completion messages!"