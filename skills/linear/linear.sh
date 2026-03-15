#!/bin/bash

# Linear.app CLI wrapper for OpenClaw
# Usage: linear.sh <command> [options]

set -e

# Configuration
TEAM_ID="7275235f-4936-488e-8340-541bcd48700f"
API_ENDPOINT="https://api.linear.app/graphql"

# Get API key from macOS Keychain
get_api_key() {
    security find-generic-password -a "linear" -s "linear-api-key" -w 2>/dev/null || {
        echo "Error: Could not retrieve API key from keychain" >&2
        echo "Run: security add-generic-password -a 'linear' -s 'linear-api-key' -w '<your-api-key>'" >&2
        exit 1
    }
}

# Make GraphQL request
graphql_request() {
    local query="$1"
    local api_key=$(get_api_key)
    
    local escaped_query=$(echo "$query" | sed 's/"/\\"/g')
    local response=$(curl -s -H "Authorization: $api_key" \
                          -H "Content-Type: application/json" \
                          -d "{\"query\": \"$escaped_query\"}" \
                          "$API_ENDPOINT")
    
    # Check if response contains errors
    if echo "$response" | jq -e '.errors' > /dev/null 2>&1; then
        echo "$response" | jq -r '.errors[] | "Error: " + .message'
        return 1
    elif echo "$response" | jq -e '.data' > /dev/null 2>&1; then
        echo "$response"
        return 0
    else
        echo "Error: Invalid response from API"
        echo "$response" >&2
        return 1
    fi
}

# Status mapping functions (compatible with bash 3.2)
get_status_id() {
    case "$1" in
        "todo") echo "ee77dcde-b277-489e-9f23-805314ab2ad9" ;;
        "in-progress") echo "88f86b3d-485a-44ac-afa2-017a925be963" ;;
        "done") echo "26f161ca-5156-4a71-9506-d49930600ddf" ;;
        "cancelled") echo "58288463-6d7c-4341-b960-5aeea91c2c82" ;;
        "backlog") echo "63bbcb1d-99c3-4cf1-bfec-e598d5f21548" ;;
        *) echo "" ;;
    esac
}

get_status_names() {
    echo "todo in-progress done cancelled backlog"
}

# Priority mapping
get_priority() {
    case "$1" in
        "1") echo "1" ;;  # Urgent
        "2") echo "2" ;;  # High
        "3") echo "3" ;;  # Medium
        "4") echo "4" ;;  # Low
        *) echo "" ;;
    esac
}

# Label mapping
get_label_id() {
    local label=$(echo "$1" | tr '[:upper:]' '[:lower:]')  # Convert to lowercase
    case "$label" in
        "bug") echo "85df2d56-8ffd-4e90-a501-2e688348346a" ;;
        "feature") echo "a1529312-1e25-4371-8a93-f81d1a49d1ec" ;;
        "improvement") echo "adc62c76-cece-463e-8929-b49e08f0bb2d" ;;
        *) echo "" ;;
    esac
}

get_label_names() {
    echo "bug feature improvement"
}

# Project mapping
get_project_id() {
    local project=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$project" in
        "trading") echo "75f1286f-eb06-4bd0-96d8-8f3e6855184b" ;;
        "content") echo "9b07d8cc-428c-4a71-9a56-2b2677963c41" ;;
        "evolving-agent"|"evolving agent") echo "d8c875bb-cfd8-4086-9f01-5e56327a3cde" ;;
        *) echo "" ;;
    esac
}

# Format issue output
format_issue() {
    echo "$1" | jq -r '
        .data.issues.nodes[] // .data.issue // empty |
        "ID: " + .identifier +
        "\nTitle: " + .title +
        "\nStatus: " + .state.name +
        "\nPriority: " + (
            if .priority == 1 then "Urgent"
            elif .priority == 2 then "High" 
            elif .priority == 3 then "Medium"
            elif .priority == 4 then "Low"
            else "None" end
        ) +
        (if .assignee then "\nAssignee: " + .assignee.name else "" end) +
        (if .description and .description != "" then "\nDescription: " + .description else "" end) +
        (if .labels.nodes | length > 0 then "\nLabels: " + ([.labels.nodes[].name] | join(", ")) else "" end) +
        "\nURL: " + .url +
        "\n---"
    '
}

# Command: list
cmd_list() {
    local status_filter=""
    local limit=10
    local project_filter=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --status)
                status_filter="$2"
                shift 2
                ;;
            --limit)
                limit="$2"
                shift 2
                ;;
            --project)
                project_filter="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1" >&2
                exit 1
                ;;
        esac
    done
    
    local base_filter="team: {id: {eq: \"$TEAM_ID\"}}"
    if [[ -n "$status_filter" ]]; then
        local status_id=$(get_status_id "$status_filter")
        if [[ -z "$status_id" ]]; then
            echo "Error: Unknown status '$status_filter'. Available: $(get_status_names)" >&2
            exit 1
        fi
        base_filter="$base_filter, state: {id: {eq: \"$status_id\"}}"
    fi
    
    local query="{ issues(first: $limit, filter: {$base_filter}, orderBy: updatedAt) { nodes { identifier title description url priority state { name } assignee { name } labels { nodes { name } } } } }"
    
    local response=$(graphql_request "$query")
    
    if echo "$response" | grep -q "Error:"; then
        echo "$response" >&2
        exit 1
    fi
    
    local count=$(echo "$response" | jq -r '.data.issues.nodes | length')
    if [[ "$count" == "0" ]]; then
        echo "No issues found."
        return
    fi
    
    echo "Found $count issue(s):"
    echo ""
    format_issue "$response"
}

# Command: create
cmd_create() {
    local title="$1"
    if [[ -z "$title" ]]; then
        echo "Error: Title is required" >&2
        exit 1
    fi
    shift
    
    local description=""
    local priority=""
    local project=""
    local label=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --description)
                description="$2"
                shift 2
                ;;
            --priority)
                priority="$2"
                shift 2
                ;;
            --project)
                project="$2"
                shift 2
                ;;
            --label)
                label="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1" >&2
                exit 1
                ;;
        esac
    done
    
    # Build mutation
    local mutation="mutation { issueCreate(input: {"
    mutation+="teamId: \"$TEAM_ID\""
    mutation+=", title: \"$(echo "$title" | sed 's/"/\\"/g')\""
    
    if [[ -n "$description" ]]; then
        mutation+=", description: \"$(echo "$description" | sed 's/"/\\"/g')\""
    fi
    
    if [[ -n "$priority" ]]; then
        local priority_val=$(get_priority "$priority")
        if [[ -z "$priority_val" ]]; then
            echo "Error: Invalid priority '$priority'. Use 1-4 (1=Urgent, 2=High, 3=Medium, 4=Low)" >&2
            exit 1
        fi
        mutation+=", priority: $priority_val"
    fi
    
    if [[ -n "$label" ]]; then
        local label_id=$(get_label_id "$label")
        if [[ -z "$label_id" ]]; then
            echo "Error: Unknown label '$label'. Available: $(get_label_names)" >&2
            exit 1
        fi
        mutation+=", labelIds: [\"$label_id\"]"
    fi

    if [[ -n "$project" ]]; then
        local project_id=$(get_project_id "$project")
        if [[ -z "$project_id" ]]; then
            echo "Error: Unknown project '$project'. Available: trading, content, evolving-agent" >&2
            exit 1
        fi
        mutation+=", projectId: \"$project_id\""
    fi
    
    mutation+="}) { success issue { identifier title url } } }"
    
    local response=$(graphql_request "$mutation")
    
    if echo "$response" | grep -q "Error:"; then
        echo "$response" >&2
        exit 1
    fi
    
    local success=$(echo "$response" | jq -r '.data.issueCreate.success')
    if [[ "$success" == "true" ]]; then
        local identifier=$(echo "$response" | jq -r '.data.issueCreate.issue.identifier')
        local url=$(echo "$response" | jq -r '.data.issueCreate.issue.url')
        echo "✅ Created issue $identifier"
        echo "Title: $title"
        echo "URL: $url"
    else
        echo "❌ Failed to create issue" >&2
        echo "$response" >&2
        exit 1
    fi
}

# Command: update
cmd_update() {
    local issue_id="$1"
    if [[ -z "$issue_id" ]]; then
        echo "Error: Issue ID is required" >&2
        exit 1
    fi
    shift
    
    local status=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --status)
                status="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1" >&2
                exit 1
                ;;
        esac
    done
    
    if [[ -z "$status" ]]; then
        echo "Error: --status is required" >&2
        exit 1
    fi
    
    local status_id=$(get_status_id "$status")
    if [[ -z "$status_id" ]]; then
        echo "Error: Unknown status '$status'. Available: $(get_status_names)" >&2
        exit 1
    fi
    
    local mutation="mutation { issueUpdate(id: \"$issue_id\", input: {stateId: \"$status_id\"}) { success issue { identifier title state { name } } } }"
    
    local response=$(graphql_request "$mutation")
    
    if echo "$response" | grep -q "Error:"; then
        echo "$response" >&2
        exit 1
    fi
    
    local success=$(echo "$response" | jq -r '.data.issueUpdate.success')
    if [[ "$success" == "true" ]]; then
        local identifier=$(echo "$response" | jq -r '.data.issueUpdate.issue.identifier')
        local state_name=$(echo "$response" | jq -r '.data.issueUpdate.issue.state.name')
        echo "✅ Updated issue $identifier"
        echo "Status: $state_name"
    else
        echo "❌ Failed to update issue" >&2
        echo "$response" >&2
        exit 1
    fi
}

# Command: search
cmd_search() {
    local query="$1"
    if [[ -z "$query" ]]; then
        echo "Error: Search query is required" >&2
        exit 1
    fi
    
    local escaped_query=$(echo "$query" | sed 's/"/\\"/g')
    local graphql_query="{ issues(first: 10, filter: {team: {id: {eq: \"$TEAM_ID\"}}, title: {contains: \"$escaped_query\"}}, orderBy: updatedAt) { nodes { identifier title description url priority state { name } assignee { name } labels { nodes { name } } } } }"
    
    local response=$(graphql_request "$graphql_query")
    
    if echo "$response" | grep -q "Error:"; then
        echo "$response" >&2
        exit 1
    fi
    
    local count=$(echo "$response" | jq -r '.data.issues.nodes | length')
    if [[ "$count" == "0" ]]; then
        echo "No issues found for query: $query"
        return
    fi
    
    echo "Found $count issue(s) for query: $query"
    echo ""
    format_issue "$response"
}

# Command: projects  
cmd_projects() {
    local query="{ team(id: \"$TEAM_ID\") { projects { nodes { id name description } } } }"
    
    local response=$(graphql_request "$query")
    
    if echo "$response" | grep -q "Error:"; then
        echo "$response" >&2
        exit 1
    fi
    
    local count=$(echo "$response" | jq -r '.data.team.projects.nodes | length')
    if [[ "$count" == "0" ]]; then
        echo "No projects found."
        return
    fi
    
    echo "Projects:"
    echo "$response" | jq -r '
        .data.team.projects.nodes[] |
        "- " + .name + (if .description then " (" + .description + ")" else "" end)
    '
}

# Command: labels
cmd_labels() {
    local query="{ team(id: \"$TEAM_ID\") { labels { nodes { id name color } } } }"
    
    local response=$(graphql_request "$query")
    
    if echo "$response" | grep -q "Error:"; then
        echo "$response" >&2
        exit 1
    fi
    
    echo "Available labels:"
    echo "$response" | jq -r '
        .data.team.labels.nodes[] |
        "- " + .name + " (" + .color + ")"
    '
}

# Main command router
main() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  list [--status <status>] [--limit <n>] [--project <name>]"
        echo "  create <title> [--description <desc>] [--priority <1-4>] [--project <name>] [--label <label>]" 
        echo "  update <issue-id> --status <status>"
        echo "  search <query>"
        echo "  projects"
        echo "  labels"
        echo ""
        echo "Status options: $(get_status_names)"
        echo "Priority: 1=Urgent, 2=High, 3=Medium, 4=Low"
        exit 1
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        help|--help|-h)
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  list [--status <status>] [--limit <n>] [--project <name>]"
            echo "  create <title> [--description <desc>] [--priority <1-4>] [--project <name>] [--label <label>]"
            echo "  update <issue-id> --status <status>"
            echo "  search <query>"
            echo "  projects"
            echo "  labels"
            echo ""
            echo "Aliases: issues → list"
            echo "Status options: $(get_status_names)"
            echo "Priority: 1=Urgent, 2=High, 3=Medium, 4=Low"
            exit 0
            ;;
        list|issues)
            cmd_list "$@"
            ;;
        create)
            cmd_create "$@"
            ;;
        update)
            cmd_update "$@"
            ;;
        search)
            cmd_search "$@"
            ;;
        projects)
            cmd_projects "$@"
            ;;
        labels)
            cmd_labels "$@"
            ;;
        *)
            echo "Error: Unknown command '$command'" >&2
            exit 1
            ;;
    esac
}

main "$@"