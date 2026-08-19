# skills

エージェント CLI (Claude Code / OpenCode / Cursor) 向けのスキル集。

## Install

```bash
npx skills add bmthd/skills
```

特定のスキルだけ入れる場合は `-s` で指定します。

```bash
npx skills add bmthd/skills -s worktree -s fix-pr
```

更新は `npx skills update` で行えます。

## Skills

| Skill | 用途 |
| --- | --- |
| [`commander`](skills/commander/SKILL.md) | メインセッションを指揮に徹させ、実作業をすべてサブエージェントに委譲する |
| [`dispatch-issues`](skills/dispatch-issues/SKILL.md) | GitHub Issue を検索・トリアージし、並列作業用に振り分ける |
| [`fix-pr`](skills/fix-pr/SKILL.md) | レビュー指摘・CI 失敗・コンフリクトを解消し、PR をマージ可能にする |
| [`merge-queue`](skills/merge-queue/SKILL.md) | 複数の PR を GitHub Merge Queue 相当の手順で順にマージする |
| [`update-repo`](skills/update-repo/SKILL.md) | 任意の GitHub リポジトリを、チェックアウトしていない端末からでも変更して PR を出す |
| [`worktree`](skills/worktree/SKILL.md) | 新しいブランチと git worktree を作り、隔離された作業場所を用意する |

## License

MIT
