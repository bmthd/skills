---
name: pair-dev
description: Use when the user wants to pair on a running app — start the local dev server, watch it together in an Orca browser tab, and fix what they point out one remark at a time while CI watching, merging, investigations, and repo-wide sweeps run in the background. Invoke as /pair-dev.
---

# Pair Dev

The user drives with remarks about the running app; you are the hands. Each remark becomes an Issue, a fix on its own branch, or a delegated job, and the conversation moves on to the next remark while delegates finish the slow parts. The user's attention is the scarce resource: keep every turn short, and keep anything that can wait off their path.

## 1. Start the session

1. Read the repository's own rules (`AGENTS.md`, `CLAUDE.md`) and find the dev command in its scripts.
2. List the ports already listening (`lsof -iTCP -sTCP:LISTEN -P`). Other worktrees often run their own dev servers; pick a free port and start yours in the background with that port fixed (for Vite, `--port <n> --strictPort`).
3. Poll the URL until it answers 200, then open it with `orca tab create --url <url> --json` (load the `orca-cli` skill for the browser commands). Keep the returned `browserPageId` as **your tab**.
4. Take one screenshot to confirm the page renders, and report the URL, the port and why it was chosen, and the current branch. Then ask what bothers them.

**Their tab is theirs.** The user looks at their own tab and may close yours. Read their tab only to see what they see (`tab list` → the active page, screenshot); drive, click, and resize only in your tab, and open a temporary tab when yours is gone. Close temporary tabs when done.

## 2. Handle each remark

Classify the remark first; the branch decides everything after it.

| Remark | Branch |
|---|---|
| "make this an Issue" | **Issue**: find the code responsible, then `gh issue create` with the current behaviour (with `file:line`), and the intended behaviour. Mark anything you inferred as inferred in your reply. |
| A visual or behaviour fix | **Fix** (below). |
| "PR it" | **Ship** (below). |
| The same pattern found across the codebase | Fix only the file in front of you; offer the rest as a **sweep** (see [delegation.md](delegation.md)). |
| Watching CI, merging, investigating a failure | Delegate (see [delegation.md](delegation.md)). |

### Fix

1. Branch from the fresh default branch, one topic per branch: `git fetch && git switch -c <topic> origin/<default>`. Never stack a new topic on an unmerged one.
2. Find the cause before editing. For layout bugs, measure in your tab (`orca eval` with `getBoundingClientRect` / `getComputedStyle`) before and after the interaction that misbehaves; the numbers name the cause.
3. When the fix has a design choice the user owns (what a warning looks like, which buttons a dialog has), ask once with `AskUserQuestion`, previews included, recommended option first. Everything else, decide.
4. Build with the UI library's components. Search its exports before composing primitives (`Box` + `display="flex"` is `Flex`; a hand-built `<table>` is the library's table). When two components fit, compare what each costs (build both and diff the chunk sizes) and pick the lighter one that does the job.
5. Tests cover **behaviour** only: what gets saved, where the user lands, what is created. Write them first and watch them fail. The look (colours, spacing, button order, which button exists) and the library's own features (a dialog closing on Escape) are the user's to check by eye; leave them out of tests.
6. A refactor that must not change the look: record the computed styles of the affected elements before the change and diff them after. Report "identical" or the exact differences.
7. Run the repository's lint, format, typecheck, and test commands. When a test fails, check whether it also fails on the default branch before calling it yours or not yours.
8. Report in a few lines: what changed with `file:line`, what you verified, what you did not, and the branch with its uncommitted state. End by asking for the next remark.

### Ship

Commit in the repository's message style, push, and open the PR from its template, linking each changed page in review notes. Then hand the PR to a delegate to watch and merge, and return to the next remark. Mention any open PR that touches the same files, since one of them will conflict.

## 3. Keep the loop safe

- **Stash is a trap in a pairing session.** Comparing two builds by stashing your work risks leaving it in the stash. Copy the file aside instead, swap, measure, copy back, and confirm with `git diff --stat` that your change is still there.
- **The dev server restarts** when you switch branches or pull config changes; poll for 200 before saying it is down.
- **Orca's runtime drops connections** now and then (`runtime_unavailable`). Retry the same command once or twice; if `browser_tab_not_found`, re-list tabs rather than reusing the id.
- Each correction the user makes about how to work (what to test, which component, where something lives) is a durable preference: save it to memory so the next session starts with it.
