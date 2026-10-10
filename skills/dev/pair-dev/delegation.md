# Delegation

Slow or wide work runs in the background so the pairing loop never waits on it. Every delegate gets the same three things in its brief: **an isolated checkout** (its own git worktree from the fresh default branch; the user's checkout and dev server are off-limits), **a stop condition** (when to stop and report instead of acting), and **a report shape** (what it hands back, in the user's language).

Relay each report in a few lines, with the decisions it needs as multiple-choice options. Delegates that hold context (the one that found a root cause, the one running a merge queue) are continued by messaging them, not replaced by a fresh one.

## Watch and merge a PR

A background subagent:

1. Waits for checks (`gh pr checks <n> --watch`).
2. After the preview job, confirms every review-notes link answers 200 (following redirects).
3. Squash-merges without deleting the branch, since the user's checkout may have it checked out.

Stop and report when a check fails for a reason that is not plainly the PR's own simple mistake, or when merging needs to bypass branch protection (`--admin` is the user's call, never the delegate's).

Several PRs form a **merge queue**: give the order up front, and add new PRs to the running delegate's tail. Two PRs whose CI each needs the other's fix deadlock the queue; resolve it by moving one PR's commit into the other, merging that one, and closing the emptied PR with a comment.

## Investigate a failure

A background subagent reproduces the failure, finds the root cause with evidence (`file:line`), and checks whether it also fails on the default branch. It fixes only small, clearly-caused failures (for example, a test that depends on today's date gets a fixed clock) and opens a separate PR for them. It stops and reports with options and a recommendation when the fix needs a product decision, the cause is in another open PR, or the fix spreads across many files. When the user picks an option, send it back to the same delegate.

## Sweep the codebase

A repo-wide mechanical change goes to a separate coding agent working in its own worktree, in a new pane of the terminal multiplexer, so the user can glance at it.

The brief states:

- the pattern to replace
- what is in scope and what is out
- which tests to leave alone
- the known failures it may ignore
- "show me the plan first; once approved, carry on through opening the PR without merging"

Then:

1. Create the worktree from the fresh default branch, start the agent in a pane there, and send it the brief.
2. Wait until the agent goes idle, then read its pane for the plan.
3. Check the plan against the brief, and send the approval or the correction to the pane.
4. Label the pane or worktree with its state so the user can see it, then leave it to run on its own.

The sweep's PR joins the merge queue like any other.
