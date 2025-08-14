#!/bin/bash

# Test script to verify parallel execution waits for all scripts

echo "Testing parallel scanner wait functionality..."

# Create a temporary test directory
TEST_DIR="/tmp/test_parallel_$$"
mkdir -p "$TEST_DIR/checks"

# Create test scripts with different execution times
cat > "$TEST_DIR/checks/test1.http" << 'EOF'
print "[SCAN] Test Script 1"
print "Testing..."
print "[✓] Completed: test1 - Found 2 of 5 vulnerabilities tested"
EOF

cat > "$TEST_DIR/checks/test2.http" << 'EOF'
print "[SCAN] Test Script 2"
print "Testing..."
print "[✓] Completed: test2 - Found 1 of 3 vulnerabilities tested"
EOF

cat > "$TEST_DIR/checks/test3.http" << 'EOF'
print "[SCAN] Test Script 3"
print "Testing..."
print "[✓] Completed: test3 - Found 0 of 4 vulnerabilities tested"
EOF

# Run our parallel scanner on the test scripts
echo "Running parallel scanner on test scripts..."
export CHECKS_DIR="$TEST_DIR/checks"

# Copy the parallel script and modify to use test directory
cp /Users/arturoeliasanton/github.com/arturoeanton/httpdsl/scripts/web_scan/scan_parallel.sh "$TEST_DIR/scan_test.sh"
sed -i '' "s|CHECKS_DIR=.*|CHECKS_DIR=\"$TEST_DIR/checks\"|" "$TEST_DIR/scan_test.sh"

# Run the test
"$TEST_DIR/scan_test.sh" "http://localhost" 2>&1 | tee "$TEST_DIR/output.log"

echo ""
echo "Test completed. Checking results..."

# Verify all completion messages appear
if grep -q "test1 - Found 2 of 5" "$TEST_DIR/output.log"; then
    echo "✓ Test 1 completion message found"
else
    echo "✗ Test 1 completion message NOT found"
fi

if grep -q "test2 - Found 1 of 3" "$TEST_DIR/output.log"; then
    echo "✓ Test 2 completion message found"
else
    echo "✗ Test 2 completion message NOT found"
fi

if grep -q "test3 - Found 0 of 4" "$TEST_DIR/output.log"; then
    echo "✓ Test 3 completion message found"
else
    echo "✗ Test 3 completion message NOT found"
fi

if grep -q "All 3 checks have completed" "$TEST_DIR/output.log"; then
    echo "✓ Final completion message found"
else
    echo "✗ Final completion message NOT found"
fi

# Cleanup
rm -rf "$TEST_DIR"

echo ""
echo "Test finished!"