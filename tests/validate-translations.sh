#!/usr/bin/env bash
# Keep each SKILL.ja.md in step with the SKILL.md it translates.
#
# The Japanese file is a reading aid: the skills CLI only ever loads SKILL.md,
# so nothing else would notice if a translation fell behind. Assert that every
# skill has one and that the two files still share a structure — same heading
# shape, same number of fenced code blocks.
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
status=0

# Heading text cannot be compared across languages, so compare the heading
# *shape* instead: the sequence of `#` prefixes.
heading_shape() {
    grep -E '^#{1,6} ' "$1" | sed -E 's/^(#+) .*/\1/'
}

fence_count() {
    grep -c '^```' "$1"
}

for skill_md in "$repo_root"/skills/*/SKILL.md; do
    dir="$(basename "$(dirname "$skill_md")")"
    ja_md="$(dirname "$skill_md")/SKILL.ja.md"

    if [ ! -f "$ja_md" ]; then
        echo "✗ $dir: no translation at skills/$dir/SKILL.ja.md"
        status=1
        continue
    fi

    # A frontmatter block would make the translation look like a second skill
    # manifest. It is prose about SKILL.md, nothing more.
    if [ "$(head -n 1 "$ja_md")" = "---" ]; then
        echo "✗ $dir: SKILL.ja.md starts with frontmatter; it is not a skill of its own"
        status=1
        continue
    fi

    if ! diff -q <(heading_shape "$skill_md") <(heading_shape "$ja_md") > /dev/null; then
        echo "✗ $dir: heading structure differs between SKILL.md and SKILL.ja.md"
        diff <(heading_shape "$skill_md") <(heading_shape "$ja_md") | head -20
        status=1
        continue
    fi

    if [ "$(fence_count "$skill_md")" != "$(fence_count "$ja_md")" ]; then
        echo "✗ $dir: code block count differs" \
             "($(fence_count "$skill_md") vs $(fence_count "$ja_md"))"
        status=1
        continue
    fi

    echo "✓ $dir"
done

# The other direction: a translation whose original was renamed or removed.
for ja_md in "$repo_root"/skills/*/SKILL.ja.md; do
    dir="$(basename "$(dirname "$ja_md")")"
    if [ ! -f "$(dirname "$ja_md")/SKILL.md" ]; then
        echo "✗ $dir: SKILL.ja.md has no SKILL.md to translate"
        status=1
    fi
done

exit "$status"
