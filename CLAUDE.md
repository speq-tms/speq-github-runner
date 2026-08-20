# speq-github-runner

GitHub Action wrapper around SPEQ CLI execution.

## Responsibilities
- Action input/output handling.
- Invocation of `speq-cli` in CI pipelines.

## Invariants
- Keep this layer thin and integration-focused.
- Do not duplicate core execution logic from `speq-cli`. Runtime behavior belongs there.
- Action inputs must map onto real CLI flags — verify against `speq-cli/src/main.rs` before adding one.

## How we work

Full process: `speq-docs/docs/delivery/release-flow.md`. Read it before starting delivery work. Summary:

- **Issues live in [`speq-tms/speq-docs`](https://github.com/speq-tms/speq-docs/issues)**, not here. Work for
  this repository carries the `area/runner` label.
- **Milestone title == RC branch name.** Milestone `v1.1.0` means branch `v1.1.0`. `backlog` is not a release
  and has no branch.
- **Find the current RC** — GitHub state is authoritative, not any version written in a file:

  ```bash
  gh api repos/speq-tms/speq-docs/milestones \
    --jq '.[] | select(.state=="open" and .title != "backlog") | .title'
  git ls-remote --heads origin 'v*'
  ```

- **Branch from the RC, never from `main`:** `git switch -c feat/runner-<name> origin/<RC>`.
- **PR base is the RC**, never `main`. One final PR takes the RC into `main`.
- `Closes #N` does **not** work across repositories. Write `Part of speq-tms/speq-docs#N` in the PR, then close
  the issue manually after merge:
  `gh issue close N --repo speq-tms/speq-docs --comment "Landed in <PR url>."`

There is currently no RC branch here. Small non-release changes go through a `chore/*` branch straight into
`main`; anything shipped as a new action version needs an RC.
