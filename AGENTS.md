# AI guidance

Detailed project guidance is under `.ai/`. Do not automatically load every document; read only what is relevant to the task.

- Code/style: `.ai/CODE_STYLE.md`
- Working practices: `.ai/WAYS_OF_WORKING.md`
- Structure, managers, routes: `.ai/ARCHITECTURE.md`

Implementation is the source of truth if it differs from this guidance.






## Pre-Commit Check

### Trigger and Confirmation
- Run this task only when the user explicitly says `Do pre-commit check`.
- Before proceeding, ask: **"Run pre-commit checks? (yes/no)"**
- If the user responds `no`, stop without taking any action.
- If the user responds `yes`, perform the checks below.
- Do not run these checks automatically or as part of other tasks.

### Review Scope
- Review all uncommitted changes, including staged, unstaged, and untracked files.
- Use Git status to identify all changed and untracked files.
- Inspect untracked file contents separately, since they are not included in standard Git diffs.
- Perform a read-only static review. Do not modify code, configuration, or files.
- Do not run builds, tests, containers, or the application.

### Checks
1. **Code quality:** Verify that changed code is clean, concise, efficient, correct, maintainable, free of unnecessary verbosity or complexity and inline with ./.ai/CODE_STYLE.md.
2. **File structure:** Identify overly long files or mixed responsibilities that would benefit from splitting into smaller, single-responsibility modules. Recommend refactoring only when justified.
3. **Legacy code:** Identify unused, obsolete, duplicated, or superseded code introduced or made redundant by the changes.

### Verification Limitations
- Static inspection cannot guarantee runtime correctness or the absence of regressions.
- Clearly identify affected functionality and any regression risks that cannot be conclusively verified.
- Do not claim that functionality has been tested or verified through execution.
- Distinguish confirmed defects from potential risks and unverified behaviour.

### Report
- Report only actionable findings, grouped by severity, with relevant file paths and line numbers.
- Explain each issue concisely and recommend a specific correction.
- Distinguish confirmed issues from potential risks that cannot be verified through static inspection.
- If no issues are found, state that the static review found no issues, without claiming the application is regression-free.
- Do not make corrections or commit changes. Wait for further instructions.