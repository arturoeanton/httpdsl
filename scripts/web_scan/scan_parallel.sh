#!/bin/bash

# Web Security Scanner - Parallel Version
# Uses background jobs for faster scanning
# Usage: ./scan_parallel.sh <target_url>

set -e

# Trap to kill all background jobs on script exit
trap "echo 'Interrupted. Killing background jobs...'; jobs -p | xargs -r kill 2>/dev/null; exit 1" INT TERM

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKS_DIR="$SCRIPT_DIR/checks"
REPORTS_DIR="$SCRIPT_DIR/reports"

# Try to find httpdsl command
if [ -n "$HTTPDSL_CMD" ]; then
    # Use environment variable if set
    HTTPDSL_CMD="$HTTPDSL_CMD"
elif [ -f "../../httpdsl" ]; then
    # Use local build if exists
    HTTPDSL_CMD="../../httpdsl"
elif [ -f "./httpdsl" ]; then
    # Check current directory
    HTTPDSL_CMD="./httpdsl"
elif command -v httpdsl &> /dev/null; then
    # Use system httpdsl if in PATH
    HTTPDSL_CMD="httpdsl"
else
    echo "Error: httpdsl not found!"
    echo "Please build it first: go build -o httpdsl ./cmd/httpdsl/main.go"
    echo "Or set HTTPDSL_CMD environment variable"
    exit 1
fi

MAX_PARALLEL="${MAX_PARALLEL:-5}"

echo -e "${GREEN}[✓] Using httpdsl: $HTTPDSL_CMD${NC}"

# Parse arguments
TARGET="$1"
if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target_url>"
    exit 1
fi

# Setup
mkdir -p "$REPORTS_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DOMAIN=$(echo "$TARGET" | sed -e 's|https\?://||' -e 's|/.*||')
REPORT_DIR="$REPORTS_DIR/${DOMAIN}_${TIMESTAMP}"
mkdir -p "$REPORT_DIR"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║        WEB SECURITY SCANNER - PARALLEL EXECUTION          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}[*] Target:${NC} $TARGET"
echo -e "${BLUE}[*] Max Parallel:${NC} $MAX_PARALLEL"
echo -e "${BLUE}[*] Report Dir:${NC} $REPORT_DIR"
echo ""

# Track PIDs for better job management
declare -a JOB_PIDS=()

# Function to run check in background
run_check_async() {
    local check_file="$1"
    local check_name=$(basename "$check_file" .http)
    local output_file="$REPORT_DIR/${check_name}.txt"
    
    (
        echo -e "${BLUE}[>] Starting:${NC} $check_name"
        # Run the script and capture output to file
        if $HTTPDSL_CMD "$check_file" "$TARGET" > "$output_file" 2>&1; then
            # Script succeeded - extract and display the completion message
            local completion_msg=$(grep "^\[✓\] Completed:" "$output_file" 2>/dev/null | tail -1)
            if [ -n "$completion_msg" ]; then
                # Display the full completion message from the script
                echo -e "${GREEN}$completion_msg${NC}"
            else
                # Fallback if no completion message found
                echo -e "${GREEN}[✓] Completed:${NC} $check_name (no detailed message)"
            fi
        else
            # Script failed
            echo -e "${RED}[✗] Failed:${NC} $check_name"
            # Show first error from output
            local error_msg=$(grep -E "Error:|ERROR:|Failed:" "$output_file" 2>/dev/null | head -1)
            if [ -n "$error_msg" ]; then
                echo -e "${RED}  └─ $error_msg${NC}"
            fi
        fi
    ) &
    
    # Track the PID
    JOB_PIDS+=($!)
}

# Start all checks with job control
echo -e "${BLUE}[*] Launching security checks...${NC}\n"

job_count=0
for check_file in "$CHECKS_DIR"/*.http; do
    if [ -f "$check_file" ]; then
        # Wait if we've reached max parallel jobs
        while [ $(jobs -r | wc -l) -ge $MAX_PARALLEL ]; do
            sleep 0.5
        done
        
        run_check_async "$check_file"
        job_count=$((job_count + 1))
    fi
done

echo -e "\n${BLUE}[*] Waiting for $job_count checks to complete...${NC}"
echo -e "${YELLOW}[*] You will see completion messages as each script finishes${NC}\n"

# Monitor all tracked PIDs
completed=0
while [ $completed -lt $job_count ]; do
    still_running=0
    for pid in "${JOB_PIDS[@]}"; do
        if kill -0 $pid 2>/dev/null; then
            still_running=$((still_running + 1))
        fi
    done
    
    # Update completed count
    new_completed=$((job_count - still_running))
    if [ $new_completed -ne $completed ]; then
        completed=$new_completed
        echo -e "${YELLOW}[*] Progress: $completed/$job_count completed, $still_running still running...${NC}"
    fi
    
    # Break if all completed
    if [ $still_running -eq 0 ]; then
        break
    fi
    
    sleep 1
done

# Final wait to ensure all background jobs are truly done
wait
echo -e "\n${GREEN}[✓] All $job_count checks have completed!${NC}"

# Combine results
echo -e "\n${BLUE}[*] All checks completed. Generating combined report...${NC}"

FINAL_REPORT="$REPORT_DIR/FULL_REPORT.txt"
{
    echo "════════════════════════════════════════════════════════════"
    echo "WEB SECURITY SCAN REPORT - PARALLEL EXECUTION"
    echo "════════════════════════════════════════════════════════════"
    echo "Target: $TARGET"
    echo "Date: $(date)"
    echo "Checks: $job_count"
    echo ""
} > "$FINAL_REPORT"

# Parse and combine results
CRITICAL_COUNT=0
HIGH_COUNT=0
MEDIUM_COUNT=0
LOW_COUNT=0

for result_file in "$REPORT_DIR"/*.txt; do
    if [ "$result_file" != "$FINAL_REPORT" ]; then
        check_name=$(basename "$result_file" .txt)
        
        # Count issues
        critical=$(grep -c "\[CRITICAL\]" "$result_file" || true)
        high=$(grep -c "\[HIGH\]" "$result_file" || true)
        medium=$(grep -c "\[MEDIUM\]" "$result_file" || true)
        low=$(grep -c "\[LOW\]" "$result_file" || true)
        
        CRITICAL_COUNT=$((CRITICAL_COUNT + critical))
        HIGH_COUNT=$((HIGH_COUNT + high))
        MEDIUM_COUNT=$((MEDIUM_COUNT + medium))
        LOW_COUNT=$((LOW_COUNT + low))
        
        # Add to report
        {
            echo "────────────────────────────────────────────────────────────"
            echo "CHECK: $check_name"
            echo "────────────────────────────────────────────────────────────"
            cat "$result_file"
            echo ""
        } >> "$FINAL_REPORT"
    fi
done

# Add summary
{
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "SUMMARY"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "Vulnerabilities Found:"
    echo "  CRITICAL: $CRITICAL_COUNT"
    echo "  HIGH:     $HIGH_COUNT"
    echo "  MEDIUM:   $MEDIUM_COUNT"
    echo "  LOW:      $LOW_COUNT"
    echo ""
    
    RISK_SCORE=$((CRITICAL_COUNT * 50 + HIGH_COUNT * 20 + MEDIUM_COUNT * 5 + LOW_COUNT * 1))
    echo "Risk Score: $RISK_SCORE"
    
    if [ $RISK_SCORE -ge 100 ]; then
        echo "Risk Level: CRITICAL"
    elif [ $RISK_SCORE -ge 50 ]; then
        echo "Risk Level: HIGH"
    elif [ $RISK_SCORE -ge 20 ]; then
        echo "Risk Level: MEDIUM"
    elif [ $RISK_SCORE -gt 0 ]; then
        echo "Risk Level: LOW"
    else
        echo "Risk Level: SECURE"
    fi
} >> "$FINAL_REPORT"

# Display summary
tail -n 20 "$FINAL_REPORT"

echo ""
echo -e "${GREEN}[✓] Scan completed in parallel!${NC}"
echo -e "${BLUE}[*] Full report: $FINAL_REPORT${NC}"
echo -e "${BLUE}[*] Individual results: $REPORT_DIR/*.txt${NC}"