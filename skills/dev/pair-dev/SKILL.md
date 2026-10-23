---
name: pair-dev
description: Use when the user wants to pair on a running app — launch it locally, watch it together in a shared view, and fix what they point out one remark at a time while CI/Preview watching, investigations, and repo-wide sweeps run in the background. Invoke as /pair-dev.
---

# Pair Dev

The user points at the running app; you do the work. Slow work runs in the background while you move on to the next remark.

## Start

Launch the app locally without colliding with other worktrees, and open it in a **shared view** the user can watch too (a browser tab, simulator, emulator, or window, in a pane of the terminal multiplexer or driven by your automation tool). Confirm it renders, then ask what bothers them. Work in your own view and leave theirs alone.

## Each remark

- **"Make it an Issue"**: file it with the current and intended behaviour.
- **"Fix this"**: one topic per branch, cut from the fresh default branch. Ask the user only about design choices that are theirs to make, then fix it following the repository's own conventions, and report the result.
- **A choice with more than one fair answer**: before changing code, lay the options side by side on a page the user can open (an artifact), at real size and on every screen the change reaches, with your recommendation. Build the one they pick.
- **"PR it"**: open the PR, hand it to a delegate to watch CI and Preview and report the results, and return to the next remark.
- **The same problem across the codebase**: fix the case in front of you and offer the rest as a sweep.

## Merge authorization

Merge only when the user explicitly requests merging the relevant PRs. A request to create a PR authorizes creation and CI/Preview monitoring only. Skill invocation, green checks, and ambiguous completion requests such as "finish it" do not authorize merging or enabling auto-merge. Without explicit merge authorization, leave the PR open and report its status.

## Delegate

Give every delegate its own worktree, a condition to stop and report, and the user's language for the report. State the delegate's merge authority explicitly: monitoring only by default; merging only the PRs covered by the user's explicit merge request. Delegation cannot expand that authority. Relay their reports to the user, with the decisions they need as options.

- **Watch CI and Preview**: a subagent waits for CI and Preview, reports results or failures, and leaves the PR open.
- **Explicitly requested merge**: a subagent may merge only the authorized PRs in the order given after checks pass, stopping when a failure or a merge needs the user's judgement.
- **Investigate**: a subagent finds the root cause of a failure, fixes it only when the fix is small and clear, and otherwise reports options with a recommendation.
- **Sweep**: a separate coding agent in its own worktree and multiplexer pane makes the repo-wide change. Approve its plan, then let it run through opening the PR.
