# Release checklist

This repository is a GitHub Action. Publishing means pushing tags and creating releases.

## 1) Pre-release checks

- Ensure CI is green on `main`.
- Ensure `README.md` examples use `@v1` (not `@main`).
- Ensure `action.yml` and scripts match current `speq-cli` behavior.

## 2) Create first stable release

Use a full semantic tag, then move major tag:

```bash
git checkout main
git pull
git tag v1.0.0
git push origin v1.0.0
git tag -f v1
git push origin v1 --force
```

Then create a GitHub Release for `v1.0.0` with notes.

## 3) Next patch/minor release

```bash
git checkout main
git pull
git tag v1.0.1
git push origin v1.0.1
git tag -f v1
git push origin v1 --force
```

## 4) Breaking changes (new major)

```bash
git tag v2.0.0
git push origin v2.0.0
git tag -f v2
git push origin v2 --force
```

Do not move `v1` when releasing `v2`.

## Consumer guidance

Production users can choose:

- `uses: speq-tms/speq-github-runner@v1` (recommended default)
- `uses: speq-tms/speq-github-runner@v1.0.0` (exact version)
- `uses: speq-tms/speq-github-runner@<commit_sha>` (strict pinning)
