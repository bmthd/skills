#!/usr/bin/env bash
# Keep every `*.ja.md` in step with the `*.md` it translates.
#
# The Japanese files are reading aids: the skills CLI only ever loads SKILL.md,
# and GitHub only ever renders README.md, so nothing else would notice if a
# translation fell behind. Assert that every original has one and that the pair
# still shares a structure — same heading shape, same number of fenced code
# blocks.
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

check_pair() {
    local original="$1"
    local translation="${original%.md}.ja.md"
    local label="${original#"$repo_root"/}"

    if [ ! -f "$translation" ]; then
        echo "✗ $label: no translation at ${translation#"$repo_root"/}"
        status=1
        return
    fi

    # A frontmatter block would make a translation look like a second skill
    # manifest. It is prose about the original, nothing more.
    if [ "$(head -n 1 "$translation")" = "---" ]; then
        echo "✗ $label: its translation starts with frontmatter; it is not a skill of its own"
        status=1
        return
    fi

    if ! diff -q <(heading_shape "$original") <(heading_shape "$translation") > /dev/null; then
        echo "✗ $label: heading structure differs from its translation"
        diff <(heading_shape "$original") <(heading_shape "$translation") | head -20
        status=1
        return
    fi

    if [ "$(fence_count "$original")" != "$(fence_count "$translation")" ]; then
        echo "✗ $label: code block count differs from its translation" \
             "($(fence_count "$original") vs $(fence_count "$translation"))"
        status=1
        return
    fi

    echo "✓ $label"
}

check_pair "$repo_root/README.md"

for skill_md in "$repo_root"/skills/*/SKILL.md; do
    check_pair "$skill_md"
done

# The other direction: a translation whose original was renamed or removed.
while IFS= read -r translation; do
    original="${translation%.ja.md}.md"
    if [ ! -f "$original" ]; then
        echo "✗ ${translation#"$repo_root"/}: no original at ${original#"$repo_root"/}"
        status=1
    fi
done < <(find "$repo_root" -name '*.ja.md' -not -path '*/.git/*')

exit "$status"
