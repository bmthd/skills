# Import YouTube Music

yt-dlp で音声をダウンロードし、まともな MP4 コンテナに詰め直し、タグと正方形のカバーを書き込んでから、Music.app に渡す。

## 概要

うまくいくかどうかは、次の 2 点で決まる。

1. ライブラリには既に規約がある。自分で発明せず、既存のトラックから読み取る。
2. ローカルで再生できるファイルでも、iCloud ミュージックライブラリには弾かれることがある。タガーではなく Music.app 越しに検証する。

## 使いどころ

- YouTube の楽曲を手元の Music.app ライブラリに入れたいとき
- 既存のトラックを指して「これと同じ形式で」と言われたとき
- トラックが **0:00** と表示される、ビットレートが無い、iCloud 同期が **不適格** になっている
- 取り込み済みトラックのアーティスト・アルバム・アートワークを直したいとき
- 対象外: ポッドキャスト、動画のまま保存したい場合、実際に再エンコードが要る場合

## 前提

macOS と、恒久的なインストールが不要な 3 つのツール。

```bash
uvx yt-dlp --version                                     # ダウンローダ
uv run --with imageio-ffmpeg python -c \
  'import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())'   # static ffmpeg
sips --help                                              # macOS 標準
```

最後のコマンドはパスを出力するので `$FF` に控えておく。**ffmpeg は任意ではなく必須**——手順 3 を参照。ファイルが確定するまでは作業用ディレクトリで進める。

## 1. 対象の動画を特定する

```bash
uvx yt-dlp --flat-playlist \
  --print "%(id)s | %(duration)s | %(channel)s | %(title)s" "ytsearch10:曲名"
```

クレジットされたアーティスト本人による原盤を優先する。判断に迷ったら再生時間で切る。1 時間耐久、リミックス、字幕付き、ファンによる再アップロードが検索結果を埋めるが、どれも求められている音源ではない。

「これと同じ形式で」と既存トラックを指定された場合は、そのトラックの出典も特定する。再生時間が一致すれば、ライブラリのコピーがどのアップロード由来かを確認できる。

## 2. ダウンロードする

```bash
uvx yt-dlp -f "bestaudio[ext=m4a]/bestaudio" \
  --write-info-json --write-thumbnail -o "track.%(ext)s" "https://www.youtube.com/watch?v=ID"
```

以降を安く済ませる鍵が `--write-info-json` にある。タイトル、チャンネル、説明文（歌詞が載っていることが多い）、サムネイルの URL が、すべてこの 1 ファイルから取れる。

## 3. リマックスする（省略しない）

yt-dlp は次の警告を出す。

```text
WARNING: writing DASH m4a. Only some players support this container.
         Install ffmpeg to fix this automatically
```

**Music.app は、この「対応していないプレイヤー」の側である。** DASH フラグメント化された m4a は取り込めるし再生もできるが、Music が尺を読み取れない。結果としてトラックは **0:00** と表示され、ビットレートも空になり、ミュージックライブラリの同期は **不適格** と判定して永久にアップロードしない。コンテナを書き直す。

```bash
"$FF" -hide_banner -loglevel warning -y -i track.m4a \
  -c:a copy -movflags +faststart -f mp4 "TITLE.m4a"
"$FF" -hide_banner -i "TITLE.m4a" 2>&1 | grep Duration   # 実際の尺が出ること
```

`-c:a copy` はコンテナの書き直しであり、音声バイト列は同一、再エンコード無し、サイズも変わらない。

## 4. タグを決める

| アトム | 項目 | 決め方 |
|---|---|---|
| `©nam` | タイトル | 曲名のみ。角括弧タグとアーティスト表記を落とす |
| `©ART` / `aART` | アーティスト / アルバムアーティスト | 投稿者名ではなく**クレジットされたアーティスト** |
| `©alb` | アルバム | シングルなら曲名。*シリーズ*タグは残し、*フォーマット*タグは落とす |
| `©gen` | ジャンル | 曲そのものから判断する |
| `©lyr` | 歌詞 | 説明文に歌詞欄がある場合はそこから |
| `covr` | アートワーク | 正方形 JPEG、1024×1024（手順 5） |

値を決める前に、ライブラリ側の規約を読む。

```bash
ls -R ~/Music/Music/Media.localized/Music/
uv run --with mutagen mutagen-inspect "<既存トラック>.m4a"
```

`Music/<アルバムアーティスト>/<アルバム>/<タイトル>.m4a` という構造が、このユーザーのタグ付け方をそのまま示している。写すのは*形*——どのアトムを埋めるか、歌詞を埋め込むか、カバーの寸法——であって、*値*ではない。参照トラックのアーティストは、あくまでその曲のアーティストである。

動画タイトルは、メタデータ欄よりもタイトル内にアーティストを埋め込んでいることが多い。

- `<タグ> 曲名 / アーティスト名` — 区切りの後ろがアーティストであり、タイトルの一部ではない。
- *動画のフォーマット*を示す角括弧タグ（公式動画マーカー、解像度表記）は雑音なので削る。*シリーズ*を示すタグはアルバム側に置く。
- チャンネルは投稿者であり、リミックス垢・レーベル・転載者であることも多い。他にクレジットが無いときだけアーティストとして扱う。

歌詞は打ち直さず、説明文から機械的に取り出す。

```bash
jq -r '.description' track.info.json | awk 'f {print} /^Lyrics:|^歌詞/ {f=1}' > lyrics.txt
```

そもそも歌詞欄を持たない動画のほうが多い。どちらの目印にもマッチしなければファイルは空になるが、それは失敗ではなく通常の状態である。空のタグを書き込まず、タグ自体を付けないままにする。手順 6 側で番人を入れてある。

## 5. カバーアート

1024×1024 の JPEG を目標にする。`sips -c H W` は中央から切り出す。

```bash
curl -sL -o thumb.jpg "https://i.ytimg.com/vi/ID/maxresdefault.jpg"   # 1280x720
cp thumb.jpg cover.jpg
sips -c 720 720 cover.jpg                     # 中央で正方形に
sips -z 1024 1024 cover.jpg
sips -s format jpeg -s formatOptions 95 --out cover.jpg cover.jpg
```

**埋め込む前に必ず結果を目で見る。** `sips -Z 500 --out preview.jpg cover.jpg` でプレビューを作って開く。16:9 のサムネイルは、被写体が中央にあれば中央切り出しがきれいに決まるが、横長の構図や端に文字がある絵では破綻する。切り出しで絵が壊れるなら、そのまま出さずにそう伝えて別の素材を選ぶ。

## 6. タグを書き込む

```bash
uv run --with mutagen python - "TITLE.m4a" <<'PY'
import pathlib, sys
from mutagen.mp4 import MP4, MP4Cover

path = sys.argv[1]
a = MP4(path)
a["\xa9nam"] = ["TITLE"]
a["\xa9ART"] = ["ARTIST"]
a["aART"] = ["ARTIST"]
a["\xa9alb"] = ["ALBUM"]
a["\xa9gen"] = ["GENRE"]
a["covr"] = [MP4Cover(pathlib.Path("cover.jpg").read_bytes(), imageformat=MP4Cover.FORMAT_JPEG)]
a.pop("\xa9too", None)  # yt-dlp が "Google" を残している

# 手順 4 が中身を出したときだけ書く。歌詞欄が無い説明文のほうが多く、
# ファイルが無ければ落ち、空ならば空のタグを書き込んでしまう。
lyrics = pathlib.Path("lyrics.txt")
text = lyrics.read_text(encoding="utf-8").strip() if lyrics.is_file() else ""
if text:
    a["\xa9lyr"] = [text]

a.save()

for k, v in sorted(MP4(path).items()):
    print(k, "=", f"{len(v[0])} bytes" if k == "covr" else v)
PY
```

書き込んだタグを読み直して出力することで、書き込み自体が検証を兼ねる。

## 7. 取り込む

仕上がったファイルを Music.app に渡す。

```bash
osascript -e 'tell application "Music" to add POSIX file "/absolute/path/TITLE.m4a"'
```

Music はこれを `~/Music/Music/Media.localized/Music/<アルバムアーティスト>/<アルバム>/<タイトル>.m4a` に**コピー**する。

## 8. Music.app 越しに検証する

コンテナ由来の失敗を捕まえるのがこの手順である。タグ検査ツールは、Music が読めないファイルに対しても正しい尺を報告する。つまり**タガーの出力は証拠にならない**。Music に訊く。

```bash
osascript -e 'tell application "Music"
set r to {}
repeat with t in (every file track of library playlist 1 whose album is "ALBUM")
set end of r to ((get name of t) & " | time=" & (get time of t) & " | bitrate=" & (get bit rate of t as text) & " | artwork=" & (count of artworks of t) & " | cloud=" & (get cloud status of t as text))
end repeat
return r
end tell'
```

- `time` は実際の `M:SS` であること。`missing value` は不可
- `bit rate` が数値であること
- `cloud status` は `uploaded` / `matched` / `purchased` のいずれかに落ち着く。`unknown` は同期側が未評価という意味で、Music がバックグラウンドにあると収束に 5 分以上かかることもある。`unknown` のままタイムアウトしたポーリングは失敗ではなく判定不能なので、結論を出す前に時間をおいて再照会する。**`ineligible` は取り込みの失敗を意味する**ので、手順 3 に戻る。

## 不良トラックを差し替える

メディアフォルダ内のファイルを直接編集しても意味がない。Music はメタデータを自前のデータベースに保持している。エントリを削除し、孤児になったファイルを消してから、取り込み直す。

```bash
osascript -e 'tell application "Music"
repeat with t in (every file track of library playlist 1 whose album is "ALBUM")
delete t
end repeat
end tell'
rm -rf ~/Music/Music/Media.localized/Music/"ARTIST"   # 孤児。消さないと "TITLE 1.m4a" ができる
```

メタデータだけの変更なら削除しない。Music を操作すれば、ファイルのタグ書き換えとフォルダの移動まで代わりにやってくれる。

```bash
osascript -e 'tell application "Music"
repeat with t in (every file track of library playlist 1 whose album is "OLD ALBUM")
set artist of t to "NEW ARTIST"
set album artist of t to "NEW ARTIST"
set album of t to "NEW ALBUM"
end repeat
end tell'
```

トラックの選択には `every file track of library playlist 1 whose <プロパティ> is "…"` を使う。`some file track … whose database ID is N` の形はエラー -1728 になる。

## よくある失敗

| 失敗 | 対処 |
|---|---|
| DASH 警告を見た目だけの問題と判断する | 0:00 と不適格の原因そのもの。リマックスは必須。 |
| 「ffmpeg が無いからリマックスは省く」と結論する | static ビルドを取ってくる。システムには何も入らない。 |
| タグ検査ツールで尺を確認する | DASH でも正しく読める。Music の `time` だけが判定材料。 |
| `cloud status = unknown` で成功と報告する | 時間をおいて再照会する。`unknown` は結果ではない。 |
| 参照トラックからアーティストを写す | それはその曲のアーティスト。この曲のクレジットから決める。 |
| フォーマットタグをアルバム名に残す | それは動画の説明であって作品名ではない。 |
| チャンネル名をアーティストにする | まず動画タイトルの `曲名 / アーティスト` を疑う。 |
| 再生時間を見ずに検索結果を選ぶ | 耐久・リミックス・転載が検索結果を埋めている。 |
| 中央切り出しを見ずに埋め込む | アルバムアートになる前に画像を見る。 |
| 空の `lyrics.txt` から `©lyr` を書く | 歌詞欄が無い説明文のほうが多い。中身があるときだけタグを付ける。 |
| 孤児ファイルを消さずに取り込み直す | `TITLE 1.m4a` が隣にできる。 |
| `-x --audio-format mp3` を使う | 無意味に再エンコードされる。`-c:a copy` なら原音のまま。 |

## 危険信号

次のいずれかに当てはまるなら、取り込みを中止してやり直す。

- DASH 警告が出たのに ffmpeg を通していない
- `time=missing value` / `bit rate=missing value` / `cloud=ineligible`
- タグ検査ツールの出力だけを根拠に成功と報告している
