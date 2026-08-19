# Update Repo

> [`SKILL.md`](SKILL.md) の日本語訳。エージェントが読み込むのは英語版の `SKILL.md` で、
> この訳は内容を理解するための参考用。
>
> **description**: 任意の GitHub リポジトリを変更して PR を出したいときに使う。対象リポジトリをチェックアウトしていない端末からでも動く。未取得なら ghq で clone し、最新のデフォルトブランチから分岐し、書き込み権限がなければ自動で fork して PR を作る。/update-repo <owner/repo> <change> で呼び出す。

任意の端末から、任意の GitHub リポジトリに変更を加えてプルリクエストを出す。
常に ghq 管理下のクローンで作業するため、どこで実行しても挙動が同じで、
今いるチェックアウトを一切乱さない。

## 手順 (厳密に従うこと)

### 1. 引数を解釈する

`args` の最初のトークンが `owner/repo` 形式 (または GitHub の完全な URL) なら、それが対象リポジトリ。
それ以降がすべて「加える変更」。

- 最初のトークンが `owner/repo` でない場合: どのリポジトリを変更するかユーザーに尋ねる。カレントディレクトリから推測しない
  — このスキルはどこからでも実行される前提なので、現在のチェックアウトは対象について何も語らない。
- リポジトリはあるが変更内容がない場合: 何を変更するか尋ねる。

### 2. 事前確認: gh auth と ghq

```bash
gh auth status
```

`gh auth status` が失敗したら、そこで停止し、`! gh auth login` を実行するようユーザーに伝えて待つ。

```bash
command -v ghq || mise use -g ghq@latest
```

`mise use -g ghq@latest` が解決できない場合は `mise use -g ubi:x-motemen/ghq` にフォールバックする。

### 3. リポジトリの事実を確認する

デフォルトブランチが `main` だと決めつけない。そこに push できるとも決めつけない。

```bash
gh repo view <owner/repo> --json defaultBranchRef,viewerPermission
```

- `defaultBranchRef.name` — PR のベースブランチ。
- `viewerPermission` — `ADMIN` / `MAINTAIN` / `WRITE` なら origin へ直接ブランチを push できる。
  `TRIAGE` / `READ` / `NONE` なら fork が必要 (手順 7)。

このコマンドが失敗する場合、リポジトリが存在しないかこのアカウントから見えていない。
その旨を報告して停止する。

### 4. リポジトリを取得 (clone または更新) する

```bash
ghq get -u github.com/<owner>/<repo>
repo="$(ghq list --full-path --exact github.com/<owner>/<repo>)"
cd "$repo"
```

### 5. ベースブランチを同期して作業ブランチを作る

常に最新のデフォルトブランチから分岐する。デフォルトブランチを直接編集しない、push しない。

```bash
git switch <default-branch>
git pull --ff-only
git switch -c "<type>/<slug>"
```

- `<type>`: `feat` / `fix` / `refactor` / `docs` / `chore` (変更内容に合わせる)
- `<slug>`: 短いケバブケースの要約。例: `feat/add-ripgrep`, `fix/install-typo`

以前の実行でブランチが既にある場合は、別のスラグを選ぶ (`-2` を付けるなど)。

### 6. リポジトリの慣習を学んでから編集する

編集の前に、リポジトリ自身の説明 — `CLAUDE.md`、`AGENTS.md`、`CONTRIBUTING.md`、
`.github/PULL_REQUEST_TEMPLATE.md` — を読み、`git log --oneline -20` で実際に使われている
コミットメッセージのスタイルを確認する。自分の癖よりそれらを優先する。

通常の編集ツールで依頼された変更を加える。範囲は絞る — 1 PR につき 1 つの論理的な変更。

設定や CI ワークフローから明らかなチェック (lint / test / typecheck) があれば実行する。
失敗は回避せずに報告する。

### 7. push する

**書き込み権限がある場合** (手順 3 が `ADMIN` / `MAINTAIN` / `WRITE`):

```bash
git push -u origin "<branch>"
```

**書き込み権限がない場合** — 先に fork し、そこへブランチを push する:

```bash
gh repo fork --remote --remote-name fork
git push -u fork "<branch>"
```

### 8. PR を作成する

```bash
gh pr create --base <default-branch> --title "<type>: <summary>" --body "<why>"
```

fork から push した場合は `--repo <owner/repo>` を付け、fork ではなく上流リポジトリに PR が向くようにする。

本文は自分で書く — 何を変えたか、なぜかを述べる。`--fill` は、コミットメッセージだけで
レビュアーに必要な情報が揃っている場合にのみ使う。

### 9. 報告する

`gh pr create` が返した PR の URL を出力する。

## 落とし穴

- **今のチェックアウトには触れない**: 対象リポジトリのチェックアウト内で呼ばれた場合でも、ghq クローンで作業する。
  どの端末でも挙動を同じに保ち、未コミットの作業を乱さないため。
- **デフォルトブランチは常に `main` とは限らない**: 手順 3 で解決する。`main` を決め打ちすると
  `master` のリポジトリや、リリースブランチをデフォルトにしているリポジトリで失敗する。
- **gh が未認証**: 手順 8 が分かりにくい形で失敗する。先に手順 2 の `gh auth status` で確認する。
- **`command -v ghq` は終了コードで判定される**: `|| mise use ...` は本当に無いときだけインストールする。
- **`git pull --ff-only`**: ローカルクローンが origin から分岐していると (デフォルトブランチに
  取り残されたコミットがあるなど) はっきり失敗する。失敗したら、残すものが無いことを確認したうえで
  `git reset --hard origin/<default-branch>` する。
- **ブランチが既に存在する**: `git switch -c` は失敗する。自分のもので、かつクリーンな場合にのみ
  再利用する (`git switch <branch>`)。それ以外は新しいスラグを選ぶ。
- **fork の古い ghq クローン**: `ghq get` が、`origin` が上流ではなく自分の fork を指すクローンに当たると、
  `gh repo view` は上流を説明するのに `git push origin` は fork へ向かう。PR のベースがおかしいときは
  `git remote -v` を確認する。
