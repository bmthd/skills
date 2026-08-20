#!/usr/bin/env bash
# Validate that every skill in skills/ carries the frontmatter the skills CLI
# needs: a `name` matching its directory and a non-empty `description`.
#
# Skills are grouped into purpose directories (skills/<group>/<skill>/), so walk
# the tree rather than globbing a fixed depth: a glob that matches nothing makes
# this script exit 0 having checked nothing.
set -euo pipefail

status=0
found=0

while IFS= read -r skill_md; do
    found=$((found + 1))
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
done < <(find skills -name SKILL.md | sort)

if [ "$found" -eq 0 ]; then
    echo "✗ no SKILL.md found under skills/"
    status=1
fi

exit "$status"
