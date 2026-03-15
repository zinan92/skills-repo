# Skill Category Subfolders Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Reorganize `skills-repo` so the five top-level domains each live in their own subfolder, while keeping installation and documentation working.

**Architecture:** Move each skill directory from the flat `skills/<name>/` layout to `skills/<category>/<name>/`. Update `install.sh` to scan recursively for `SKILL.md` and install the containing skill directory. Add a regression test that proves dry-run output resolves nested category paths, then rewrite `README.md` with the gh-readme structure to document the new layout.

**Tech Stack:** Bash, Markdown, repo-local shell tests

---

### Task 1: Add failing regression test for nested category discovery

**Files:**
- Create: `tests/install_nested_categories_dry_run.sh`
- Modify: none
- Test: `tests/install_nested_categories_dry_run.sh`

**Step 1: Write the failing test**

Create a shell test that runs:

```bash
bash "$REPO_ROOT/install.sh" --dry-run
```

and asserts the output contains nested source paths such as:

```text
$REPO_ROOT/skills/global/using-superpowers
$REPO_ROOT/skills/content/baoyu-post-to-x
$REPO_ROOT/skills/dev/gh-readme
```

**Step 2: Run test to verify it fails**

Run: `bash tests/install_nested_categories_dry_run.sh`
Expected: FAIL because the repo is still flat and `install.sh` only scans one directory deep.

**Step 3: Write minimal implementation**

Do not implement yet. The failure proves the current installer cannot satisfy the new structure.

**Step 4: Run test to verify it still fails for the expected reason**

Run: `bash tests/install_nested_categories_dry_run.sh`
Expected: FAIL with missing nested path assertions.

### Task 2: Move skill directories into five category subfolders

**Files:**
- Modify: `skills/`
- Test: `tests/install_nested_categories_dry_run.sh`

**Step 1: Move skills into category folders**

Create:

- `skills/global/`
- `skills/data/`
- `skills/content/`
- `skills/dev/`
- `skills/trading/`

Move each skill directory into its assigned category folder, preserving each skill’s internal files.

**Step 2: Run failing test again**

Run: `bash tests/install_nested_categories_dry_run.sh`
Expected: Still FAIL, because `install.sh` still scans `skills/*/`.

### Task 3: Update installer for recursive category scanning

**Files:**
- Modify: `install.sh`
- Test: `tests/install_nested_categories_dry_run.sh`

**Step 1: Write minimal implementation**

Change the scan logic so it finds every `SKILL.md` under `skills/` recursively, then installs the parent directory of each `SKILL.md`.

**Step 2: Run targeted test**

Run: `bash tests/install_nested_categories_dry_run.sh`
Expected: PASS

**Step 3: Run broader verification**

Run: `bash tests/install_company_shared.sh`
Expected: PASS

### Task 4: Rewrite README with gh-readme structure

**Files:**
- Modify: `README.md`
- Review: `install.sh`

**Step 1: Read current product details**

Use the current `README.md`, `install.sh`, `uninstall.sh`, and test files to derive:

- repo purpose
- five-category structure
- install interface
- frontmatter routing model

**Step 2: Rewrite `README.md`**

Produce a Chinese product README that reflects:

- the five category subfolders
- flat skill naming inside each category
- recursive installer discovery
- frontmatter routing

**Step 3: Verify doc accuracy**

Run:

```bash
bash install.sh --dry-run
bash tests/install_nested_categories_dry_run.sh
```

Expected: both succeed and the documented paths match the real output.

### Task 5: Final verification and git hygiene

**Files:**
- Modify: `README.md`
- Modify: `install.sh`
- Modify: `tests/install_nested_categories_dry_run.sh`
- Modify: moved `skills/...` directories

**Step 1: Run full verification**

Run:

```bash
bash tests/install_nested_categories_dry_run.sh
bash tests/install_company_shared.sh
bash tests/monica_workspace_skills_resolve.sh
bash tests/monica_skills_no_self_symlinks.sh
bash tests/donald_remotion_skill_resolves.sh
```

Expected: all relevant tests pass, or any pre-existing failures are called out explicitly.

**Step 2: Commit**

```bash
git add README.md install.sh tests/install_nested_categories_dry_run.sh skills docs/plans/2026-03-15-skill-category-subfolders.md
git commit -m "refactor: organize skills by category"
```
