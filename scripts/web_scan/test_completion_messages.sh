#!/bin/bash

# Test that all scripts output the correct completion message format

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKS_DIR="$SCRIPT_DIR/checks"
HTTPDSL_CMD="$SCRIPT_DIR/../../httpdsl"

echo "Testing completion messages in vulnerability scripts..."
echo "================================================"

SUCCESS=0
FAIL=0

for script in "$CHECKS_DIR"/*.http; do
    script_name=$(basename "$script" .http)
    
    # Run the script and capture output
    output=$($HTTPDSL_CMD "$script" "http://example.com" 2>&1)
    
    # Check for completion message
    if echo "$output" | grep -q "\[✓\] Completed: $script_name.*Found.*of.*vulnerabilities tested"; then
        echo "✓ $script_name - Has correct completion message"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "✗ $script_name - Missing or incorrect completion message"
        FAIL=$((FAIL + 1))
        
        # Show what was found instead
        completion_line=$(echo "$output" | grep "\[✓\] Completed:" | tail -1)
        if [ -n "$completion_line" ]; then
            echo "  Found: $completion_line"
        else
            echo "  No completion message found"
        fi
    fi
done

echo ""
echo "================================================"
echo "Results: $SUCCESS passed, $FAIL failed"

if [ $FAIL -eq 0 ]; then
    echo "✅ All scripts have correct completion messages!"
else
    echo "❌ Some scripts need fixing"
fi