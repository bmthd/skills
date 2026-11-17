---
name: move-to-worktree
description: Use when the user wants the current conversation's work moved to a new worktree and carried on there by a fresh agent. Invoke as /move-to-worktree [where to start].
argument-hint: "[where the new agent starts]"
---

# Move to Worktree

Move the work of this conversation to a new worktree, where a fresh agent carries it on. Once it is working, the user talks to it, and you stop.

## Steps

1. **Create the worktree** with the terminal multiplexer, from the fresh default branch, linked to the Issue or PR the work is about.
2. **Launch the agent** there: the same agent and model as yourself, unless the user names another.
3. **Hand over the brief** as its first prompt. The agent starts cold, so the brief carries:
   - the task, by its Issue or PR when one exists; point at what they record instead of restating it
   - what the user decided in this conversation, and what is still open
   - what you found: files, functions, constraints
   - the path to this conversation's transcript, when the harness keeps one
   - where to start: the user's argument, or else the next step
   - the conditions the user set, such as when to stop for their review, and the language to reply in
4. **Confirm** the prompt arrived and the agent is working. Report the worktree path, the branch, and where to find the agent.
