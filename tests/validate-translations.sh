#!/usr/bin/env bash
# Keep every `*.ja.md` in step with the `*.md` it translates.
#
# The Japanese files are reading aids: the skills CLI only ever loads SKILL.md,
# and GitHub only ever renders README.md, so nothing else would notice if a
# translation fell behind. Assert that every original has one and that the pair
# still shares a structure — mirrored frontmatter, same heading shape, same
# number of fenced code blocks.
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

has_frontmatter() {
    [ "$(head -n 1 "$1")" = "---" ]
}

# The frontmatter fields, in order. Enough to catch a translation that dropped
# `argument-hint` or invented a field the original does not carry.
frontmatter_keys() {
    awk 'NR > 1 { if ($0 == "---") exit; print }' "$1" |
        sed -nE 's/^([A-Za-z0-9_-]+):.*/\1/p'
}

frontmatter_value() {
    awk 'NR > 1 { if ($0 == "---") exit; print }' "$1" |
        sed -n "s/^$2:[[:space:]]*//p" |
        sed -e 's/^"//' -e 's/"$//'
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

    # The description in the frontmatter is what an agent shows before it loads
    # a skill, so a translation that stops at the body leaves the most visible
    # sentence in English. Mirror the original instead: same fields, the same
    # `name` (an identifier, not prose), and a description actually rewritten.
    if has_frontmatter "$original"; then
        if ! has_frontmatter "$translation"; then
            echo "✗ $label: its translation has no frontmatter"
            status=1
            return
        fi

        if ! diff -q <(frontmatter_keys "$original") <(frontmatter_keys "$translation") > /dev/null; then
            echo "✗ $label: frontmatter fields differ from its translation"
            diff <(frontmatter_keys "$original") <(frontmatter_keys "$translation") | head -20
            status=1
            return
        fi

        if [ "$(frontmatter_value "$original" name)" != "$(frontmatter_value "$translation" name)" ]; then
            echo "✗ $label: its translation changes 'name'; that field is an identifier, not prose"
            status=1
            return
        fi

        local translated_description
        translated_description="$(frontmatter_value "$translation" description)"

        if [ -z "$translated_description" ]; then
            echo "✗ $label: its translation has no 'description'"
            status=1
            return
        fi

        if [ "$translated_description" = "$(frontmatter_value "$original" description)" ]; then
            echo "✗ $label: its translation copies 'description' from the original verbatim"
            status=1
            return
        fi
    elif has_frontmatter "$translation"; then
        echo "✗ $label: its translation has frontmatter the original does not"
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

while IFS= read -r skill_md; do
    check_pair "$skill_md"
done < <(find "$repo_root"/skills -name SKILL.md | sort)

# The other direction: a translation whose original was renamed or removed.
while IFS= read -r translation; do
    original="${translation%.ja.md}.md"
    if [ ! -f "$original" ]; then
        echo "✗ ${translation#"$repo_root"/}: no original at ${original#"$repo_root"/}"
        status=1
    fi
done < <(find "$repo_root" -name '*.ja.md' -not -path '*/.git/*')

exit "$status"
