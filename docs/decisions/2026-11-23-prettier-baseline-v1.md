# Prettier baseline v1.0.0

Date: 2026-11-23. Approved by the repository owner after the cross-repository audit.

## Decision

- **Prettier version:** 3.10.1, the latest stable release on the day of the audit. It is pinned exactly wherever it is used.
- **Options:** every option is set explicitly in `.prettierrc.json`. All of them are Prettier 3 defaults except one: `printWidth: 120`.
- **Line endings:** `endOfLine: "lf"` is not negotiable. In `.gitattributes`, `*.cmd` and `*.bat` stay CRLF.
- **Where the check runs:** a reusable GitHub Actions workflow in this public repository runs the check, and adopting repositories call it.
  - The owner chose this knowingly. It is an exception to the general rule that verification runs before the push, not in Actions.
- **How changes reach repositories:** each repository adopts the baseline through its own feature branch and pull request.
  - The owner also chose this knowingly. It is an exception to the staging-only branch rule and to the ban on formatting-only pushes.

## Why

- Setting every option explicitly means a future Prettier release that changes a default cannot reformat code without a new baseline version.
- **Width 120:**
  - It gave a smaller diff than 80 in 17 of the 18 full-scope repositories.
  - It cut the total diff by 32% (657,000 lines against 957,746).
  - The exception is `tudor-mail`, which was already formatted at 80.
- **Other candidates:** the audit tested four more overrides; none gave a smaller diff in more than half the repositories.

| Candidate                   | Repositories where it gave a smaller diff | Total lines changed |
| --------------------------- | ----------------------------------------- | ------------------- |
| baseline (`printWidth: 80`) | —                                         | 957,746             |
| `printWidth: 120`           | 17/18                                     | 655,723             |
| `printWidth: 100`           | 17/18                                     | 770,107             |
| `trailingComma: "es5"`      | 6/18                                      | 958,588             |
| `singleQuote: true`         | 3/18                                      | 1,114,548           |
| `semi: false`               | 1/18                                      | 1,322,028           |

## Audit facts this rests on

- **Coverage:** 32 active repositories were audited on 2026-11-23.
  - 18 are in `full` scope and 14 in `docs-only` scope.
  - 4 archived repositories were skipped.
- **Prior Prettier use:** only `tudor-mail` used Prettier, with Prettier defaults and `endOfLine: "auto"`.
- **ESLint:** no repository had stylistic ESLint rules.
- **Line endings:** no repository stored CRLF files in its index.
- **How it was measured:**
  - Prettier ran on the build PC with this baseline config and ignore file only.
  - No repository's own config or plugins were loaded.
  - Lines changed means insertions plus deletions.
