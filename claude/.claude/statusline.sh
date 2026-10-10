#!/usr/bin/env bash
# Claude Code statusLine: dir | branch | model | context pct+bar+used/total | tokens in ↑ out ↓ | 5h limit bar
# Needs bash (uses <<<, <(...)); settings call `bash` explicitly since the harness may use sh/dash.

input=$(cat)

# DEBUG: dump raw stdin JSON (overwrite) and append a timestamped one-line copy to a log
dbg_dir=/tmp/claude-1000/-home-user-workspace-research-narration-music-tools/229021df-d366-4499-8bb6-e3293fa8f7c9/scratchpad
if mkdir -p "$dbg_dir" 2>/dev/null; then
  printf '%s\n' "$input" > "$dbg_dir/statusline_input.json"
  printf '%s %s\n' "$(date +%s)" "$(jq -c . <<< "$input" 2>/dev/null || tr '\n' ' ' <<< "$input")" >> "$dbg_dir/statusline_input.log"
fi

GREEN='01;32'
YELLOW='01;33'
RED='01;31'
BLUE='01;34'
MAGENTA='01;35'
CYAN='01;36'

# paint <color> <text>
paint() { printf '\033[%sm%s\033[00m' "$1" "$2"; }

# repeat_char <count> <char>
repeat_char() {
  local out='' i
  for ((i = 0; i < $1; i++)); do out+="$2"; done
  printf '%s' "$out"
}

# bar <filled_cells> <total_cells>
bar() {
  local f=$1 t=$2
  ((f > t)) && f=$t
  ((f < 0)) && f=0
  printf '[%s%s]' "$(repeat_char "$f" '█')" "$(repeat_char $((t - f)) '░')"
}

# human <n>: 1234 -> 1k, 2300000 -> 2.3M
human() {
  awk -v n="$1" 'BEGIN{ if (n >= 1e6) printf "%.1fM", n / 1e6; else if (n >= 1e3) printf "%.0fk", n / 1e3; else printf "%d", n }'
}

# --- directory + git branch ---
dir=$(jq -r '.workspace.current_dir // .cwd' <<< "$input")
out=$(paint "$GREEN" "$(basename "$dir")")
br=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" branch --show-current 2>/dev/null)
[ -z "$br" ] && br=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" rev-parse --short HEAD 2>/dev/null)
[ -n "$br" ] && out+=" | $(paint "$BLUE" "$br")"

# --- model ---
model=$(paint "$MAGENTA" "$(jq -r '.model.display_name // "--"' <<< "$input")")
# effort level (e.g. xhigh), in its own color; field name varies by version so try a few
effort=$(jq -r '(.effort.level // .effort_level // .effort // empty) | strings' <<< "$input" 2>/dev/null)
[ -n "$effort" ] && model+=" $(paint "$YELLOW" "$effort")"

# --- context window bar (fill = used) ---
pct=$(jq -r '(.context_window.used_percentage
  // (if (.context_window.current_usage and .context_window.context_window_size)
      then ((.context_window.current_usage
             | ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)))
            * 100 / .context_window.context_window_size)
      else null end)) // empty' <<< "$input")
CTX_CELLS=24
AUTOCOMPACT_BUFFER=33000  # tokens reserved at the end of the window (see /context)
ctx_size=$(jq -r '.context_window.context_window_size // empty' <<< "$input")
# used tokens: sum of current_usage input fields, else derived from the percentage
ctx_used=$(jq -r '(.context_window.current_usage
  | if . then ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))
    else empty end) // empty' <<< "$input")
if [ -z "$ctx_used" ] && [ -n "$pct" ] && [ -n "$ctx_size" ]; then
  ctx_used=$(awk -v p="$pct" -v s="$ctx_size" 'BEGIN{ printf "%d", p * s / 100 }')
fi
# Use the model's autoCompactWindow (from settings.json) as the meter maximum.
# Falls back to the full context window size if the model id, file, or key is missing/invalid.
model_id=$(jq -r '.model.id // empty' <<< "$input")
acw=''
if [ -n "$model_id" ] && [ -f "$HOME/.claude/settings.json" ]; then
  acw=$(jq -r --arg m "$model_id" '.modelSettings[$m].autoCompactWindow
    | if type == "number" and . > 0 then . else empty end' "$HOME/.claude/settings.json" 2>/dev/null)
fi
# The meter maximum is the usable range: autoCompactWindow minus the autocompact buffer.
if [ -n "$acw" ] && [ -n "$ctx_used" ]; then
  if ((acw > AUTOCOMPACT_BUFFER)); then
    ctx_size=$((acw - AUTOCOMPACT_BUFFER))
  else
    ctx_size=$acw
  fi
  pct=$(awk -v u="$ctx_used" -v s="$ctx_size" 'BEGIN{ printf "%.2f", u * 100 / s }')
fi
# kilo <n>: always in k, e.g. 12345 -> 12k, 1000000 -> 1000k
kilo() { awk -v n="$1" 'BEGIN{ printf "%.0fk", n / 1e3 }'; }
if [ -n "$pct" ]; then
  n=$(printf '%.0f' "$pct")
  # green < 60%, yellow 60% to < 85%, red >= 85%
  ctx_color=$(awk -v p="$pct" -v g="$GREEN" -v y="$YELLOW" -v r="$RED" \
    'BEGIN{ print (p >= 85) ? r : (p >= 60) ? y : g }')
  # bar() caps the fill at 100% when usage exceeds the usable max
  ctx="${n}% $(paint "$ctx_color" "$(bar $((n * CTX_CELLS / 100)) $CTX_CELLS)")"
  [ -n "$ctx_used" ] && [ -n "$ctx_size" ] && ctx+=" $(kilo "$ctx_used")/$(kilo "$ctx_size")"
else
  ctx="-- $(paint "$BLUE" "$(bar 0 $CTX_CELLS)")"
fi

# --- session tokens in/out, summed from the transcript (cached by file size) ---
# in = fresh input + cache writes; cache reads are not shown. Dedupe by message id since the
# transcript can log a message more than once. Subagent transcripts are included; t/s uses main-session output only.
tok='-- ↑ -- ↓'
tp=$(jq -r '.transcript_path // empty' <<< "$input")
if [ -n "$tp" ] && [ -f "$tp" ]; then
  # subagent transcripts live in <session>/subagents/*.jsonl; fold them into the totals
  files=("$tp")
  for f in "${tp%.jsonl}"/subagents/agent-*.jsonl; do [ -f "$f" ] && files+=("$f"); done
  sz=$(stat -c %s "${files[@]}" | paste -sd+ | bc)
  cf="/tmp/sl_tok_$(basename "$tp" .jsonl)"
  read -r csz ti to tm _ 2>/dev/null < "$cf"
  if [ "$csz" != "$sz" ]; then
    read -r ti to <<< "$(jq -s -r '[.[] | select(.type=="assistant") | .message | select(.usage)]
      | unique_by(.id)
      | [(map((.usage.input_tokens // 0) + (.usage.cache_creation_input_tokens // 0)) | add // 0),
         (map(.usage.output_tokens // 0) | add // 0)] | @tsv' "${files[@]}" 2>/dev/null)"
    # main-session output only, for the t/s estimate
    tm=$(jq -s -r '[.[] | select(.type=="assistant") | .message | select(.usage)]
      | unique_by(.id) | map(.usage.output_tokens // 0) | add // 0' "$tp" 2>/dev/null)
    echo "$sz $ti $to $tm" > "$cf"
  fi
  [ -n "$ti" ] && tok="$(human "$ti") ↑ $(human "$to") ↓"
  # t/s estimate: output tokens / total API time (includes prompt processing, so it reads low)
  api_ms=$(jq -r '.cost.total_api_duration_ms // empty' <<< "$input")
  if [ -n "$ti" ] && [ -n "$api_ms" ] && [ "${api_ms%.*}" -gt 0 ] 2>/dev/null; then
    tps=$(awk -v o="${tm:-$to}" -v ms="$api_ms" 'BEGIN{ printf "%.0f", o * 1000 / ms }')
    tok+=" ${tps} t/s"
  fi
fi

# --- 5h rate limit bar (fill = remaining; absent for API-key users / before first response) ---
LIM_CELLS=20
lim='5h n/a'
read -r fh_used fh_reset < <(jq -r '[(.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // "")] | @tsv' <<< "$input")
if [ -n "$fh_used" ]; then
  left=$(awk -v u="$fh_used" 'BEGIN{ l = 100 - u; if (l < 0) l = 0; printf "%.0f", l }')
  if ((left <= 10)); then c=$RED; elif ((left <= 30)); then c=$YELLOW; else c=$GREEN; fi
  rs=''
  if [ -n "$fh_reset" ]; then
    secs=$((fh_reset - $(date +%s)))
    ((secs > 0)) && rs=$(date -d "@$fh_reset" +' (reset %H:%M)')
  fi
  lim="5h $(paint "$c" "$(bar $((left * LIM_CELLS / 100)) $LIM_CELLS)") ${left}%${rs}"
fi

printf '%s | %s | %s | %s | %s' "$out" "$model" "$ctx" "$(paint "$CYAN" "$tok")" "$lim"
