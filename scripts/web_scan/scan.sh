#!/bin/bash

# Web Security Scanner Orchestrator
# Usage: ./scan.sh <target_url> [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

PARALLEL_JOBS="${PARALLEL_JOBS:-5}"

echo -e "${GREEN}[✓] Using httpdsl: $HTTPDSL_CMD${NC}"

# Parse arguments
TARGET="$1"
MODE="${2:-full}"  # full or quick
REPORT_FORMAT="${3:-text}"  # text, json, or html

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target_url> [full|quick] [text|json|html]"
    echo ""
    echo "Examples:"
    echo "  $0 https://example.com"
    echo "  $0 https://example.com quick"
    echo "  $0 https://example.com full json"
    exit 1
fi

# Create reports directory
mkdir -p "$REPORTS_DIR"

# Generate timestamp and report filename
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DOMAIN=$(echo "$TARGET" | sed -e 's|https\?://||' -e 's|/.*||')
REPORT_BASE="$REPORTS_DIR/${DOMAIN}_${TIMESTAMP}"
REPORT_FILE="${REPORT_BASE}.txt"
JSON_FILE="${REPORT_BASE}.json"

# Print banner
echo "╔══════════════════════════════════════════════════════════╗"
echo "║           WEB SECURITY SCANNER - MODULAR                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}[*] Target:${NC} $TARGET"
echo -e "${BLUE}[*] Mode:${NC} $MODE"
echo -e "${BLUE}[*] Report:${NC} $REPORT_FILE"
echo ""

# Initialize counters
TOTAL_CHECKS=0
CRITICAL_COUNT=0
HIGH_COUNT=0
MEDIUM_COUNT=0
LOW_COUNT=0

# Start report
{
    echo "════════════════════════════════════════════════════════════"
    echo "WEB SECURITY SCAN REPORT"
    echo "════════════════════════════════════════════════════════════"
    echo "Target: $TARGET"
    echo "Date: $(date)"
    echo "Mode: $MODE"
    echo ""
} > "$REPORT_FILE"

# Function to run a check
run_check() {
    local check_file="$1"
    local check_name=$(basename "$check_file" .http)
    local temp_output="/tmp/scan_${check_name}_$$.txt"
    
    echo -e "${BLUE}[*] Running:${NC} $check_name"
    
    # Run the check and capture output
    if $HTTPDSL_CMD "$check_file" "$TARGET" > "$temp_output" 2>&1; then
        # Parse results
        local critical=$(grep -c "\[CRITICAL\]" "$temp_output" || true)
        local high=$(grep -c "\[HIGH\]" "$temp_output" || true)
        local medium=$(grep -c "\[MEDIUM\]" "$temp_output" || true)
        local low=$(grep -c "\[LOW\]" "$temp_output" || true)
        
        # Update global counters
        CRITICAL_COUNT=$((CRITICAL_COUNT + critical))
        HIGH_COUNT=$((HIGH_COUNT + high))
        MEDIUM_COUNT=$((MEDIUM_COUNT + medium))
        LOW_COUNT=$((LOW_COUNT + low))
        
        # Add to report
        {
            echo "────────────────────────────────────────────────────────────"
            echo "CHECK: $check_name"
            echo "────────────────────────────────────────────────────────────"
            cat "$temp_output"
            echo ""
        } >> "$REPORT_FILE"
        
        # Show summary
        if [ $critical -gt 0 ]; then
            echo -e "  ${RED}✗ Found $critical CRITICAL issues${NC}"
        fi
        if [ $high -gt 0 ]; then
            echo -e "  ${YELLOW}✗ Found $high HIGH issues${NC}"
        fi
        if [ $medium -gt 0 ]; then
            echo -e "  ${YELLOW}⚠ Found $medium MEDIUM issues${NC}"
        fi
        if [ $((critical + high + medium + low)) -eq 0 ]; then
            echo -e "  ${GREEN}✓ No issues found${NC}"
        fi
    else
        echo -e "  ${RED}✗ Check failed${NC}"
    fi
    
    rm -f "$temp_output"
}

# Select checks based on mode
if [ "$MODE" = "quick" ]; then
    CHECKS=(
        "0001_security_headers.http"
        "0002_sensitive_files.http"
        "0003_sql_injection.http"
        "0004_xss.http"
    )
else
    # Full mode - all checks
    CHECKS=($(ls "$CHECKS_DIR"/*.http 2>/dev/null | xargs -n1 basename))
fi

# Run checks (can be parallelized with GNU parallel if available)
echo -e "\n${BLUE}[*] Starting security checks...${NC}\n"

for check in "${CHECKS[@]}"; do
    if [ -f "$CHECKS_DIR/$check" ]; then
        run_check "$CHECKS_DIR/$check"
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
done

# Generate summary
{
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "SUMMARY"
    echo "════════════════════════════════════════════════════════════"
    echo "Total Checks: $TOTAL_CHECKS"
    echo ""
    echo "Vulnerabilities Found:"
    echo "  CRITICAL: $CRITICAL_COUNT"
    echo "  HIGH:     $HIGH_COUNT"
    echo "  MEDIUM:   $MEDIUM_COUNT"
    echo "  LOW:      $LOW_COUNT"
    echo ""
    
    # Risk score
    RISK_SCORE=$((CRITICAL_COUNT * 50 + HIGH_COUNT * 20 + MEDIUM_COUNT * 5 + LOW_COUNT * 1))
    echo "Risk Score: $RISK_SCORE"
    
    if [ $RISK_SCORE -ge 100 ]; then
        echo "Risk Level: CRITICAL - Immediate action required!"
    elif [ $RISK_SCORE -ge 50 ]; then
        echo "Risk Level: HIGH - Urgent remediation needed"
    elif [ $RISK_SCORE -ge 20 ]; then
        echo "Risk Level: MEDIUM - Schedule fixes"
    elif [ $RISK_SCORE -gt 0 ]; then
        echo "Risk Level: LOW - Minor issues"
    else
        echo "Risk Level: SECURE - No issues found"
    fi
    
    echo ""
    echo "Report saved to: $REPORT_FILE"
    echo "════════════════════════════════════════════════════════════"
} | tee -a "$REPORT_FILE"

# Generate JSON report if requested
if [ "$REPORT_FORMAT" = "json" ] || [ "$REPORT_FORMAT" = "all" ]; then
    cat > "$JSON_FILE" <<EOF
{
    "target": "$TARGET",
    "timestamp": "$(date -Iseconds)",
    "mode": "$MODE",
    "summary": {
        "total_checks": $TOTAL_CHECKS,
        "critical": $CRITICAL_COUNT,
        "high": $HIGH_COUNT,
        "medium": $MEDIUM_COUNT,
        "low": $LOW_COUNT,
        "risk_score": $RISK_SCORE
    }
}
EOF
    echo -e "\n${GREEN}[✓] JSON report saved to: $JSON_FILE${NC}"
fi

# Show final summary
echo ""
if [ $CRITICAL_COUNT -gt 0 ]; then
    echo -e "${RED}[!] Found $CRITICAL_COUNT CRITICAL vulnerabilities!${NC}"
elif [ $HIGH_COUNT -gt 0 ]; then
    echo -e "${YELLOW}[!] Found $HIGH_COUNT HIGH severity issues${NC}"
elif [ $MEDIUM_COUNT -gt 0 ]; then
    echo -e "${YELLOW}[⚠] Found $MEDIUM_COUNT MEDIUM severity issues${NC}"
else
    echo -e "${GREEN}[✓] No significant vulnerabilities found${NC}"
fi

echo -e "\n${GREEN}[✓] Scan completed successfully!${NC}"
echo -e "${BLUE}[*] Full report: $REPORT_FILE${NC}"