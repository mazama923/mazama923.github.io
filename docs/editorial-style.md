# Editorial style

## Voice

Write for practitioners. Prefer direct explanations, concrete commands, versions, constraints, and failure modes over broad claims. Explain why a choice was made when that context affects operations.

## Structure

- Start with the problem and the intended outcome.
- State assumptions and prerequisites before commands.
- Use short sections with descriptive headings.
- Keep commands minimal, copyable, and idempotent where possible.
- End with validation or rollback guidance when a change affects production systems.

## Technical conventions

- Use English for code, identifiers, configuration keys, paths, and commands.
- Pin or state versions when behavior depends on them.
- Quote shell variables and use `set -euo pipefail` in Bash examples unless there is a reason not to.
- State security implications for credentials, network exposure, and destructive operations.

## Metadata

The title is specific and concise. The description is a standalone factual summary suitable for a feed or search result. Tags identify technologies or operational themes using the repository's lower-case CSV convention.
