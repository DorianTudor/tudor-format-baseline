# Tudor format baseline

This repo holds the single Prettier setup shared by Tudor repositories, plus a reusable GitHub Actions workflow that checks a repository against it.

Current version: `v1.0.0` (Prettier `3.10.1`).

## What is in it

- `.prettierrc.json`: the full config. Every option is set explicitly, so a change to Prettier's defaults cannot reformat code silently.
- `.prettierignore`: the canonical block, between its markers. Each repository adds its own entries below the marker.
- `.gitattributes`: the canonical line-ending block.
- `.github/workflows/prettier-baseline.yml`: the reusable check, called with `mode: full` or `mode: docs-only`.
- `docs/decisions/`: one file per baseline version, giving the reasons and the audit numbers. These files are never edited after they are added.

## The check

The workflow fails if any of these is true:

- `.prettierrc.json` is not byte-identical to this repo's copy at the same tag.
- The marked block in `.prettierignore` or `.gitattributes` differs from this repo's copy.
- Any other Prettier config exists: `.prettierrc` in another format or folder, `prettier.config.*`, or a `"prettier"` key in a `package.json`.
- In `full` mode, the root `package.json` does not pin `prettier` in `devDependencies` to exactly the baseline version.
- `prettier --check` fails.
  - `full` mode runs the install command (default `npm ci`), then the repository's own pinned Prettier.
  - `docs-only` mode runs the pinned Prettier on `**/*.{md,json,yml,yaml}`.

## Adopting it

1. Copy `.prettierrc.json`, and the marked blocks of `.prettierignore` and `.gitattributes`, from the tag you adopt.
2. In `full` mode:
   - Add `"prettier": "3.10.1"` to `devDependencies`. Use an exact version, with no `^` or `~`.
   - Add the scripts `"format": "prettier --write ."` and `"format:check": "prettier --check ."`.
   - If the repository uses ESLint, add `eslint-config-prettier`.
3. Add the caller workflow, `.github/workflows/prettier-baseline.yml`:

   ```yaml
   name: Prettier baseline
   on:
     pull_request:
     push:
       branches: [staging, main]
   jobs:
     prettier:
       uses: DorianTudor/tudor-format-baseline/.github/workflows/prettier-baseline.yml@v1.0.0
       with:
         mode: full # or docs-only
         # install-command: pnpm install --frozen-lockfile   # only if the repository does not use npm
   ```

4. Renormalise line endings in their own commit: `git add --renormalize .`.
5. Format in their own commit, with only Prettier's output in it.
6. List the SHAs of the two bulk commits in `.git-blame-ignore-revs`.
7. Add the "Formatting" section from the next heading to the repository's README.

## README section for adopting repositories

```markdown
## Formatting

This repo uses the shared Tudor Prettier baseline (`DorianTudor/tudor-format-baseline`, version vX.Y.Z).

- Format: `npm run format`
- Check: `npm run format:check` (CI runs this on every PR and fails on drift)
- Do not edit `.prettierrc.json`, the marked block in `.prettierignore` or `.gitattributes`, or the Prettier version. CI rejects changes to them.
- To change the baseline, open a PR on `tudor-format-baseline`, tag a new version, then bump the version in each repo.
- Repo-specific ignores go below the marker in `.prettierignore`.
```

## Changing the baseline

Changes go through a pull request on this repo. Each one:

1. Adds a new dated file in `docs/decisions/`, with a diff-size table across every adopting repository.
2. Updates `BASELINE_VERSION`, and `PRETTIER_VERSION` if it changes, in `.github/workflows/prettier-baseline.yml`. It also updates the current version in this README.
3. Is tagged with the new version once merged. The self-check fails if the tag and `BASELINE_VERSION` disagree.

Each repository then adopts the new version in its own pull request. That pull request moves its caller to the new tag, re-formats the code, and adds the formatting commit to `.git-blame-ignore-revs`.
