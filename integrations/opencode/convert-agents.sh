#!/usr/bin/env bash
#
# convert-agents.sh — Convert agent-roster agents to OpenCode format
#
# Converts Tech-Lead agent to primary role (mode: agent) for OpenCode.
# Other agents can be added here as subagents if needed in the future.
#
# Usage:
#   ./integrations/opencode/convert-agents.sh [--out <dir>]
#
# Output is written to integrations/opencode/agents/ by default.

set -euo pipefail

# --- Paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUT_DIR="$SCRIPT_DIR/agents"

# --- Usage ---
usage() {
	sed -n '3,10p' "$0" | sed 's/^# \{0,1\}//'
	exit 0
}

# --- Frontmatter helpers ---

# Extract a single field value from YAML frontmatter block.
get_field() {
	local field="$1" file="$2"
	awk -v f="$field" '
    /^---$/ { fm++; next }
    fm == 1 && $0 ~ "^" f ": " { sub("^" f ": ", ""); print; exit }
  ' "$file"
}

# Strip the leading frontmatter block and return only the body.
get_body() {
	awk 'BEGIN{fm=0} /^---$/{fm++; next} fm>=2{print}' "$1"
}

# Convert a human-readable agent name to a lowercase kebab-case slug.
slugify() {
	echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

# Map known color names and normalize to OpenCode-safe #RRGGBB values.
resolve_opencode_color() {
	local c="$1"

	c="$(printf '%s' "$c" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')"

	case "$c" in
	cyan) echo "#00FFFF" ;;
	blue) echo "#3498DB" ;;
	green) echo "#2ECC71" ;;
	red) echo "#E74C3C" ;;
	purple) echo "#9B59B6" ;;
	orange) echo "#F39C12" ;;
	teal) echo "#008080" ;;
	indigo) echo "#6366F1" ;;
	pink) echo "#E84393" ;;
	gold) echo "#EAB308" ;;
	amber) echo "#F59E0B" ;;
	neon-green) echo "#10B981" ;;
	neon-cyan) echo "#06B6D4" ;;
	metallic-blue) echo "#3B82F6" ;;
	yellow) echo "#EAB308" ;;
	violet) echo "#8B5CF6" ;;
	rose) echo "#F43F5E" ;;
	lime) echo "#84CC16" ;;
	gray) echo "#6B7280" ;;
	fuchsia) echo "#D946EF" ;;
	*)
		# If already hex format, use it; otherwise default to gray
		if [[ "$c" =~ ^#?[0-9a-fA-F]{6}$ ]]; then
			echo "#${c#\#}" | tr '[:lower:]' '[:upper:]'
		else
			echo "#6B7280"
		fi
		;;
	esac
}

# Convert agent to OpenCode format
convert_agent() {
	local file="$1"
	local mode="$2" # "agent" for primary, "subagent" for on-demand

	local name description color slug outfile body

	name="$(get_field "name" "$file")"
	display_name="$(get_field "display_name" "$file")"
	description="$(get_field "description" "$file")"
	color_raw="$(get_field "color" "$file")"

	# Default color to blue if not specified
	if [ -z "$color_raw" ]; then
		color_raw="blue"
	fi

	color="$(resolve_opencode_color "$color_raw")"
	slug="$(slugify "$name")"
	body="$(get_body "$file")"

	outfile="$OUT_DIR/${slug}.md"
	mkdir -p "$OUT_DIR"

	# Use display_name if available, otherwise use name
	if [ -z "$display_name" ]; then
		display_name="$name"
	fi

	cat >"$outfile" <<HEREDOC
---
name: ${display_name}
description: ${description}
mode: ${mode}
color: '${color}'
---
${body}
HEREDOC

	echo "✓ Converted: ${name} (${mode})"
}

# --- Main ---

main() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--out)
			OUT_DIR="${2:?'--out requires a value'}"
			shift 2
			;;
		--help | -h) usage ;;
		*)
			echo "Unknown option: $1" >&2
			usage
			;;
		esac
	done

	echo "Converting agent-roster agents to OpenCode format..."
	echo "Output: $OUT_DIR"
	echo ""

	# Convert Tech-Lead as PRIMARY agent (mode: agent)
	local tech_lead_file="$REPO_ROOT/agents/management/tech-lead.md"
	if [ -f "$tech_lead_file" ]; then
		convert_agent "$tech_lead_file" "agent"
	else
		echo "ERROR: Tech-Lead agent not found at $tech_lead_file" >&2
		exit 1
	fi

	# Future: Add more agents here as subagents if needed
	# Example:
	# convert_agent "$REPO_ROOT/agents/backend/implementer.md" "subagent"

	echo ""
	echo "✓ Done. OpenCode agents written to: $OUT_DIR"
	echo ""
	echo "To use in a project:"
	echo "  1. Add opencode runtime to .harness/harness.json"
	echo "  2. Run: ./scripts/sync-harness.sh /path/to/project"
	echo "  3. Tech-Lead will appear in OpenCode's main Tab-cycle"
}

main "$@"
