# Ways of working

## Static changes by default

Codex may inspect and edit files. Do not build, compile, run the application or tests, launch executables, start servers, or perform runtime verification unless the developer explicitly asks. Do not infer that permission from a code-change request.

## Developer-led design

The developer owns architecture and structure. Implement requested changes in the existing design; do not add frameworks, layers, helper systems, abstractions, or new patterns unless requested or clearly required by the change.

## Light touch

Make the smallest clean change that satisfies the request. Avoid unrelated refactors, opportunistic cleanup, broad formatting, premature abstraction, and complexity for hypothetical requirements.

## Decisions and ecosystem

- Follow the existing repository layout and local code pattern.
- Reuse project utilities and available Haxelibs before creating equivalent infrastructure.
- Inspect existing code before adding custom infrastructure.
- Ask the developer when an ambiguity would materially affect implementation. Do not ask when the existing code establishes the pattern.

## Communication and context

Keep communication concise. Inspect only files needed for the current task where practical; do not provide long explanations for straightforward edits.
