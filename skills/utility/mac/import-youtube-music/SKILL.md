---
name: import-youtube-music
description: Use when the user wants to download a track from YouTube and add it to the macOS Music.app / iTunes library with proper tags and cover art, or when a track already in the library shows 0:00 duration, a missing bitrate, or an iCloud sync status of "ineligible".
---

# Import YouTube Music

Download the audio with yt-dlp, remux it into a real MP4 container, write the
tags and a square cover, then hand the file to Music.app.

## Overview

Two things decide whether this goes well.

1. The library already has a convention. Read it off an existing track instead
   of inventing one.
2. A file that plays fine locally can still be rejected by iCloud Sync Library.
   Verify through Music.app, not through the tagger.

## When to Use

- The user wants a song from YouTube in their local Music.app library
- The user names an existing track and asks for "the same format"
- A track shows **0:00**, no bitrate, or is marked **ineligible** for iCloud sync
- Fixing artist, album, or artwork on a track already imported
- NOT for: podcasts, keeping the video, anything that needs a real re-encode

## Requirements

macOS, plus three tools that need no permanent install:

```bash
uvx yt-dlp --version                                     # downloader
uv run --with imageio-ffmpeg python -c \
  'import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())'   # static ffmpeg
sips --help                                              # built into macOS
```

The last command prints a path; keep it in `$FF`. **ffmpeg is required, not
optional** — see step 3. Work in a scratch directory until the file is final.

## 1. Identify the right video

```bash
uvx yt-dlp --flat-playlist \
  --print "%(id)s | %(duration)s | %(channel)s | %(title)s" "ytsearch10:SONG NAME"
```

Prefer the original upload by the credited artist. Duration is the tiebreaker:
hour-long loops, remixes, subtitle edits, and fan reuploads crowd the results and
none of them are the track being asked for.

When the user names an existing track as the template, find its source too —
a matching duration confirms which upload the library copy came from.

## 2. Download

```bash
uvx yt-dlp -f "bestaudio[ext=m4a]/bestaudio" \
  --write-info-json --write-thumbnail -o "track.%(ext)s" "https://www.youtube.com/watch?v=ID"
```

`--write-info-json` is what makes the rest cheap: title, channel, description
(often the lyrics), and thumbnail URLs all come from that one file.

## 3. Remux, and never skip it

yt-dlp prints:

```text
WARNING: writing DASH m4a. Only some players support this container.
         Install ffmpeg to fix this automatically
```

**Music.app is one of the players that does not support it.** A DASH-fragmented
m4a imports and even plays, but Music reads no duration from it, so the track
shows **0:00**, has no bitrate, and Sync Library marks it **ineligible** and
never uploads it. Rewrite the container:

```bash
"$FF" -hide_banner -loglevel warning -y -i track.m4a \
  -c:a copy -movflags +faststart -f mp4 "TITLE.m4a"
"$FF" -hide_banner -i "TITLE.m4a" 2>&1 | grep Duration   # must print a real duration
```

`-c:a copy` is a container rewrite: same audio bytes, no re-encode, same size.

## 4. Derive the tags

| Atom | Field | How to derive |
|---|---|---|
| `©nam` | Title | Song name only — strip bracket tags and any artist suffix |
| `©ART` / `aART` | Artist / Album Artist | The **credited artist**, not the uploader handle |
| `©alb` | Album | Song name for a single; keep a *series* tag, drop a *format* tag |
| `©gen` | Genre | From the music itself |
| `©lyr` | Lyrics | The description, when it carries a lyrics section |
| `covr` | Artwork | Square JPEG, 1024×1024 (step 5) |

Read the convention off the library before choosing values:

```bash
ls -R ~/Music/Music/Media.localized/Music/
uv run --with mutagen mutagen-inspect "<an existing track>.m4a"
```

The layout `Music/<Album Artist>/<Album>/<Title>.m4a` shows exactly how this user
tags things. Copy the *shape* — which atoms are set, whether lyrics are embedded,
what size the cover is. Do not copy the *values*: the artist on the reference
track is that song's artist, not this one's.

Video titles often encode the artist rather than the metadata fields:

- `<TAG> Song Name / Artist Name` — the name after the separator is the artist.
  It is not part of the title.
- A bracket tag describing the *video format* (an official-video marker, a
  resolution) is noise: delete it. A tag naming a *series* belongs in the album.
- The channel is the uploader, often a remix account, a label, or a reuploader.
  It is the artist only when nothing else is credited.

Take the lyrics from the description mechanically rather than retyping them:

```bash
jq -r '.description' track.info.json | awk 'f {print} /^Lyrics:|^歌詞/ {f=1}' > lyrics.txt
```

Most videos have no lyrics section at all. When neither marker matches, the file
comes out empty — that is the normal case, not a failure. Leave the tag unset
rather than writing an empty one; step 6 already guards for it.

## 5. Cover art

Target a 1024×1024 JPEG. `sips -c H W` crops from the center.

```bash
curl -sL -o thumb.jpg "https://i.ytimg.com/vi/ID/maxresdefault.jpg"   # 1280x720
cp thumb.jpg cover.jpg
sips -c 720 720 cover.jpg                     # center square
sips -z 1024 1024 cover.jpg
sips -s format jpeg -s formatOptions 95 --out cover.jpg cover.jpg
```

**Look at the result before embedding it.** Render a preview with
`sips -Z 500 --out preview.jpg cover.jpg` and open it. A 16:9 thumbnail
center-crops well when the subject is centered and badly when the art is a wide
composition or carries text near the edges. If the crop mangles it, say so and
choose another source image instead of shipping it.

## 6. Write the tags

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
a.pop("\xa9too", None)  # yt-dlp leaves "Google" here

# Only when step 4 produced something. Most descriptions carry no lyrics, and a
# missing file would crash the script while an empty one would write an empty tag.
lyrics = pathlib.Path("lyrics.txt")
text = lyrics.read_text(encoding="utf-8").strip() if lyrics.is_file() else ""
if text:
    a["\xa9lyr"] = [text]

a.save()

for k, v in sorted(MP4(path).items()):
    print(k, "=", f"{len(v[0])} bytes" if k == "covr" else v)
PY
```

Printing the tags back is what makes the write self-verifying.

## 7. Import

Hand the finished file to Music.app:

```bash
osascript -e 'tell application "Music" to add POSIX file "/absolute/path/TITLE.m4a"'
```

Music **copies** it into
`~/Music/Music/Media.localized/Music/<Album Artist>/<Album>/<Title>.m4a`.

## 8. Verify through Music.app

This is the step that catches the container failure. A tag inspector reports the
correct duration even for a file Music cannot read, so **tagger output is not
evidence.** Ask Music:

```bash
osascript -e 'tell application "Music"
set r to {}
repeat with t in (every file track of library playlist 1 whose album is "ALBUM")
set end of r to ((get name of t) & " | time=" & (get time of t) & " | bitrate=" & (get bit rate of t as text) & " | artwork=" & (count of artworks of t) & " | cloud=" & (get cloud status of t as text))
end repeat
return r
end tell'
```

- `time` must be a real `M:SS`, never `missing value`
- `bit rate` must be a number
- `cloud status` settles on `uploaded`, `matched`, or `purchased`. `unknown`
  means Sync Library has not evaluated it yet, and settling can take well over
  five minutes while Music is in the background — a poll loop that times out on
  `unknown` is inconclusive, not a failure, so re-query later before concluding
  anything. **`ineligible` means the import failed**; go back to step 3.

## Replacing a bad track

Editing the file inside the media folder does nothing: Music caches metadata in
its own database. Delete the entry, remove the file it orphans, then re-import.

```bash
osascript -e 'tell application "Music"
repeat with t in (every file track of library playlist 1 whose album is "ALBUM")
delete t
end repeat
end tell'
rm -rf ~/Music/Music/Media.localized/Music/"ARTIST"   # orphan; else you get "TITLE 1.m4a"
```

For a metadata-only change, do not delete. Drive Music and it rewrites the
file's tags and relocates the folder for you:

```bash
osascript -e 'tell application "Music"
repeat with t in (every file track of library playlist 1 whose album is "OLD ALBUM")
set artist of t to "NEW ARTIST"
set album artist of t to "NEW ARTIST"
set album of t to "NEW ALBUM"
end repeat
end tell'
```

Select tracks with `every file track of library playlist 1 whose <property> is
"…"`. The `some file track … whose database ID is N` form raises error -1728.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Treating the DASH warning as cosmetic | It causes 0:00 and ineligible. The remux is mandatory. |
| Concluding "no ffmpeg here, so skip the remux" | Fetch a static build; nothing is installed system-wide. |
| Verifying duration with a tag inspector | It reads DASH fine. Only Music's `time` counts. |
| Reporting success at `cloud status = unknown` | Poll again later; `unknown` is not a result. |
| Copying the artist off the reference track | That is that song's artist. Derive this one from its own credits. |
| Leaving a format tag in the album name | It describes the video, not the release. |
| Using the channel name as the artist | Look for `Title / Artist` in the video title first. |
| Picking a search hit without checking duration | Loops, remixes, and reuploads dominate the results. |
| Embedding a center crop unseen | Look at the image before it becomes the album art. |
| Writing `©lyr` from an empty `lyrics.txt` | Most descriptions have no lyrics. Set the tag only when there is text. |
| Re-importing without removing the orphan | Music creates `TITLE 1.m4a` beside it. |
| Reaching for `-x --audio-format mp3` | Re-encodes for nothing; `-c:a copy` keeps the original quality. |

## Red Flags

Stop and redo the import when any of these is true.

- The DASH warning appeared and ffmpeg never ran
- `time=missing value`, `bit rate=missing value`, or `cloud=ineligible`
- Success was reported citing only tag-inspector output
