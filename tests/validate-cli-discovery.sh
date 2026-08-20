#!/usr/bin/env bash
# Assert that the skills CLI actually discovers every skill directory.
#
# The frontmatter check in validate-skills.sh cannot catch YAML that parses as
# the wrong type — an unquoted `argument-hint: [FOO] [--bar]` becomes a flow
# sequence, the CLI skips the whole skill, and nothing else notices. Only the
# CLI's own listing tells us what it really sees.
#
# Deliberately does not parse the CLI's "Found N skills" summary: that line is
# part of the interactive spinner output and is absent when there is no TTY.
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="$(npx -y skills@latest add "$repo_root" -l 2>&1)"
status=0

# A skipped skill still prints its path, so its name would match the per-skill
# check below. Treat any skip as a hard failure first.
if printf '%s\n' "$output" | grep -qiE 'skipped|parse error'; then
    echo "✗ the CLI skipped at least one skill:"
    printf '%s\n' "$output" | grep -iE 'skipped|parse error'
    status=1
fi

# Skills live one level deeper than the group directory, so ask for the
# directories that actually hold a SKILL.md instead of globbing a fixed depth.
while IFS= read -r skill_md; do
    name="$(basename "$(dirname "$skill_md")")"
    if printf '%s\n' "$output" | grep -q "$name"; then
        echo "✓ $name discovered"
    else
        echo "✗ $name not discovered by the CLI"
        status=1
    fi
done < <(find "$repo_root"/skills -name SKILL.md | sort)

if [ "$status" -ne 0 ]; then
    echo "--- CLI output ---"
    printf '%s\n' "$output"
fi

exit "$status"
