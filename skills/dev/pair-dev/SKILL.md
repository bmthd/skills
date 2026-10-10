---
name: pair-dev
description: Use when the user wants to pair on a running app — launch it locally, watch it together in a shared view, and fix what they point out one remark at a time while CI watching, merging, investigations, and repo-wide sweeps run in the background. Invoke as /pair-dev.
---

# Pair Dev

The user drives with remarks about the running app; you are the hands. Each remark becomes an Issue, a fix on its own branch, or a delegated job, and the conversation moves on to the next remark while delegates finish the slow parts. The user's attention is the scarce resource: keep every turn short, and keep anything that can wait off their path.

The **shared view** is wherever the running app is visible to both of you: a browser tab, a simulator or emulator, a desktop window, opened in a pane of the terminal multiplexer or driven by your automation tool.

## 1. Start the session

1. Read the repository's agent instructions (`AGENTS.md` or its equivalent) and find how it runs the app in development.
2. Check what other worktrees already hold (ports, simulator devices, emulators). Pick a free one and launch yours in the background, pinned to it so it cannot silently drift onto another.
3. Wait until the app is ready, then open it in the shared view. Keep the id of what you opened as **your view**.
4. Capture one screenshot to confirm it renders, and report where the app is running, which resource you picked and why, and the current branch. Then ask what bothers them.

**Their view is theirs.** The user watches their own view and may close yours. Read theirs only to see what they see; interact, resize, and navigate only in yours, and open a temporary one when yours is gone. Close temporary views when done.

## 2. Handle each remark

Classify the remark first; the branch decides everything after it.

| Remark | Branch |
|---|---|
| "make this an Issue" | **Issue**: find the code responsible, then file it with the current behaviour (with `file:line`) and the intended behaviour. Mark anything you inferred as inferred in your reply. |
| A visual or behaviour fix | **Fix** (below). |
| "PR it" | **Ship** (below). |
| The same pattern found across the codebase | Fix only the file in front of you; offer the rest as a **sweep** (see [delegation.md](delegation.md)). |
| Watching CI, merging, investigating a failure | Delegate (see [delegation.md](delegation.md)). |

### Fix

1. Branch from the fresh default branch, one topic per branch: `git fetch && git switch -c <topic> origin/<default>`. Never stack a new topic on an unmerged one.
2. Find the cause before editing. For layout bugs, measure in your view before and after the interaction that misbehaves (element bounds and computed styles, read through your automation tool or the platform's inspector); the numbers name the cause.
3. When the fix has a design choice the user owns (what a warning looks like, which actions a dialog offers), ask once as a multiple-choice question (the harness's structured question tool when it has one), previews included, recommended option first. Everything else, decide.
4. Build with the project's UI kit. Search what it exports before composing primitives yourself. When two components fit, compare what each costs (the size and dependencies each adds to the build) and pick the lighter one that does the job.
5. Tests cover **behaviour** only: what gets saved, where the user lands, what is created. Write them first and watch them fail. The look (colours, spacing, order, which controls exist) and the UI kit's own features are the user's to check by eye; leave them out of tests.
6. A refactor that must not change the look: record the measured bounds and styles of the affected elements before the change and diff them after. Report "identical" or the exact differences.
7. Run the repository's lint, format, typecheck, and test commands. When a test fails, check whether it also fails on the default branch before calling it yours or not yours.
8. Report in a few lines: what changed with `file:line`, what you verified, what you did not, and the branch with its uncommitted state. End by asking for the next remark.

### Ship

Commit in the repository's message style, push, and open the PR from its template, saying where in the app a reviewer sees the change. Then hand the PR to a delegate to watch and merge, and return to the next remark. Mention any open PR that touches the same files, since one of them will conflict.

## 3. Keep the loop safe

- **Stash is a trap in a pairing session.** Comparing two builds by stashing your work risks leaving it in the stash. Copy the file aside instead, swap, measure, copy back, and confirm with `git diff --stat` that your change is still there.
- **The running app restarts** when you switch branches or pull config changes; wait for it to be ready again before saying it is down.
- **The connection to the shared view drops** now and then. Retry the same command once or twice; when a view is reported missing, list what is open again rather than reusing the old id.
- Each correction the user makes about how to work (what to test, which component, where something lives) is a durable preference: save it to memory so the next session starts with it.
