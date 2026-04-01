# Contributing to speq-github-runner

## Workflow

- Branch from `main`.
- Keep changes backward compatible where possible.
- Validate examples after action changes.

## Commit style

Use Conventional Commit prefixes (`feat:`, `fix:`, `docs:`, `chore:`).

## Pull request checklist

- [ ] Action behavior documented.
- [ ] Example workflow updated if needed.
- [ ] Compatibility with current `speq-cli` noted.
- [ ] CI checks are green.

## Runtime rule

Do not add execution runtime to this repository. All validation and test execution must go through `speq-cli`.
