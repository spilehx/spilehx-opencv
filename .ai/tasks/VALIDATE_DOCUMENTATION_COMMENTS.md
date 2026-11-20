# Validate Haxe Documentation Comments

## Objective

Validate, add, and correct documentation comments for the public API of Haxe (`.hx`) files under `./src/spilehx/cv/` and its subdirectories, using the scope selected by the user.

Follow project conventions and standard Haxe/Dox documentation practices.

**Document the public contract, not the implementation.** Preserve all executable code, existing changes, and valid documentation. Make only necessary modifications.

## 1. Scope

### Eligible Files

Proceed only after the confirmation and scope selection defined in `AGENTS.md`. Do not infer a default scope or inspect files before both responses are received.

Apply the selected scope:

- `all haxe files`: Include all existing eligible `.hx` files under `./src/spilehx/cv/` and its subdirectories, regardless of Git change status. Include tracked and untracked files.
- `only updated haxe files`: Include only existing eligible `.hx` files under that directory with staged, unstaged, or untracked changes.

For `only updated haxe files`, identify changed files using:

```bash
git status --porcelain=v1 -z --untracked-files=all
```

Correctly handle staged, unstaged, partially staged, added, renamed, and untracked files. Use current filenames for renames.

For either scope, process only existing `.hx` files under `./src/spilehx/cv/` and its subdirectories. Files outside this directory are not eligible, including files renamed out of it. Exclude deleted, ignored, generated, and vendor-managed files unless explicitly maintained as source.

Inspect each eligible file in full, not just modified lines.

Other project files may be read for context but must not be modified. Never read or edit files under `./native/`, including for context.

If no eligible files exist, report this and stop.

### Eligible API

Document externally accessible declarations where documentation provides useful information:

- Classes, interfaces, enums, abstracts, and typedefs.
- Public constructors, methods, properties, fields, and constants.
- Enum constructors and meaningful typedef fields.
- Exposed abstract operations and conversions.
- Interface members and public overrides with meaningful behavioral differences.

Determine accessibility using Haxe semantics, including default visibility, module accessibility, inheritance, abstracts, and relevant metadata.

Distinguish technically accessible declarations from the API intended for library consumers.

Exclude private, internal, implementation-only, compiler-generated, and documentation-hidden declarations.

Respect `@:dox(hide)` and other documentation metadata supported by the project's tooling.

Do not add comments to self-explanatory declarations when documentation would provide no value.

## 2. Documentation Conventions

Before editing, briefly inspect relevant project conventions using existing documented APIs and, where available, `haxelib.json`, documentation configuration, guidelines, and `AGENTS.md`.

Prioritize:

1. Explicit project requirements.
2. Consistent existing conventions.
3. Standard Haxe/Dox conventions.

Use standard Haxe documentation syntax:

```haxe
/**
 * Describes the declaration's public behavior.
 */
```

Place comments so Haxe/Dox associates them with the intended declaration, respecting metadata and modifiers.

Documentation should be concise, accurate, and focused on externally observable behavior.

Include information where meaningful:

- **Types:** Purpose, responsibilities, and important usage constraints.
- **Methods:** Behavior, parameters, return values, side effects, and error conditions.
- **Constructors:** Meaningful initialization behavior and parameters.
- **Properties and fields:** Semantics, units, constraints, mutability, and nullability.
- **Enums:** Meaning of the enum and non-obvious constructors.
- **Abstracts:** Exposed operations, conversions, and relevant constraints.
- **Typedefs:** Purpose and meaningful field semantics.
- **Overrides:** Behavioral differences from the inherited contract.
- **Deprecated APIs:** Deprecated status and known replacements.

Use `@param` for meaningful parameter descriptions and `@return` for meaningful non-`Void` results, following project conventions.

Parameter names must match their declarations. Document nullable or special return values where relevant.

Avoid:

- Comments that merely repeat names or types.
- Unnecessary implementation details.
- Unsupported assumptions or invented constraints.
- Placeholder documentation.
- Redundant comments on trivial declarations.
- Duplicating inherited documentation without meaningful differences.

## 3. Validate and Update Documentation

For each eligible public API declaration:

1. Check whether existing documentation is accurate and sufficient.
2. Correct outdated behavior, parameter names, return descriptions, constraints, or API references.
3. Add missing documentation only when it provides useful information.
4. Preserve valid documentation without unnecessary rewriting.

Base descriptions on the implementation, related APIs, inherited contracts, or authoritative project documentation.

Read related files when necessary to establish behavior, but do not modify them unless independently eligible.

If behavior cannot be established reliably, leave the declaration unchanged and report the uncertainty.

Prefer minimal, targeted edits.

## 4. Modification Restrictions

**Only documentation comments in eligible `.hx` files may be changed.**

Do not:

- Modify executable code, signatures, imports, metadata, visibility, or identifiers.
- Refactor or reformat unrelated code.
- Modify non-documentation comments.
- Remove valid documentation.
- Modify project configuration or files outside scope.
- Stage, commit, push, revert, or discard changes.
- Run automatic source-rewriting commands.

Treat all existing uncommitted changes as user-owned.

Preserve staged and unstaged changes, including partially staged files. Apply edits only to the working tree without modifying the Git index.

## 5. Verification and Reporting

### Verification

Before editing, retain the original contents of eligible files and the initial Git status for comparison.

After editing, verify:

- Only eligible documentation comments were changed by this task.
- Executable code and existing user changes remain intact.
- The Git index is unchanged.
- Documentation syntax, placement, parameters, and return descriptions are correct.
- Project conventions are respected.

Use targeted diffs and `git diff --check` where appropriate. Account for staged and untracked files, which ordinary working-tree diffs do not fully cover.

Compare against the pre-edit contents to distinguish task changes from existing user modifications.

Run an established Haxe validation command only if available, safe, and practical. Do not install dependencies or modify configuration.

Do not perform unnecessary builds, exhaustive repository analysis, or unrelated validation.

### Report

Provide a concise summary:

**Documentation Validation Results**

- Scope: All Haxe files / Only updated Haxe files
- Files inspected: N
- Files updated: N
- Comments added: N
- Comments corrected: N
- Verification: Passed / Failed / Not verified
- Compilation: Passed / Failed / Not run
- Unresolved issues: None / Brief details

Do not claim verification succeeded unless performed.

If no changes were necessary, report:

`All eligible Haxe files were inspected. No documentation updates were required.`

Do not include lengthy explanations, unchanged-file listings, or detailed change logs unless necessary to report a problem.

---

**Priority:** Accuracy, minimal changes, preservation of user work, and efficient execution. Avoid unnecessary analysis, tool calls, and documentation volume.
