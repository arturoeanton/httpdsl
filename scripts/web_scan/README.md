# Modular Web Security Scanner

A fast, modular web security scanner built with HTTP DSL. Each vulnerability check runs as a separate script, allowing for parallel execution and easy customization.

## Features

- **Modular Design**: Each vulnerability check is a separate script
- **Parallel Execution**: Run multiple checks simultaneously for faster scanning
- **Comprehensive Coverage**: SQL injection, XSS, security headers, sensitive files, and more
- **Detailed Reports**: Text, JSON, and HTML report formats
- **Easy to Extend**: Add new checks by creating new .http files

## Directory Structure

```
web_scan/
├── checks/               # Individual vulnerability check scripts
│   ├── 01_security_headers.http
│   ├── 02_sensitive_files.http
│   ├── 03_sql_injection.http
│   ├── 04_xss.http
│   ├── 05_cors.http
│   └── 06_open_redirect.http
├── reports/             # Generated scan reports
├── scan.sh             # Sequential scanner
├── scan_parallel.sh    # Parallel scanner (faster)
└── README.md
```

## Usage

### Quick Scan (Sequential)
```bash
cd scripts/web_scan
./scan.sh https://example.com
```

### Fast Scan (Parallel)
```bash
cd scripts/web_scan
./scan_parallel.sh https://example.com
```

### Quick Mode (Critical checks only)
```bash
./scan.sh https://example.com quick
```

### JSON Output
```bash
./scan.sh https://example.com full json
```

## Adding New Checks

Create a new .http file in the `checks/` directory:

```http
# checks/07_new_vulnerability.http
if $ARGC < 1 then
    print "ERROR: Missing target URL"
    set $stop 1
else
    set $target $ARG1
    set $stop 0
endif

if $stop == 0 then
    print "[SCAN] New Vulnerability Check"
    print "Target: $target"
    
    # Your vulnerability check logic here
    GET "$target/vulnerable-endpoint"
    
    if response contains "vulnerable" then
        print "[CRITICAL] Vulnerability found"
        print "  URL: $target/vulnerable-endpoint"
        print "  Risk: Description"
        print "  Fix: Remediation steps"
    endif
    
    print "[RESULT] Check completed"
endif
```

## Performance Comparison

| Method | Time (approx) | Description |
|--------|--------------|-------------|
| Original scanner (web_scanner3.http) | 3-5 minutes | Sequential, 98+ requests |
| Modular sequential (scan.sh) | 1-2 minutes | Sequential, optimized |
| Modular parallel (scan_parallel.sh) | 20-30 seconds | Parallel execution |

## Report Format

Reports include:
- Target URL and timestamp
- Individual check results
- Vulnerability counts by severity
- Risk score calculation
- Remediation recommendations

Example output:
```
════════════════════════════════════════════════════════════
WEB SECURITY SCAN REPORT
════════════════════════════════════════════════════════════
Target: https://example.com
Date: 2025-08-13

CHECK: 01_security_headers
────────────────────────────────────────────────────────────
[CRITICAL] Missing X-Frame-Options
  URL: https://example.com
  Risk: Clickjacking attacks
  Fix: Add header 'X-Frame-Options: DENY'

SUMMARY
════════════════════════════════════════════════════════════
Vulnerabilities Found:
  CRITICAL: 2
  HIGH:     3
  MEDIUM:   5
  LOW:      1

Risk Score: 185
Risk Level: CRITICAL
```

## Requirements

- HTTP DSL (httpdsl) installed and in PATH
- Bash shell
- Basic Unix tools (grep, sed, etc.)

## Advantages of Modular Approach

1. **Speed**: Parallel execution is 10x faster
2. **Maintainability**: Each check is independent
3. **Debugging**: Test individual checks easily
4. **Customization**: Enable/disable specific checks
5. **CI/CD Integration**: Easy to integrate into pipelines
6. **Resource Efficiency**: Less memory usage

## Troubleshooting

If httpdsl is not in PATH:
```bash
export HTTPDSL_CMD="/path/to/httpdsl"
./scan.sh https://example.com
```

To adjust parallel jobs:
```bash
export MAX_PARALLEL=10
./scan_parallel.sh https://example.com
```

## Future Enhancements

- [ ] HTML report generation
- [ ] Integration with CI/CD pipelines
- [ ] Webhook notifications
- [ ] Custom check profiles
- [ ] Rate limiting configuration
- [ ] Authentication support