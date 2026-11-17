---
name: move-to-worktree
description: Use when the user wants this conversation moved to a new worktree and resumed there with its whole context, not summarised for another agent. Invoke as /move-to-worktree [what to do next].
argument-hint: "[what to do next]"
---

# Move to Worktree

Move this very conversation into a new worktree: the same session, resumed there with everything said so far. Nothing is summarised; the user carries on talking to the same context in its new place, and this copy stops.

## Steps

1. **Create the worktree** with the terminal multiplexer, from the fresh default branch, linked to the Issue or PR the work is about. Bring along any uncommitted changes the work depends on.
2. **Resume this session there**: in a new pane of the multiplexer at the worktree, start the same agent and model, resuming this session by its ID. Fork it into a new session ID when the agent can, so the two copies never write to one record.
3. **Hand it the next step** as its first message: the user's argument, or else what you were about to do.
4. **Confirm** the resumed session remembers this conversation and has started on the next step. Report the worktree path, the branch, and the pane, then stop working on the task here.
