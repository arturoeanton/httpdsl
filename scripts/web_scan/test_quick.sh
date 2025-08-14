#!/bin/bash

# Quick test with just a few scripts
cd /Users/arturoeliasanton/github.com/arturoeanton/httpdsl/scripts/web_scan

# Create temp directory with just 3 scripts for testing
TEMP_DIR="/tmp/test_scan_$$"
mkdir -p "$TEMP_DIR/checks"
cp checks/0001_security_headers.http "$TEMP_DIR/checks/"
cp checks/0002_sensitive_files.http "$TEMP_DIR/checks/"
cp checks/0003_sql_injection.http "$TEMP_DIR/checks/"

# Modify parallel script to use temp directory
cp scan_parallel.sh "$TEMP_DIR/scan_test.sh"
sed -i '' "s|CHECKS_DIR=.*|CHECKS_DIR=\"$TEMP_DIR/checks\"|" "$TEMP_DIR/scan_test.sh"

echo "Running test with 3 scripts..."
"$TEMP_DIR/scan_test.sh" "http://httpbin.org"

# Cleanup
rm -rf "$TEMP_DIR"