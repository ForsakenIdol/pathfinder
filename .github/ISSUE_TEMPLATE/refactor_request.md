---
name: "Refactor Request"
about: "Suggest changes and improvements to the Pathfinder project."
title: "[Refactor] <short title>"
labels: ["refactor", "needs-triage"]
assignees: []

body:
  - type: markdown
    attributes:
      value: |
        Propose refactoring to improve maintainability, performance, or clarity.
---

# Refactor Request

Please fill out the sections below. If you are implementing a refactor and your changes are covered by a pull request, please reference the corresponding GitHub issue number in your PR.

## What needs refactoring?

*Describe the file(s)/function(s), e.g. "myscript.sh has nested conditionals and poor error handling."*

## Why refactor?

*Justify the need to refactor. Some examples of pointers are provided below.*

- *Current issues: (e.g., hard to maintain, violates DRY principle)*
- *Benefits: (e.g., easier testing, 20% faster execution)*

## Proposed changes

*Outline the approach, e.g.:*

- *Extract functions*
- *Add error handling*
- *etc.*

## Risks / Breaking changes

*What is the potential impact of your refactor? What functionality might be affected, and what steps will you take / have you taken to mitigate this?*

## Additional context

*Screenshots or code snippets if helpful.*
