#!/usr/bin/env bash
# Search agents by keyword across name, description, domain, and tags.
# Usage: ./scripts/search.sh <query> [--domain <domain>] [--tag <tag>]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INDEX="$REPO_ROOT/index.json"

if [ ! -f "$INDEX" ]; then
    echo "Index not found. Run npm run build:index first." >&2
    exit 1
fi

QUERY="${1:-}"
DOMAIN_FILTER=""
TAG_FILTER=""

shift || true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --domain) DOMAIN_FILTER="$2"; shift 2 ;;
        --tag)    TAG_FILTER="$2"; shift 2 ;;
        *)        shift ;;
    esac
done

if [ -z "$QUERY" ] && [ -z "$DOMAIN_FILTER" ] && [ -z "$TAG_FILTER" ]; then
    echo "Usage: search.sh <query> [--domain <domain>] [--tag <tag>]" >&2
    exit 1
fi

# Use jq for filtering
jq_filter="."

if [ -n "$QUERY" ]; then
    jq_filter="$jq_filter | map(select(.name + .display_name + .description + (.tags | join(\" \")) | test(\"$QUERY\"; \"i\")))"
fi

if [ -n "$DOMAIN_FILTER" ]; then
    jq_filter="$jq_filter | map(select(.domain | map(test(\"$DOMAIN_FILTER\"; \"i\")) | any))"
fi

if [ -n "$TAG_FILTER" ]; then
    jq_filter="$jq_filter | map(select(.tags | map(test(\"$TAG_FILTER\"; \"i\")) | any))"
fi

jq -r "$jq_filter | .[] | \"\(.name)\t\(.description)\t\(.path)\"" "$INDEX" | column -t -s $'\t'
