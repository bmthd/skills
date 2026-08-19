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

### 言語を選ぶ

各スキルには英語版と日本語版があり、インストール時にどちらを入れるか選べます。
`-s` を付けずに実行すると一覧から選択でき、日本語版は `-ja` 付きの名前で並びます。

```bash
# 日本語版だけを入れる
npx skills add bmthd/skills -s worktree-ja -s fix-pr-ja
```

日本語版は英語版の忠実な翻訳で、内容は同じです。読みやすい方を選んでください。
呼び出し名も `/worktree-ja` のように `-ja` が付きます。

## Skills

| Skill | 日本語版 | 用途 |
| --- | --- | --- |
| [`commander`](skills/commander/SKILL.md) | [`commander-ja`](skills/commander-ja/SKILL.md) | メインセッションを指揮に徹させ、実作業をすべてサブエージェントに委譲する |
| [`dispatch-issues`](skills/dispatch-issues/SKILL.md) | [`dispatch-issues-ja`](skills/dispatch-issues-ja/SKILL.md) | GitHub Issue を検索・トリアージし、並列作業用に振り分ける |
| [`fix-pr`](skills/fix-pr/SKILL.md) | [`fix-pr-ja`](skills/fix-pr-ja/SKILL.md) | レビュー指摘・CI 失敗・コンフリクトを解消し、PR をマージ可能にする |
| [`merge-queue`](skills/merge-queue/SKILL.md) | [`merge-queue-ja`](skills/merge-queue-ja/SKILL.md) | 複数の PR を GitHub Merge Queue 相当の手順で順にマージする |
| [`update-repo`](skills/update-repo/SKILL.md) | [`update-repo-ja`](skills/update-repo-ja/SKILL.md) | 任意の GitHub リポジトリを、チェックアウトしていない端末からでも変更して PR を出す |
| [`worktree`](skills/worktree/SKILL.md) | [`worktree-ja`](skills/worktree-ja/SKILL.md) | 新しいブランチと git worktree を作り、隔離された作業場所を用意する |

## License

MIT
