#!/usr/bin/env bash
# Builds index.json from all agent definition files in agents/ and recruiter/
# Run from repo root: ./scripts/build-index.sh > index.json

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Convert YAML-style array [a, b, c] to JSON array ["a", "b", "c"]
yaml_arr_to_json() {
    local raw="$1"
    # Strip outer brackets, split on comma, quote each element
    raw="${raw#\[}"
    raw="${raw%\]}"
    local result="["
    local first=true
    IFS=',' read -ra items <<< "$raw"
    for item in "${items[@]}"; do
        item="$(echo "$item" | xargs)"  # trim whitespace
        if [ "$first" = true ]; then
            first=false
        else
            result+=", "
        fi
        result+="\"$item\""
    done
    result+="]"
    echo "$result"
}

extract_field() {
    local file="$1" field="$2"
    awk -v f="$field" '/^---$/{n++; next} n==1 && $0 ~ "^"f":"{gsub("^"f": *", ""); print; exit}' "$file"
}

entries=()

for file in $(find "$REPO_ROOT/agents" "$REPO_ROOT/recruiter" -name '*.md' -type f 2>/dev/null | sort); do
    name=$(extract_field "$file" "name")
    [ -z "$name" ] && continue

    display_name=$(extract_field "$file" "display_name")
    description=$(extract_field "$file" "description")
    domain=$(extract_field "$file" "domain")
    tags=$(extract_field "$file" "tags")
    model=$(extract_field "$file" "model")
    complexity=$(extract_field "$file" "complexity")
    compatible=$(extract_field "$file" "compatible_with")
    version=$(extract_field "$file" "version")

    relpath="${file#$REPO_ROOT/}"

    domain_json=$(yaml_arr_to_json "$domain")
    tags_json=$(yaml_arr_to_json "$tags")
    compatible_json=$(yaml_arr_to_json "$compatible")

    entries+=("$(cat <<ENTRY
  {
    "name": "$name",
    "display_name": "$display_name",
    "description": "$description",
    "domain": $domain_json,
    "tags": $tags_json,
    "model": "$model",
    "complexity": "$complexity",
    "compatible_with": $compatible_json,
    "version": "${version:-1.0.0}",
    "path": "$relpath"
  }
ENTRY
)")
done

# Join with commas
echo "["
for i in "${!entries[@]}"; do
    if [ "$i" -gt 0 ]; then
        echo ","
    fi
    echo "${entries[$i]}"
done
echo "]"
