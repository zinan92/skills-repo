# Linear Task Tracker Integration

OpenClaw skill for managing Linear issues via GraphQL API.

## Setup

API key must be stored in macOS Keychain:
```bash
security add-generic-password -a "linear" -s "linear-api-key" -w "your-api-key"
```

## Commands

### List Issues
```bash
linear.sh list [--status <status>] [--limit <n>] [--project <name>]
```

List issues with optional filtering:
- `--status`: Filter by status (todo, in-progress, done, cancelled, backlog)
- `--limit`: Maximum number of issues to show (default: 10)
- `--project`: Filter by project name

**Examples:**
```bash
linear.sh list
linear.sh list --status todo --limit 5
linear.sh list --status in-progress
```

### Create Issue
```bash
linear.sh create <title> [--description <desc>] [--priority <1-4>] [--project <name>] [--label <label>]
```

Create a new issue:
- `title`: Issue title (required)
- `--description`: Issue description
- `--priority`: Priority level (1=Urgent, 2=High, 3=Medium, 4=Low)
- `--project`: Assign to project
- `--label`: Add label (bug, feature, improvement)

**Examples:**
```bash
linear.sh create "Fix login bug"
linear.sh create "Add user dashboard" --description "Create new dashboard for users" --priority 2 --label feature
linear.sh create "Database optimization" --priority 1 --label improvement
```

### Update Issue
```bash
linear.sh update <issue-id> --status <status>
```

Update issue status:
- `issue-id`: Issue ID from Linear
- `--status`: New status (todo, in-progress, done, cancelled, backlog)

**Examples:**
```bash
linear.sh update "WEN-123" --status in-progress
linear.sh update "WEN-124" --status done
```

### Search Issues
```bash
linear.sh search <query>
```

Search issues by text:

**Examples:**
```bash
linear.sh search "login"
linear.sh search "database bug"
```

### List Projects
```bash
linear.sh projects
```

Show all available projects.

### List Labels
```bash
linear.sh labels
```

Show all available labels with colors.

## Status Mapping

- `todo` → Todo
- `in-progress` → In Progress  
- `done` → Done
- `cancelled` → Canceled
- `backlog` → Backlog

## Priority Mapping

- `1` → Urgent
- `2` → High
- `3` → Medium
- `4` → Low

## Available Labels

- `bug` → Bug (red)
- `feature` → Feature (purple)
- `improvement` → Improvement (blue)

## Error Handling

- Validates API key access
- Checks for valid status/priority/label values
- Returns meaningful error messages
- Gracefully handles API failures

## Output Format

Issues are displayed in human-readable format with:
- Issue ID and title
- Current status and priority
- Assignee (if any)
- Description (if any) 
- Labels (if any)
- Direct URL to Linear

Perfect for agent consumption and human review.