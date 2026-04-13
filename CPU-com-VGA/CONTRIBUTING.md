# Contributing

Thanks for contributing.

## Before you start

- Work starts from an admin-created issue for the active biweekly rotation.
- Use one issue per branch and one branch per pull request.
- Follow naming conventions in `/Users/josesilvaa/verilog-processor/docs/templates/github/README.md`.

## Biweekly rotation workflow

1. Rotations run biweekly across three domains:
   - `pipeline`
   - `compiler backend`
   - `peripherals`
2. The admin creates the biweekly milestone, using the previous group's release notes as input.
3. Admins collaborate to define that biweek’s issue set and explicit deliverables.
4. Issues are assigned by the admin to team members or member groups.
5. Each assignee/group implements only the scoped issue(s) for that rotation and opens PRs against those issues.
6. At the end of the biweek, release notes are updated and become input for the next rotation planning cycle.

## Development flow

1. Sync your local `main` from origin before starting any work.
2. Create your feature branch from the latest `main` (do not branch from stale commits).
3. Confirm the issue is assigned to you (or your group) in the current milestone.
4. Implement the smallest change that closes the issue.
5. Keep RTL style conventions used in this repository:
   - sectioned modules/testbenches
   - explicit signal naming conventions
   - update docs when behavior/register maps change
6. While your branch is open, rebase (or merge) from `main` frequently, especially after PRs that touch shared interfaces.
7. Before opening/reopening PR review, update your branch to latest `main` and resolve conflicts locally.
8. Run local checks before opening the PR.

## Git workflow commands (copy/paste)

### 1) Start work from latest `main`

```bash
git checkout main
git pull origin main
git checkout -b <type>/<short-description>
```

Example:

```bash
git checkout -b pipeline/add-forwarding-fix
```

### 2) Commit your work normally

```bash
git add -A
git commit -m "pipeline: fix forwarding hazard in EX stage"
git push -u origin <type>/<short-description>
```

### 3) Keep branch synced while PR is open (recommended daily)

Rebase style (preferred for clean history):

```bash
git fetch origin
git rebase origin/main
git push --force-with-lease
```

### 4) Sync again right before requesting final review/merge

```bash
git fetch origin
git rebase origin/main
git push --force-with-lease
```

### 5) If rebase conflicts happen

```bash
git status
# edit conflicting files, then:
git add <resolved-file> ...
git rebase --continue
```

### 6) After PR is merged

Rinse and repeat for the next issue.

```bash
git checkout main
git pull origin main
git checkout -b <type>/<short-description>
```

## Required local checks

From repository root:

```bash
python3 /Users/josesilvaa/verilog-processor/tools/assembler.py -q
bash /Users/josesilvaa/verilog-processor/scripts/ci/run_iverilog_regression.sh
```

If you touched constraints, waveform configs, or hardware-only paths, include
what you validated in Vivado in the PR description.

## Pull request requirements

- Use the PR template in `/Users/josesilvaa/verilog-processor/docs/templates/github/PULL_REQUEST.md`.
- Include one auto-closing issue reference (`Fixes #...` or equivalent).
- Include clear verification evidence (command output summary, waveform note,
  or testbench pass markers).
- **Keep PRs focused (AVOID MIXING UNRELATED CHANGES).**
- If work is group-owned, **include all relevant assignees/reviewers in the PR.**
- PR branch must be updated with latest `main` before merge (required when branch protection enforces up-to-date merges).

## Commit guidance

- Write clear commit messages describing what changed and why.
- Prefer small commits that are easy to review.

## Licensing and provenance

This repository includes material derived from Gray Research XSOC work.
Contributions must preserve required attribution and license terms in
`root/LICENSE`.

If you import external code, document provenance and license compatibility in
your PR.

## Questions

For implementation questions, open a GitHub issue or discussion in this repo.
