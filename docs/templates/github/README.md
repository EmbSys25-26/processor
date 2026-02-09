# Rules to enforce on GitHub

The workflow will be as follows:

1. **One issue → one branch → one pull request.**
2. Every issue has AT LEAST 2 labels: **one priority** (`P0/P1/P2`) + **one area** (`pipeline/compiler/peripherals`).
3. Every PR must contain **Fixes #ID** and **How to test**.

## Issue naming convention

Issue names are: `<type>/<short description>`, where `<type>` is one of `pipeline/compiler/peripherals/bug` and the description is a short action verb phrase. 
For example: `pipeline/add IF/ID stage register + valid`.

## Branch naming convention

`<type>/<short description>`, where `<type>` is one of `pipeline/compiler/peripherals/bug` and the description is a short action verb phrase. 
For example: `pipeline/add-IF-ID-stage-register`.
This **should match** the issue name, but with dashes instead of spaces and no labels.
