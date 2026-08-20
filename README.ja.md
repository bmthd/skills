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

スキルは対象読者で分けています。`dev/` はソフトウェア開発向け、`utility/` は開発とは無関係な日常作業向けで、そのうち macOS 用が `utility/mac/` です。

### Development

| Skill | 日本語訳 | 用途 |
| --- | --- | --- |
| [`commander`](skills/dev/commander/SKILL.md) | [日本語](skills/dev/commander/SKILL.ja.md) | メインセッションを指揮に徹させ、実作業をすべてサブエージェントに委譲する |
| [`dispatch-issues`](skills/dev/dispatch-issues/SKILL.md) | [日本語](skills/dev/dispatch-issues/SKILL.ja.md) | GitHub Issue を検索・トリアージし、並列作業用に振り分ける |
| [`fix-pr`](skills/dev/fix-pr/SKILL.md) | [日本語](skills/dev/fix-pr/SKILL.ja.md) | レビュー指摘・CI 失敗・コンフリクトを解消し、PR をマージ可能にする |
| [`merge-queue`](skills/dev/merge-queue/SKILL.md) | [日本語](skills/dev/merge-queue/SKILL.ja.md) | 複数の PR を GitHub Merge Queue 相当の手順で順にマージする |
| [`update-repo`](skills/dev/update-repo/SKILL.md) | [日本語](skills/dev/update-repo/SKILL.ja.md) | 任意の GitHub リポジトリを、チェックアウトしていない端末からでも変更して PR を出す |
| [`worktree`](skills/dev/worktree/SKILL.md) | [日本語](skills/dev/worktree/SKILL.ja.md) | 新しいブランチと git worktree を作り、隔離された作業場所を用意する |

### Mac utilities

| Skill | 日本語訳 | 用途 |
| --- | --- | --- |
| [`import-youtube-music`](skills/utility/mac/import-youtube-music/SKILL.md) | [日本語](skills/utility/mac/import-youtube-music/SKILL.ja.md) | YouTube の楽曲をダウンロードし、タグとカバーアートを付けて macOS の Music.app ライブラリに取り込む |

各スキルには日本語訳 `SKILL.ja.md` が併置されています。frontmatter も訳してあるので、
エージェントがスキルを読み込む前に提示する `description` まで日本語で読めます。
エージェントが実際に読み込むのは英語版の `SKILL.md` だけで、日本語訳は内容を把握するための参考用です。

## License

MIT
