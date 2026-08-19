---
name: update-repo
description: Use when the user wants to change a GitHub repository and open a PR from ANY terminal, even one where that repo is not checked out. Clones via ghq if absent, branches off the fresh default branch, forks automatically when there is no write access, and opens a PR. Invoke as /update-repo <owner/repo> <change>.
argument-hint: <owner/repo> <change to make>
---

# Update Repo

Make a change to any GitHub repository and open a pull request, from any terminal.
Always works in the ghq-managed clone so behaviour is identical everywhere and never
disturbs whatever checkout you happen to be sitting in.

## Steps (follow strictly)

### 1. Parse the arguments

The first token of `args` is the target repository when it looks like `owner/repo`
(or a full GitHub URL). Everything after it is the change to make.

- No `owner/repo` first token: ask the user which repository to change. Do not guess
  from the current directory — this skill is meant to be run from anywhere, so the
  current checkout says nothing about the intended target.
- Repository given but no change described: ask what to change.

### 2. Preflight: gh auth and ghq

```bash
gh auth status
```

If `gh auth status` fails, STOP and tell the user to run `! gh auth login`, then wait.

```bash
command -v ghq || mise use -g ghq@latest
```

If `mise use -g ghq@latest` fails to resolve, fall back to `mise use -g ubi:x-motemen/ghq`.

### 3. Resolve the repository's facts

Never assume the default branch is `main`, and never assume you can push to it.

```bash
gh repo view <owner/repo> --json defaultBranchRef,viewerPermission
```

- `defaultBranchRef.name` — the base branch for the PR.
- `viewerPermission` — `ADMIN`, `MAINTAIN`, or `WRITE` means you can push a branch
  directly to origin. `TRIAGE`, `READ`, or `NONE` means you must fork (step 7).

If the command fails, the repo does not exist or is not visible to this account.
Report that and stop.

### 4. Get (clone or update) the repository

```bash
ghq get -u github.com/<owner>/<repo>
repo="$(ghq list --full-path --exact github.com/<owner>/<repo>)"
cd "$repo"
```

### 5. Sync the base branch and create a working branch

Always branch off the fresh default branch — never edit it directly, never push to it.

```bash
git switch <default-branch>
git pull --ff-only
git switch -c "<type>/<slug>"
```

- `<type>`: `feat` / `fix` / `refactor` / `docs` / `chore` (match the change)
- `<slug>`: short kebab-case summary, e.g. `feat/add-ripgrep`, `fix/install-typo`

If the branch already exists from a prior run, pick a new slug (append `-2`, etc.).

### 6. Learn the repo's conventions, then apply the edit

Before editing, read whatever the repository says about itself — `CLAUDE.md`,
`AGENTS.md`, `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE.md` — and check
`git log --oneline -20` for the commit message style actually in use. Follow them
over any habit of your own.

Make the requested change with the normal edit tools. Keep it focused — one logical
change per PR.

Run whatever check the repo defines (lint, test, typecheck) if one is obvious from
its config or CI workflow. Report failures rather than working around them.

### 7. Push

**With write access** (step 3 said `ADMIN` / `MAINTAIN` / `WRITE`):

```bash
git push -u origin "<branch>"
```

**Without write access** — fork first, and push the branch to the fork:

```bash
gh repo fork --remote --remote-name fork
git push -u fork "<branch>"
```

### 8. Open the PR

```bash
gh pr create --base <default-branch> --title "<type>: <summary>" --body "<why>"
```

Add `--repo <owner/repo>` when pushing from a fork, so the PR lands on the upstream
repository rather than the fork.

Write the body yourself — state what changed and why. Use `--fill` only when the
commit message already says everything the reviewer needs.

### 9. Report

Output the PR URL returned by `gh pr create`.

## Gotchas

- **Never touch the current checkout**: even when invoked from inside a checkout of
  the target repo, work in the ghq clone. This keeps behaviour identical on every
  terminal and avoids disturbing uncommitted work.
- **The default branch is not always `main`**: resolve it in step 3. Hardcoding
  `main` fails on `master` repos and on any repo using a release branch as default.
- **gh not authenticated**: step 8 fails cryptically. Verify with `gh auth status` in
  step 2 first.
- **`command -v ghq` is checked by exit code**: `|| mise use ...` only installs when
  truly missing.
- **`git pull --ff-only`**: fails loudly if the local clone diverged from origin (e.g.
  leftover commits on the default branch). If it fails, `git reset --hard
  origin/<default-branch>` after confirming there is nothing to keep.
- **Branch already exists**: `git switch -c` fails. Reuse it (`git switch <branch>`)
  only if it is yours and clean, otherwise choose a new slug.
- **A stale ghq clone of a fork**: if `ghq get` lands on a clone whose `origin` is
  your fork rather than upstream, `gh repo view` still describes upstream while
  `git push origin` goes to the fork. Check `git remote -v` when the PR base looks
  wrong.
