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

Skills are grouped by who needs them: `dev/` is for software work, `utility/` is for everyday tasks that have nothing to do with code — `utility/mac/` being the macOS ones.

### Development

| Skill | 日本語訳 | Purpose |
| --- | --- | --- |
| [`commander`](skills/dev/commander/SKILL.md) | [日本語](skills/dev/commander/SKILL.ja.md) | Keep the main session on command duty and delegate every piece of hands-on work to subagents |
| [`dispatch-issues`](skills/dev/dispatch-issues/SKILL.md) | [日本語](skills/dev/dispatch-issues/SKILL.ja.md) | Search and triage GitHub Issues, then hand them out as parallel work |
| [`fix-pr`](skills/dev/fix-pr/SKILL.md) | [日本語](skills/dev/fix-pr/SKILL.ja.md) | Resolve review comments, failing checks, and conflicts to make a PR mergeable |
| [`merge-queue`](skills/dev/merge-queue/SKILL.md) | [日本語](skills/dev/merge-queue/SKILL.ja.md) | Merge several PRs one at a time, the way GitHub's Merge Queue would |
| [`update-repo`](skills/dev/update-repo/SKILL.md) | [日本語](skills/dev/update-repo/SKILL.ja.md) | Change any GitHub repository and open a PR, even from a terminal where it is not checked out |
| [`worktree`](skills/dev/worktree/SKILL.md) | [日本語](skills/dev/worktree/SKILL.ja.md) | Create a new branch and git worktree as an isolated place to work |

### Mac utilities

| Skill | 日本語訳 | Purpose |
| --- | --- | --- |
| [`import-youtube-music`](skills/utility/mac/import-youtube-music/SKILL.md) | [日本語](skills/utility/mac/import-youtube-music/SKILL.ja.md) | Download a track from YouTube and add it to the macOS Music.app library, tagged and with cover art |

Every skill ships a Japanese translation next to it as `SKILL.ja.md`, frontmatter
included — the `description` an agent shows before it loads a skill is translated
too. Agents still load the English `SKILL.md`; the translation is there to help you
read it.

## License

MIT
