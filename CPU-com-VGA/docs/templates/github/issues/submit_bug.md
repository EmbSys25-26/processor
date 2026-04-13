---
name: Bug
about: Something is wrong (regression, incorrect behavior, failing test)
title: "[BUG] short description"
labels: ["P0"]
assignees: []
---

## State Bug (1 line)

What is observed?

## Expected (2-3 lines)

What should happen?

## How to observe (minimal)

Example:

1. Check out to branch `bug/short-description`
2. Run behavioral simulation in Vivado Design Suite.
3. Select waveconfig `wavecfgs/bug-wavcfg`. See that `signal` is `0` when it should be `1`.

## Evidence (required)

- Logs / failing test name / screenshot / waveform timestamp

## Suspected area

- [ ] pipeline
- [ ] compiler
- [ ] peripherals

## Definition of Done

- [ ] Root cause identified
- [ ] Fix merged
- [ ] Regression test added (or explanation why not)
