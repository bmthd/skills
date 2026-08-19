# skills

エージェント CLI (Claude Code / OpenCode / Cursor) 向けのスキル集。

[English version here](README.md)

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

| Skill | 日本語訳 | 用途 |
| --- | --- | --- |
| [`commander`](skills/commander/SKILL.md) | [日本語](skills/commander/SKILL.ja.md) | メインセッションを指揮に徹させ、実作業をすべてサブエージェントに委譲する |
| [`dispatch-issues`](skills/dispatch-issues/SKILL.md) | [日本語](skills/dispatch-issues/SKILL.ja.md) | GitHub Issue を検索・トリアージし、並列作業用に振り分ける |
| [`fix-pr`](skills/fix-pr/SKILL.md) | [日本語](skills/fix-pr/SKILL.ja.md) | レビュー指摘・CI 失敗・コンフリクトを解消し、PR をマージ可能にする |
| [`merge-queue`](skills/merge-queue/SKILL.md) | [日本語](skills/merge-queue/SKILL.ja.md) | 複数の PR を GitHub Merge Queue 相当の手順で順にマージする |
| [`update-repo`](skills/update-repo/SKILL.md) | [日本語](skills/update-repo/SKILL.ja.md) | 任意の GitHub リポジトリを、チェックアウトしていない端末からでも変更して PR を出す |
| [`worktree`](skills/worktree/SKILL.md) | [日本語](skills/worktree/SKILL.ja.md) | 新しいブランチと git worktree を作り、隔離された作業場所を用意する |

各スキルには日本語訳 `SKILL.ja.md` が併置されています。エージェントが読み込むのは
英語版の `SKILL.md` だけで、日本語訳は内容を把握するための参考用です。

## License

MIT
