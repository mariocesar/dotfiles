#!/usr/bin/env bash
# Claude Code statusLine — shows:
#   - the current folder name (~ for $HOME)
#   - model display name + reasoning effort level
#   - context window usage (bar + %)
#   - Claude.ai 5-hour and 7-day (1w) rate-limit usage, each with time-to-reset
# Managed by the statusline-setup agent — ask Claude to update it rather than
# editing by hand, so ~/.claude/settings.json stays in sync.
set -u

input=$(cat)
get() { printf '%s' "$input" | jq -r "$1 // empty"; }

cwd=$(get '.workspace.current_dir // .cwd')
model=$(get '.model.display_name')
effort=$(get '.effort.level')
ctx_pct=$(get '.context_window.used_percentage')
h5_pct=$(get '.rate_limits.five_hour.used_percentage')
h5_reset=$(get '.rate_limits.five_hour.resets_at')
w1_pct=$(get '.rate_limits.seven_day.used_percentage')
w1_reset=$(get '.rate_limits.seven_day.resets_at')
dur_ms=$(get '.cost.total_duration_ms')

DIM='\033[2m'; RESET='\033[0m'; BOLD='\033[1m'
CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; MAGENTA='\033[35m'
sep="${DIM}|${RESET}"

# --- directory: just the current folder name, ~ for $HOME ---
if [[ "$cwd" == "$HOME" ]]; then
  dir_name="~"
else
  dir_name=$(basename "$cwd")
fi
dir_segment="${BOLD}${CYAN}${dir_name}${RESET}"

# --- helpers ---
round() { awk -v n="$1" 'BEGIN{printf "%d", (n<0?0:n)+0.5}'; }

bar() {
  local pct=$1 width=10 filled empty out i
  filled=$(( (pct * width + 50) / 100 ))
  (( filled > width )) && filled=$width
  (( filled < 0 )) && filled=0
  empty=$(( width - filled ))
  out=""
  for ((i = 0; i < filled; i++)); do out+="#"; done
  for ((i = 0; i < empty; i++)); do out+="-"; done
  printf '%s' "$out"
}

pct_color() {
  local pct=$1
  if (( pct >= 85 )); then printf '%b' "$RED"
  elif (( pct >= 60 )); then printf '%b' "$YELLOW"
  else printf '%b' "$GREEN"
  fi
}

fmt_duration() {
  local secs=$1 d h m
  (( secs < 0 )) && secs=0
  d=$(( secs / 86400 )); h=$(( (secs % 86400) / 3600 )); m=$(( (secs % 3600) / 60 ))
  if (( d > 0 )); then printf '%dd%dh' "$d" "$h"
  elif (( h > 0 )); then printf '%dh%dm' "$h" "$m"
  else printf '%dm' "$m"
  fi
}

# --- model + reasoning effort ---
model_segment=""
if [[ -n "$model" ]]; then
  model_segment="${DIM}${model}${RESET}"
  if [[ -n "$effort" ]]; then
    case "$effort" in
      low)    effort_color="$GREEN" ;;
      medium) effort_color="$YELLOW" ;;
      high)   effort_color="${BOLD}${YELLOW}" ;;
      xhigh)  effort_color="$MAGENTA" ;;
      max)    effort_color="${BOLD}${RED}" ;;
      *)      effort_color="$DIM" ;;
    esac
    model_segment="${model_segment} ${effort_color}[${effort}]${RESET}"
  fi
fi

# --- context window usage ---
ctx_segment=""
if [[ -n "$ctx_pct" ]]; then
  ctx_int=$(round "$ctx_pct")
  ctx_color=$(pct_color "$ctx_int")
  ctx_segment="${ctx_color}[$(bar "$ctx_int")] ${ctx_int}%${RESET}"
fi

# --- 5-hour rate limit ---
h5_segment=""
if [[ -n "$h5_pct" ]]; then
  h5_int=$(round "$h5_pct")
  h5_color=$(pct_color "$h5_int")
  if [[ "$h5_reset" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    now=$(date +%s)
    h5_segment="${DIM}5h${RESET} ${h5_color}$(fmt_duration $(( ${h5_reset%.*} - now )))${RESET}"
  else
    h5_segment="${DIM}5h${RESET} ${h5_color}${h5_int}%${RESET}"
  fi
fi

# --- 7-day (1w) rate limit ---
w1_segment=""
if [[ -n "$w1_pct" ]]; then
  w1_int=$(round "$w1_pct")
  w1_color=$(pct_color "$w1_int")
  if [[ "$w1_reset" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    now=$(date +%s)
    w1_segment="${DIM}1w${RESET} ${w1_color}$(fmt_duration $(( ${w1_reset%.*} - now )))${RESET}"
  else
    w1_segment="${DIM}1w${RESET} ${w1_color}${w1_int}%${RESET}"
  fi
fi

# --- session duration ---
dur_segment=""
if [[ "$dur_ms" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  dur_segment="${DIM}up $(fmt_duration $(( ${dur_ms%.*} / 1000 )))${RESET}"
fi

# --- assemble, skipping any segment whose data was unavailable ---
segments=()
[[ -n "$dir_segment" ]] && segments+=("$dir_segment")
[[ -n "$model_segment" ]] && segments+=("$model_segment")
[[ -n "$ctx_segment" ]] && segments+=("$ctx_segment")
[[ -n "$h5_segment" ]] && segments+=("$h5_segment")
[[ -n "$w1_segment" ]] && segments+=("$w1_segment")
[[ -n "$dur_segment" ]] && segments+=("$dur_segment")

out="${BOLD}${GREEN}>${RESET} "
first=true
for s in "${segments[@]}"; do
  if $first; then
    out+="$s"
    first=false
  else
    out+=" ${sep} $s"
  fi
done

printf '%b\n' "$out"
