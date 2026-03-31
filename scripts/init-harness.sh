#!/usr/bin/env bash
# Initialize a canonical .harness tree for a target project using roster defaults,
# then project it into runtime-specific files.
# Usage: ./scripts/init-harness.sh <project-root> [profile]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="${1:-}"
PROFILE="${2:-developer}"

if [ -z "$PROJECT_ROOT" ]; then
    echo "Usage: ./scripts/init-harness.sh <project-root> [profile]" >&2
    exit 1
fi

case "$PROFILE" in
    core|developer|security|full) ;;
    *)
        echo "Unsupported profile: $PROFILE" >&2
        exit 1
        ;;
esac

HARNESS_DIR="$PROJECT_ROOT/.harness"
AGENTS_DIR="$HARNESS_DIR/agents"
SKILLS_DIR="$HARNESS_DIR/skills"
RULES_DIR="$HARNESS_DIR/rules"
HOOKS_DIR="$HARNESS_DIR/hooks"
MANIFEST="$HARNESS_DIR/harness.json"

mkdir -p "$AGENTS_DIR" "$SKILLS_DIR" "$RULES_DIR" "$HOOKS_DIR"

copy_files() {
    local target_dir="$1"
    shift
    local rel
    for rel in "$@"; do
        cp "$REPO_ROOT/$rel" "$target_dir/$(basename "$rel")"
    done
}

CORE_AGENTS=(
    "agents/management/tech-lead.md"
    "agents/testing/reviewer.md"
)

DEVELOPER_AGENTS=(
    "agents/backend/implementer.md"
    "agents/testing/qa.md"
    "agents/management/architect.md"
    "agents/management/kb-agent.md"
)

SECURITY_AGENTS=(
    "agents/security/mcp-vetter.md"
)

FULL_EXTRA_AGENTS=(
    "recruiter/recruiter.md"
    "agents/management/harness-builder.md"
    "agents/management/context-manager.md"
    "agents/management/error-coordinator.md"
    "agents/management/skill-creator.md"
    "agents/devops/tool-provisioner.md"
    "agents/devops/performance-monitor.md"
    "agents/specialist/expert-debugger.md"
    "agents/specialist/config-migrator.md"
)

CORE_RULES=(
    "rules/safety/sycophancy.md"
    "rules/safety/escalation.md"
    "rules/common/code-quality.md"
)

CORE_HOOKS=(
    "hooks/safety/block-dangerous-commands.md"
)

DEVELOPER_HOOKS=(
    "hooks/quality/post-edit-lint.md"
)

DEVELOPER_SKILLS=(
    "skills/testing/tdd-workflow.md"
    "skills/kb/kb-update.md"
    "skills/workflow/git-conventions.md"
)

FULL_EXTRA_SKILLS=(
    "skills/kb/ambiguity-auditor.md"
    "skills/kb/code-quality-auditor.md"
    "skills/kb/spec-compliance-auditor.md"
    "skills/kb/harness-validator.md"
)

find "$AGENTS_DIR" -maxdepth 1 -type f -name '*.md' -delete
find "$SKILLS_DIR" -maxdepth 1 -type f -name '*.md' -delete
find "$RULES_DIR" -maxdepth 1 -type f -name '*.md' -delete
find "$HOOKS_DIR" -maxdepth 1 -type f -name '*.md' -delete

copy_files "$AGENTS_DIR" "${CORE_AGENTS[@]}"
copy_files "$RULES_DIR" "${CORE_RULES[@]}"
copy_files "$HOOKS_DIR" "${CORE_HOOKS[@]}"

if [[ "$PROFILE" == "developer" || "$PROFILE" == "security" || "$PROFILE" == "full" ]]; then
    copy_files "$AGENTS_DIR" "${DEVELOPER_AGENTS[@]}"
    copy_files "$SKILLS_DIR" "${DEVELOPER_SKILLS[@]}"
    copy_files "$HOOKS_DIR" "${DEVELOPER_HOOKS[@]}"
fi

if [[ "$PROFILE" == "security" || "$PROFILE" == "full" ]]; then
    copy_files "$AGENTS_DIR" "${SECURITY_AGENTS[@]}"
fi

if [[ "$PROFILE" == "full" ]]; then
    copy_files "$AGENTS_DIR" "${FULL_EXTRA_AGENTS[@]}"
    copy_files "$SKILLS_DIR" "${FULL_EXTRA_SKILLS[@]}"
fi

project_name="$(basename "$PROJECT_ROOT")"

extract_field() {
    local file="$1"
    local field="$2"
    awk -v f="$field" '
        /^---$/ {n++; next}
        n == 1 && $0 ~ "^" f ":" {
            sub("^" f ": *", "")
            print
            exit
        }
    ' "$file"
}

list_layer_json() {
    local dir="$1"
    local kind="$2"
    local file name version description scope category event matcher first

    printf '['
    first=true

    while IFS= read -r file; do
        [ -n "$file" ] || continue
        name="$(extract_field "$file" "name")"
        [ -n "$name" ] || name="$(basename "$file" .md)"

        if [ "$first" = true ]; then
            first=false
        else
            printf ','
        fi

        case "$kind" in
            agents)
                version="$(extract_field "$file" "version")"
                description="$(extract_field "$file" "description")"
                jq -nc \
                  --arg name "$name" \
                  --arg version "${version:-local}" \
                  --arg role "${description:-Installed from roster profile}" \
                  '{
                    name: $name,
                    source: "roster",
                    version: $version,
                    role: $role,
                    tunables: {}
                  }'
                ;;
            skills)
                version="$(extract_field "$file" "version")"
                jq -nc \
                  --arg name "$name" \
                  --arg version "${version:-local}" \
                  '{
                    name: $name,
                    source: "roster",
                    version: $version
                  }'
                ;;
            rules)
                scope="$(extract_field "$file" "scope")"
                category="$(extract_field "$file" "category")"
                jq -nc \
                  --arg name "$name" \
                  --arg scope "${scope:-global}" \
                  --arg category "${category:-unknown}" \
                  '{
                    name: $name,
                    source: "roster",
                    scope: $scope,
                    category: $category
                  }'
                ;;
            hooks)
                event="$(extract_field "$file" "event")"
                matcher="$(extract_field "$file" "matcher")"
                jq -nc \
                  --arg name "$name" \
                  --arg event "${event:-unknown}" \
                  --arg matcher "${matcher:-}" \
                  '{
                    name: $name,
                    event: $event,
                    matcher: (if $matcher == "" then null else $matcher end),
                    source: "roster"
                  }'
                ;;
        esac
    done < <(find "$dir" -maxdepth 1 -type f -name '*.md' | sort)

    printf ']'
}

agents_json="$(list_layer_json "$AGENTS_DIR" agents)"
skills_json="$(list_layer_json "$SKILLS_DIR" skills)"
rules_json="$(list_layer_json "$RULES_DIR" rules)"
hooks_json="$(list_layer_json "$HOOKS_DIR" hooks)"

jq -n \
  --arg profile "$PROFILE" \
  --arg project_name "$project_name" \
  --argjson agents "$agents_json" \
  --argjson skills "$skills_json" \
  --argjson rules "$rules_json" \
  --argjson hooks "$hooks_json" \
  '{
    version: "1.0.0",
    profile: $profile,
    source_of_truth: ".harness",
    runtimes: [
      {name: "claude-code", enabled: true, entrypoint: ".claude/"},
      {name: "codex", enabled: true, entrypoint: ".agents/skills/"}
    ],
    project: {
      name: $project_name,
      languages: [],
      frameworks: [],
      ci: null,
      issue_tracker: null
    },
    layers: {
      agents: $agents,
      rules: $rules,
      hooks: $hooks,
      skills: $skills,
      mcp: [],
      kb: {
        structure: (if $profile == "full" then "standard" else "minimal" end),
        bootstrapped: false,
        last_audit: null,
        auditors: []
      }
    }
  }' > "$MANIFEST"

"$REPO_ROOT/scripts/sync-harness.sh" "$PROJECT_ROOT"

printf 'Initialized shared harness in %s with profile %s\n' "$PROJECT_ROOT" "$PROFILE"
