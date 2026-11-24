# Prettier baseline v1.0.1

Date: 2026-11-24. Approved by the repository owner.

## Decision

- In `full` mode, the reusable check no longer installs the repository's dependencies. It runs `prettier@3.10.1` directly with `npx`, as `docs-only` mode already did.
- The `install-command` input is removed, because nothing needs it any more.
  - A caller that passed it would fail, since GitHub rejects inputs a reusable workflow does not declare.
  - On 2026-11-24 none of the 7 adopting repositories passed it; their callers set only `mode`.
  - A future caller that adds it must drop it to use v1.0.1 or later.
- The check that `package.json` pins `prettier` to exactly the baseline version stays. Local `npm run format` and the CI check therefore still use the same Prettier.
- No formatting option changes, so adopting repositories only move their caller from `@v1.0.0` to `@v1.0.1`. Nothing is reformatted.

## Why

- In v1.0.0, `full` mode ran `npm ci` without a registry token.
- In `pim-sandbox`, which installs private `@doriantudor/*` packages from GitHub Packages, that step failed with `401 Unauthorized` on its first run. It fails in the same way in every repository with private packages.
- Prettier needs none of a repository's dependencies, because the baseline uses no plugins.
- Passing a registry token into the shared check would give a formatting check read access to private packages it does not use.

## Diff size

| Repository          | Lines changed by v1.0.1 |
| ------------------- | ----------------------- |
| every adopting repo | 0                       |
