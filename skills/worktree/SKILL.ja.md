# Worktree

指定されたブランチ名から、新しいブランチと worktree を作成する。

## 手順 (厳密に従うこと)

### 1. 引数を検証する

`args` からブランチ名を取得する。ブランチ名が渡されていなければユーザーに尋ねる。

### 2. リポジトリ情報を取得する

```bash
# リポジトリルートを取得する
git rev-parse --show-toplevel

# リポジトリ名 (ディレクトリ名) を取得する
basename "$(git rev-parse --show-toplevel)"
```

### 3. スラグを算出する

ブランチ名から worktree のディレクトリ名 (スラグ) を生成する。

- `/` を `-` に置き換える
- その他の特殊文字 (スペース、`:` など) も `-` に置き換える

例: `feature/add-button` -> `feature-add-button`

### 4. worktree のパスを決める

```
{repo_root}/../{repo_name}.worktrees/{slug}
```

例: リポジトリが `/home/user/my-project` にある場合
-> `/home/user/my-project.worktrees/feature-add-button`

### 5. ブランチの存在を確認して worktree を作成する

ブランチの状態に応じてコマンドを選ぶ。

```bash
# ローカルにブランチがあるか確認する
git branch --list "{branch_name}"

# リモートにブランチがあるか確認する
git ls-remote --heads origin "{branch_name}"
```

| ローカル | リモート | コマンド |
|----------|----------|----------|
| なし     | なし     | `git worktree add "{path}" -b "{branch}"` |
| なし     | あり     | `git fetch origin "{branch}" && git worktree add "{path}" --track -b "{branch}" "origin/{branch}"` |
| あり     | -        | `git worktree add "{path}" "{branch}"` |

- **ローカルにもリモートにもない**: `-b` で新しいブランチを作る
- **リモートのみ**: 先に `git fetch` し、`--track -b` で追跡ブランチとして作る
- **ローカルにある**: リモートの状態に関わらず、`-b` を付けずに既存ブランチをチェックアウトする

### 6. 完了を報告する

作成した worktree のパスとブランチ名をユーザーに伝える。

## 落とし穴

- **worktree のパスが既に存在する**: `git worktree add` は失敗する。`rm -rf` を実行する前にユーザーへ確認するか、別のスラグを使う。
- **リモート URL からリポジトリ名を取る必要はない**: `basename $(git rev-parse --show-toplevel)` で十分。
- **相対パスではなく絶対パスを使う**: `git worktree add` には常に絶対パスを渡す。
- **`git ls-remote` は終了コードではなく出力で判定する**: 「リモートにブランチがない」ことは、終了コードではなく stdout が空かどうかで判定する。
