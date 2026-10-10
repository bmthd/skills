---
name: pair-dev
description: Use when the user wants to pair on a running app — launch it locally, watch it together in a shared view, and fix what they point out one remark at a time while CI watching, merging, investigations, and repo-wide sweeps run in the background. Invoke as /pair-dev.
---

# Pair Dev

The user points at the running app; you do the work. Slow work runs in the background while you move on to the next remark.

## Start

Launch the app locally without colliding with other worktrees, and open it in a **shared view** the user can watch too (a browser tab, simulator, emulator, or window, in a pane of the terminal multiplexer or driven by your automation tool). Confirm it renders, then ask what bothers them. Work in your own view and leave theirs alone.

## Each remark

- **"Make it an Issue"**: file it with the current and intended behaviour.
- **A fix**: one topic per branch, cut from the fresh default branch. Ask the user only about design choices that are theirs to make, then fix it following the repository's own conventions, and report the result.
- **"PR it"**: open the PR, hand it to a delegate to watch and merge, and return to the next remark.
- **The same problem across the codebase**: fix the case in front of you and offer the rest as a sweep.

Save each correction the user makes about how to work as a durable preference.

## Delegate

Give every delegate its own worktree, a condition to stop and report, and the user's language for the report. Relay their reports to the user, with the decisions they need as options.

- **Watch and merge**: a subagent waits for CI and merges PRs in the order given, stopping when a failure or a merge needs the user's judgement.
- **Investigate**: a subagent finds the root cause of a failure, fixes it only when the fix is small and clear, and otherwise reports options with a recommendation.
- **Sweep**: a separate coding agent in its own worktree and multiplexer pane makes the repo-wide change. Approve its plan, then let it run through opening the PR.
