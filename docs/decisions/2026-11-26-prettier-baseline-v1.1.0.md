# Prettier baseline v1.1.0

Date: 2026-11-26. Approved by the repository owner.

## Decision

- `.prettierrc.json` adds `"objectWrap": "collapse"`. Every other option and the Prettier version (3.10.1) stay as in v1.0.1.
- Prettier then puts an object literal on one line whenever it fits in `printWidth`, whatever its line breaks were in the source.
- Under v1.0.1 the option was unset, so Prettier's default (`"preserve"`) kept an object multi-line if the source had a line break after `{`.
- Each adopting repository moves its caller to `@v1.1.0`, re-formats in its own commit, and lists that commit in `.git-blame-ignore-revs`.
- A repository that stays on `@v1.0.1` keeps passing; nothing breaks until it moves.

## Why

- With `"preserve"`, how an object is laid out depends on where its author happened to press Enter, so the same object can be formatted two ways. `"collapse"` leaves one layout per object.
- Setting the option explicitly keeps the v1.0.0 rule that every option is set, so a change to Prettier's default cannot reformat code silently.

## Diff size

Measured on 2026-11-26 with Prettier 3.10.1 on each repository's development branch: formatted with v1.0.1 first, then with v1.1.0. Lines changed means insertions plus deletions of the second step only.

| Repository          | Files | Lines changed | Net lines |
| ------------------- | ----- | ------------- | --------- |
| tudor-mail          | 128   | 4,446         | −2,932    |
| tudor-it-help-api   | 94    | 2,974         | −1,854    |
| purchasing          | 89    | 2,861         | −1,723    |
| tudor-user-portal   | 48    | 1,435         | −847      |
| Tudor-CRM           | 84    | 1,188         | −584      |
| tudor-design-system | 37    | 441           | −289      |
| Tudor-CRM-Android   | 34    | 290           | −142      |
| flip-book           | 27    | 252           | −162      |
| tudor-pim           | 6     | 169           | −107      |
| pim-sandbox         | 6     | 163           | −101      |
| claude-review-gate  | 3     | 26            | −18       |
| **All 11 adopters** | 556   | 14,245        | −8,759    |
