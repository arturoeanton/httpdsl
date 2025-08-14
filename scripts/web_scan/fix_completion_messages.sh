#!/bin/bash

# Fix completion messages in all vulnerability scripts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKS_DIR="$SCRIPT_DIR/checks"

echo "Fixing completion messages in all vulnerability scripts..."

# Define the test counts for each script (based on actual tests)
declare -A TEST_COUNTS=(
    ["0001_security_headers.http"]="7"
    ["0002_sensitive_files.http"]="15"
    ["0003_sql_injection.http"]="10"
    ["0004_xss.http"]="8"
    ["0005_cors.http"]="5"
    ["0006_open_redirect.http"]="6"
    ["0007_csrf.http"]="5"
    ["0008_auth_bypass.http"]="7"
    ["0009_xxe.http"]="5"
    ["0010_ssrf.http"]="6"
    ["0011_command_injection.http"]="7"
    ["0012_ldap_injection.http"]="5"
    ["0013_nosql_injection.http"]="6"
    ["0014_template_injection.http"]="6"
    ["0015_file_upload.http"]="6"
    ["0016_jwt.http"]="6"
    ["0017_xml_injection.http"]="5"
    ["0018_directory_traversal.http"]="7"
    ["0019_session_management.http"]="6"
    ["0020_api_security.http"]="7"
    ["0021_cache_poisoning.http"]="6"
    ["0022_http_smuggling.http"]="5"
    ["0023_websocket.http"]="5"
    ["0024_graphql.http"]="6"
    ["0025_subdomain_takeover.http"]="4"
    ["0026_clickjacking.http"]="6"
    ["0027_deserialization.http"]="6"
    ["0028_business_logic.http"]="7"
    ["0029_race_condition.http"]="5"
    ["0030_host_header.http"]="6"
    ["0031_oauth.http"]="6"
    ["0032_idor.http"]="6"
    ["0033_log4j.http"]="7"
    ["0034_verb_tampering.http"]="7"
    ["0035_ssl_tls.http"]="6"
    ["0036_information_disclosure.http"]="7"
)

# Fix the early scripts that have [RESULT] format
for script in "$CHECKS_DIR"/000{1..6}_*.http; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        base_name=$(basename "$script" .http)
        
        # Get test count
        test_count="${TEST_COUNTS[$script_name]:-10}"
        
        # Get variable name
        var_name=$(grep -o 'set \$[a-z_]* \$[a-z_]* + 1' "$script" | head -1 | awk '{print $2}' | tr -d '$')
        if [ -z "$var_name" ]; then
            var_name="issues"  # Default for early scripts
        fi
        
        # Check if already has correct format
        if grep -q "\[✓\] Completed:" "$script"; then
            echo "✓ $base_name already has correct format"
            continue
        fi
        
        # Replace [RESULT] line or add completion line
        if grep -q "print.*\[RESULT\]" "$script"; then
            # Replace existing [RESULT] line
            sed -i '' "s|print.*\[RESULT\].*|print \"[✓] Completed: $base_name - Found \$$var_name of $test_count vulnerabilities tested\"|" "$script"
            echo "✓ Fixed $base_name ([RESULT] replaced)"
        else
            # Add completion line at the end before the final endif
            # Count the number of endif statements to find the last one
            endif_count=$(grep -c "^endif" "$script")
            if [ $endif_count -gt 0 ]; then
                # Insert before the last endif
                sed -i '' "/^endif$/i\\
\\
print \"[✓] Completed: $base_name - Found \$$var_name of $test_count vulnerabilities tested\"
" "$script"
                echo "✓ Fixed $base_name (added before endif)"
            else
                # Just append at the end
                echo "" >> "$script"
                echo "print \"[✓] Completed: $base_name - Found \$$var_name of $test_count vulnerabilities tested\"" >> "$script"
                echo "✓ Fixed $base_name (appended)"
            fi
        fi
    fi
done

echo ""
echo "✓ All early scripts fixed with proper completion messages!"