#!/usr/bin/env bash
# Structural guard for this fork's exact-* skills. Run it after every upstream rebase.
# SKILLS_DIR and AGENTS_DIR default to this repo's .github/skills and .github/agents;
# point them at an install location to check what Copilot actually loads.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
default_skills_dir="$repo_root/.github/skills"
SKILLS_DIR="${SKILLS_DIR:-$default_skills_dir}"
AGENTS_DIR="${AGENTS_DIR:-$repo_root/.github/agents}"
agent_file="$AGENTS_DIR/exact-isolated-refactor.agent.md"
expected_skills="exact-coding exact-coding-isolated-refactor exact-predictive-tdd exact-test-list exact-example-mapping exact-red exact-green exact-refactor exact-end-refactor"

failure_count=0
fail() {
  echo "FAIL $1: $2"
  failure_count=$((failure_count + 1))
}

# Runs grep in this shell so read errors (exit > 1) count as failures; matches land in grep_result.
grep_result=""
grep_into_result() {
  local check_id="$1" grep_status
  shift
  grep_result="$(grep "$@")" && grep_status=0 || grep_status=$?
  if [ "$grep_status" -gt 1 ]; then
    fail IO "$check_id could not read its input (grep exit $grep_status)"
  fi
}

fail_for_each_result_line() {
  local check_id="$1" result_line
  [ -n "$grep_result" ] || return 0
  while IFS= read -r result_line; do
    fail "$check_id" "$result_line"
  done <<< "$grep_result"
}

checked_files=()
for skill_dir in "$SKILLS_DIR"/exact-*/; do
  [ -d "$skill_dir" ] || continue
  skill_file_list="$(find -L "$skill_dir" -type f)" || fail IO "could not fully traverse $skill_dir"
  [ -n "$skill_file_list" ] || continue
  while IFS= read -r skill_file; do
    checked_files+=("$skill_file")
  done <<< "$skill_file_list"
done
if [ -f "$agent_file" ]; then
  checked_files+=("$agent_file")
fi

fail_on_matches() {
  local check_id="$1" pattern="$2"
  [ "${#checked_files[@]}" -gt 0 ] || return 0
  grep_into_result "$check_id" -HnE -- "$pattern" "${checked_files[@]}"
  fail_for_each_result_line "$check_id"
}

require_text() {
  local check_id="$1" file="$2" text="$3"
  if [ ! -f "$file" ]; then
    fail "$check_id" "missing file $file"
  elif ! grep -qF -- "$text" "$file"; then
    fail "$check_id" "$file does not contain '$text'"
  fi
}

# C1 stale paths
fail_on_matches C1 '\.github/(skills|agents)/'

# C2 naming
for skill_dir in "$SKILLS_DIR"/exact-*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    fail C2 "$skill_name has no SKILL.md"
    continue
  fi
  declared_name="$(awk '/^name:/ { sub(/^name:[[:space:]]*/, ""); print; exit }' "$skill_dir/SKILL.md")"
  if [ "$declared_name" != "$skill_name" ]; then
    fail C2 "$skill_name/SKILL.md declares name '$declared_name'"
  fi
done

if [ "$SKILLS_DIR" = "$default_skills_dir" ]; then
  for skill_dir in "$default_skills_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    case "$skill_name" in
      exact-*) ;;
      *) fail C2b "$skill_name lacks the exact- prefix" ;;
    esac
  done
fi

for expected_skill in $expected_skills; do
  [ -f "$SKILLS_DIR/$expected_skill/SKILL.md" ] || fail C2c "missing skill $expected_skill"
done

# C3 references resolve
for skill_md in "$SKILLS_DIR"/exact-*/SKILL.md; do
  [ -f "$skill_md" ] || continue
  skill_dir="$(dirname "$skill_md")"
  grep_into_result C3 -oE '`\.\./exact-[a-z-]+/[^`]*`' "$skill_md"
  [ -n "$grep_result" ] || continue
  while IFS= read -r reference; do
    target="$skill_dir/$reference"
    case "$reference" in
      */) [ -d "$target" ] || fail C3 "$skill_md: directory $reference does not resolve" ;;
      *) [ -f "$target" ] || fail C3 "$skill_md: file $reference does not resolve" ;;
    esac
  done <<< "$(printf '%s\n' "$grep_result" | tr -d '`' | sort -u)"
done

predictive_tdd_dir="$SKILLS_DIR/exact-predictive-tdd"
if [ -f "$predictive_tdd_dir/SKILL.md" ] && grep -qF '`human-in-the-loop.md`' "$predictive_tdd_dir/SKILL.md"; then
  [ -f "$predictive_tdd_dir/human-in-the-loop.md" ] || fail C3 "exact-predictive-tdd/human-in-the-loop.md does not exist"
fi

# C4 old names
fail_on_matches C4 '`/?(red|green|refactor|test-list|predictive-tdd|example-mapping|end-refactor)`'
fail_on_matches C4 '(^|[ (`])/(red|green|refactor|test-list|predictive-tdd|example-mapping|end-refactor)\b'

# C5 agent
require_text C5 "$agent_file" "name: exact-isolated-refactor"

# C6 spec input
fail_on_matches C6 'prompt\.md'

# C7 English output
example_mapping_md="$SKILLS_DIR/exact-example-mapping/SKILL.md"
if [ ! -f "$example_mapping_md" ]; then
  fail C7 "missing file $example_mapping_md"
else
  grep_into_result C7 -HnE -- '\((gelb|blau|gruen|rot|ausgelagert)\)|Regel|Keine -|Titel der' "$example_mapping_md"
  fail_for_each_result_line C7
fi

# C8 opt-in
fail_on_matches C8 'asks for TDD or|prepare a feature for TDD|clarify requirements before coding'

# C9 features
require_text C9 "$predictive_tdd_dir/human-in-the-loop.md" "Per-run override"
require_text C9 "$predictive_tdd_dir/human-in-the-loop.md" 'Only `task-end` and `autonomous` may investigate and resume'
require_text C9 "$predictive_tdd_dir/SKILL.md" "## Other TDD skills"
require_text C9 "$predictive_tdd_dir/SKILL.md" 'Unless the Autonomy Level is `task-end` or `autonomous`'
require_text C9 "$example_mapping_md" "## Draft mode"

if [ "$failure_count" -gt 0 ]; then
  exit 1
fi
echo "OK"
