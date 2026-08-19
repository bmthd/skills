#!/usr/bin/env bash
# Keep the Japanese skill variants in step with their English originals.
#
# Each skill `foo` has a translation at `skills/foo-ja/SKILL.md`, installable on
# its own so a user can pick the language at install time. Two copies drift the
# moment someone edits one of them, so assert the pairing exists in both
# directions and that the two files still share a structure: same headings, same
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

for skill_md in "$repo_root"/skills/*/SKILL.md; do
    dir="$(basename "$(dirname "$skill_md")")"
    case "$dir" in
        *-ja) continue ;;
    esac

    ja_md="$repo_root/skills/$dir-ja/SKILL.md"
    if [ ! -f "$ja_md" ]; then
        echo "✗ $dir: no Japanese variant at skills/$dir-ja/SKILL.md"
        status=1
        continue
    fi

    if ! diff -q <(heading_shape "$skill_md") <(heading_shape "$ja_md") > /dev/null; then
        echo "✗ $dir: heading structure differs from $dir-ja"
        diff <(heading_shape "$skill_md") <(heading_shape "$ja_md") | head -20
        status=1
        continue
    fi

    if [ "$(fence_count "$skill_md")" != "$(fence_count "$ja_md")" ]; then
        echo "✗ $dir: code block count differs from $dir-ja" \
             "($(fence_count "$skill_md") vs $(fence_count "$ja_md"))"
        status=1
        continue
    fi

    echo "✓ $dir ↔ $dir-ja"
done

# The other direction: a translation whose original was renamed or removed.
for ja_dir in "$repo_root"/skills/*-ja/; do
    ja_name="$(basename "$ja_dir")"
    base="${ja_name%-ja}"
    if [ ! -f "$repo_root/skills/$base/SKILL.md" ]; then
        echo "✗ $ja_name: no original at skills/$base/SKILL.md"
        status=1
    fi
done

exit "$status"
