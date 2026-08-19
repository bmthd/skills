# skills

Skills for agent CLIs (Claude Code / OpenCode / Cursor).

[日本語版はこちら](README.ja.md)

## Install

```bash
npx skills add bmthd/skills
```

Pass `-s` to install only the skills you want.

```bash
npx skills add bmthd/skills -s worktree -s fix-pr
```

Update them with `npx skills update`.

## Skills

| Skill | 日本語訳 | Purpose |
| --- | --- | --- |
| [`commander`](skills/commander/SKILL.md) | [日本語](skills/commander/SKILL.ja.md) | Keep the main session on command duty and delegate every piece of hands-on work to subagents |
| [`dispatch-issues`](skills/dispatch-issues/SKILL.md) | [日本語](skills/dispatch-issues/SKILL.ja.md) | Search and triage GitHub Issues, then hand them out as parallel work |
| [`fix-pr`](skills/fix-pr/SKILL.md) | [日本語](skills/fix-pr/SKILL.ja.md) | Resolve review comments, failing checks, and conflicts to make a PR mergeable |
| [`merge-queue`](skills/merge-queue/SKILL.md) | [日本語](skills/merge-queue/SKILL.ja.md) | Merge several PRs one at a time, the way GitHub's Merge Queue would |
| [`update-repo`](skills/update-repo/SKILL.md) | [日本語](skills/update-repo/SKILL.ja.md) | Change any GitHub repository and open a PR, even from a terminal where it is not checked out |
| [`worktree`](skills/worktree/SKILL.md) | [日本語](skills/worktree/SKILL.ja.md) | Create a new branch and git worktree as an isolated place to work |

Every skill ships a Japanese translation next to it as `SKILL.ja.md`. Agents only
load the English `SKILL.md`; the translation is there to help you read it.

## License

MIT
