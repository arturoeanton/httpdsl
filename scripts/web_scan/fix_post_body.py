#!/usr/bin/env python3

import os
import re
import glob

# Directory with the scripts
checks_dir = "/Users/arturoeliasanton/github.com/arturoeanton/httpdsl/scripts/web_scan/checks"

# Process all .http files
for script_path in glob.glob(f"{checks_dir}/*.http"):
    print(f"Processing {script_path}")
    
    with open(script_path, 'r') as f:
        content = f.read()
    
    # Pattern to match POST with body on separate line
    # POST "url"
    # header "..."
    # body "..."
    pattern = re.compile(
        r'^POST\s+([^\r\n]+)\n\s+header\s+([^\r\n]+)\n\s+body\s+([^\r\n]+)',
        re.MULTILINE
    )
    
    def replacement(match):
        url = match.group(1).strip()
        header_line = match.group(2).strip()
        body_line = match.group(3).strip()
        return f'POST {url} body {body_line}\n    header {header_line}'
    
    # Apply the transformation
    new_content = pattern.sub(replacement, content)
    
    # Also handle simple POST + body without headers
    simple_pattern = re.compile(
        r'^POST\s+([^\r\n]+)\n\s+body\s+([^\r\n]+)',
        re.MULTILINE
    )
    
    def simple_replacement(match):
        url = match.group(1).strip()
        body_line = match.group(2).strip()
        return f'POST {url} body {body_line}'
    
    new_content = simple_pattern.sub(simple_replacement, new_content)
    
    # Write back if changed
    if new_content != content:
        with open(script_path, 'w') as f:
            f.write(new_content)
        print(f"  Fixed {script_path}")

print("POST/body separation fixes completed.")