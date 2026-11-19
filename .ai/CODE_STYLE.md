# Code style

IMPORTANT: Only apply these rules to .hx files all other code must not be reviewed


Follow the surrounding file when minor historical inconsistencies exist.

## Names and types

- Classes use `PascalCase`; functions, variables, and fields use `camelCase`.
- Constants use `UPPER_SNAKE_CASE` (`CACHE_FILE_NAME`, `MAX_ERROR_RETRIES`). Enum-abstract values are also uppercase.
- Use descriptive, domain-specific names (`fileManagerFolderKey`, `onComplete`, `dataCache`).
- Fields, parameters, collections, callbacks, and meaningful locals are usually explicitly typed: `Array<String>`, `Map<String, T>`, `Bool->Void`.
- Public properties commonly use `@:isVar` with explicit access, such as `default, null` for read-only state.

## Classes and methods

- Put `package` first, then targeted imports. Avoid imports that are not needed.
- Use `public static final instance:Type = new Type();` and a private constructor for singleton managers.
- Constructors assign setup state, call `super()` in subclasses, and register manager blocking/dependency relationships.
- Manager hooks are private overrides: `override private function setup(...)`, `update(...)`, and `onError()`.
- Use an explicit callback parameter for asynchronous completion and call it once work is complete. Arrow callbacks are common for short handlers (`info -> { ... }`).
- Keep responsibilities narrow (SRP), avoid duplicated logic (DRY), and prefer direct code over extra helpers or abstractions.

## Layout and flow

- Braces stay on the declaration/control-flow line. Use tabs in the prevailing Haxe source style; do not reformat unrelated code.
- Prefer early returns for simple empty/error cases, then straightforward `if`/`else`, loops, and `switch` statements.
- Avoid overly verbose code, unnecessary null/defensive checks where the project contract guarantees a value, and speculative branches.
- Comments explain a local operational reason (for example, a dependency or queue behaviour), not obvious syntax. Keep them brief; existing hook placeholders may note the intended override purpose.

## Logging

- Use `LOG()` for development diagnostics, `LOG_WARN()` for diagnostic warnings, and `LOG_ERROR()` for diagnostic failures. `LOG()` is gated by verbosity; warnings and errors remain visible.
- Use `EVENT_INFO()`, `EVENT_WARN()`, and `EVENT_ERROR()` for application events available through HTTP. These also log locally and queue `EVENT_LOG_TOPIC`; do not log the same event again when storing or delivering it.
- Keep `USER_MESSAGE*` inside the event logging implementation only. Its optional boolean is `forceMsg` (default `true`), not a verbose-only flag.
- Report operation outcomes and state changes, with the affected object or operation. Deduplicate recurring failures and avoid events for polling or internal lifecycle details.
- Keep detailed output in diagnostic logs and concise, actionable summaries in server events.

When changing an existing area, its local pattern takes priority over these summaries.
