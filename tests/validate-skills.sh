#!/usr/bin/env bash
# Validate that every skill in skills/ carries the frontmatter the skills CLI
# needs: a `name` matching its directory and a non-empty `description`.
set -euo pipefail

status=0

for skill_md in skills/*/SKILL.md; do
    dir="$(basename "$(dirname "$skill_md")")"

    if [ "$(head -n 1 "$skill_md")" != "---" ]; then
        echo "✗ $skill_md: missing frontmatter (first line is not '---')"
        status=1
        continue
    fi

    frontmatter="$(awk 'NR > 1 { if ($0 == "---") exit; print }' "$skill_md")"
    name="$(printf '%s\n' "$frontmatter" | sed -n 's/^name:[[:space:]]*//p')"
    description="$(printf '%s\n' "$frontmatter" | sed -n 's/^description:[[:space:]]*//p')"

    if [ -z "$name" ]; then
        echo "✗ $skill_md: frontmatter has no 'name'"
        status=1
    elif [ "$name" != "$dir" ]; then
        # The CLI names the installed directory after `name`, so a mismatch
        # silently installs the skill under an unexpected directory.
        echo "✗ $skill_md: name '$name' does not match directory '$dir'"
        status=1
    fi

    if [ -z "$description" ]; then
        echo "✗ $skill_md: frontmatter has no 'description'"
        status=1
    fi

    [ "$status" -eq 0 ] && echo "✓ $dir"
done

exit "$status"
