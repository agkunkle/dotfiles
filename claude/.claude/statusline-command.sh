#!/usr/bin/env bash
# Claude Code statusLine command
# Converted from ~/.bashrc PS1 configuration
# Includes: PS1-style prefix, context bar, and token usage info

# Read stdin JSON (Claude Code pipes session data here)
input=$(cat)

# Build the PS1-style prefix (no user@host, tilde-shortened path)
_cwd="$(pwd)"
_home="$HOME"
case "$_cwd" in
  "$_home"*) _display_path="~${_cwd#"$_home"}" ;;
  *)         _display_path="$_cwd" ;;
esac
prefix=$(printf '\033[01;34m%s\033[00m' "$_display_path")

# Build the context bar and usage info if jq is available
bar_section=""
usage_section=""
if command -v jq >/dev/null 2>&1; then
  used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // 0' 2>/dev/null)
  # Ensure we have a numeric value; fall back to 0 on any parse failure
  case "$used_pct" in
    ''|null|*[!0-9.]*) used_pct=0 ;;
  esac

  # Round to nearest integer
  used_int=$(printf '%.0f' "$used_pct" 2>/dev/null || echo 0)

  # Clamp to [0, 100]
  [ "$used_int" -lt 0 ] 2>/dev/null && used_int=0
  [ "$used_int" -gt 100 ] 2>/dev/null && used_int=100

  # Calculate filled boxes out of 20
  filled=$(( used_int * 20 / 100 ))
  empty=$(( 20 - filled ))

  bar=""
  i=0
  while [ "$i" -lt "$filled" ]; do
    bar="${bar}▓"
    i=$(( i + 1 ))
  done
  i=0
  while [ "$i" -lt "$empty" ]; do
    bar="${bar}░"
    i=$(( i + 1 ))
  done

  bar_section=" [${bar}] ${used_int}%"

  # Token usage: total session input/output tokens
  total_in=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // empty' 2>/dev/null)
  total_out=$(printf '%s' "$input" | jq -r '.context_window.total_output_tokens // empty' 2>/dev/null)

  # Helper: format large numbers with k suffix
  fmt_num() {
    local n="$1"
    if [ -z "$n" ] || [ "$n" = "null" ]; then
      echo "?"
      return
    fi
    if [ "$n" -ge 1000 ] 2>/dev/null; then
      printf '%dk' "$(( n / 1000 ))"
    else
      printf '%d' "$n"
    fi
  }

  in_fmt=$(fmt_num "$total_in")
  out_fmt=$(fmt_num "$total_out")

  # Model display name (shortened)
  model=$(printf '%s' "$input" | jq -r '.model.display_name // empty' 2>/dev/null)

  if [ -n "$model" ]; then
    usage_section=" | ${model} | in:${in_fmt} out:${out_fmt}"
  else
    usage_section=" | in:${in_fmt} out:${out_fmt}"
  fi
fi

printf '%s%s%s' "$prefix" "$bar_section" "$usage_section"
