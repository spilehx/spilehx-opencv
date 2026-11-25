# Code style

Apply the general rules to all project code, including embedded code in scripts. Apply language-specific rules to the corresponding language. Build and configuration files have additional guidance below.

Follow the surrounding code when minor historical inconsistencies exist. Local patterns take priority over these summaries; do not reformat unrelated code.

## General

### Names and structure

- Use descriptive, domain-specific names that follow the language and local naming conventions.
- Follow the Single Responsibility Principle (SRP): each module, class, and function should have one clear responsibility. Avoid mixing unrelated concerns.
- Follow the Don't Repeat Yourself (DRY) principle: reuse shared logic rather than duplicate it. Extract cohesive functions or utility classes, and use object-oriented design where appropriate. Keep abstractions proportionate to the actual need; avoid excessive helpers, class hierarchies, or speculative reuse.
- Include only imports, includes, and dependencies needed by the code.
- Preserve names required by public APIs, native bindings, external tools, and file formats.

### Layout and flow

- Follow the surrounding indentation, spacing, and brace placement, subject to the language's syntax requirements.
- Prefer early returns for simple empty/error cases, followed by straightforward conditions, loops, and switches.
- Avoid overly verbose code, unnecessary defensive checks where the project contract guarantees a value, and speculative branches. Retain validation needed at external or native boundaries.
- Keep comments brief and focused on operational reasons or constraints rather than obvious syntax.

### Diagnostics

- Follow the diagnostic mechanism already used in the area being changed.
- Describe operation outcomes and failures with enough context to identify the affected operation or object.
- Avoid duplicate messages for the same event and repetitive output from polling or internal lifecycle details.

## Haxe (`.hx`)

### Names and types

- Classes use `PascalCase`; functions, variables, and fields use `camelCase`. Preserve existing binding names and accessor conventions such as `get_raw`.
- Constants and enum-abstract values use `UPPER_SNAKE_CASE`.
- Prefer explicit types for fields, parameters, collections, callbacks, and meaningful locals, following the surrounding code: `Array<String>`, `Map<String, T>`, `Bool->Void`.
- Declare property access explicitly, following nearby properties, such as `(get, never)` for a computed read-only property.

### Declarations and layout

- Put `package` first, followed by targeted imports. Keep macro-only imports inside the existing conditional compilation guards.
- Keep opening braces on the declaration or control-flow line.
- Follow the file's indentation; do not impose tabs on files that use spaces.
- Follow neighboring binding classes for visibility, metadata, inline methods, and native conversions.
- When using callbacks for asynchronous completion, make the completion parameter explicit and invoke it once the operation completes. Use arrow callbacks for short handlers where consistent with nearby code.
- make code readable, always include all braces

## C++ (`.cpp`, `.h`)

- Follow neighboring declarations for OpenCV types, CFFI `value` parameters, pointer/reference spacing, and native symbol names.
- Keep opening braces on the declaration or control-flow line, matching the surrounding indentation.
- Use the existing conversion, property, primitive-registration, and finalizer helpers where applicable rather than duplicating them.
- Keep macro continuation backslashes consistent with the local style and preserve statement boundaries in macro expansions.
- Make ownership and lifetime constraints clear where they are not evident from the existing conversion or finalizer pattern. See [the architecture map](ARCHITECTURE.md) for binding and lifetime conventions.

## Bash (`.sh`)

- Preserve the Bash shebang and existing `set -euo pipefail` setup.
- Use `camelCase` function names and uppercase configuration/global variables, following the existing scripts. Use `local` for function-local variables.
- Quote variable expansions and paths unless splitting or globbing is intentional.
- Follow the existing function and control-flow layout; keep multiline commands readable using continuation lines.
- Use the script's existing diagnostic helpers or output conventions, with errors directed to standard error.

## Python (including code embedded in shell scripts)

- Use four spaces for indentation, `snake_case` functions and variables, and uppercase constants.
- Put imports at the start of each Python block and use the existing standard-library utilities where suitable.
- Preserve heredoc boundaries and indentation so shell processing does not alter Python code.

## Build and configuration files

- XML and JSON: follow the existing indentation and attribute/key layout. Preserve names and syntax required by the consuming tool.
- Makefiles: use tabs for recipe commands and follow the existing target and variable conventions.
- HXML: follow the existing option layout and preserve quoting across Haxe and shell parsing.
- For embedded code, apply the corresponding language rules as well as the containing format's syntax requirements.
