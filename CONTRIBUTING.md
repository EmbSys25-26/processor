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

1. Sync your branch from `main`.
2. Confirm the issue is assigned to you (or your group) in the current milestone.
3. Implement the smallest change that closes the issue.
4. Keep RTL style conventions used in this repository:
   - sectioned modules/testbenches
   - explicit signal naming conventions
   - update docs when behavior/register maps change
5. Run local checks before opening the PR.

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
- Keep PRs focused (avoid mixing unrelated changes).
- If work is group-owned, **include all relevant assignees/reviewers in the PR.**

## Commit guidance

- Write clear commit messages describing what changed and why.
- Prefer small commits that are easy to review.

## Licensing and provenance

This repository includes material derived from Gray Research XSOC work.
Contributions must preserve required attribution and license terms in
`/Users/josesilvaa/verilog-processor/LICENSE`.

If you import external code, document provenance and license compatibility in
your PR.

## Questions

For implementation questions, open a GitHub issue or discussion in this repo.
