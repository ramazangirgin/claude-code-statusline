#!/bin/bash
# Claude Code status line: model, context usage, and rate limits with their reset times.
export LC_ALL=C
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CTX=$(echo "$input" | jq -r '.context_window.used_percentage // empty | round')

# Formats a Unix epoch as a local time; adds the day when it is not today.
fmt_reset() {
  local ts=$1
  if [ "$(date -r "$ts" +%Y-%m-%d)" = "$(date +%Y-%m-%d)" ]; then
    date -r "$ts" +%H:%M
  else
    date -r "$ts" '+%a %d %b %H:%M'
  fi
}

# Prints "<label>: <pct>% (resets <time>)" for one rate-limit window, nothing when absent.
window() {
  local label=$1 key=$2 pct ts
  pct=$(echo "$input" | jq -r ".rate_limits.$key.used_percentage // empty | round")
  ts=$(echo "$input" | jq -r ".rate_limits.$key.resets_at // empty")
  [ -z "$pct" ] && return
  # Colour by the remaining share: red under 20%, yellow under 40%, green otherwise.
  local remaining=$((100 - pct)) color
  if [ "$remaining" -lt 20 ]; then color='\033[31m'
  elif [ "$remaining" -lt 40 ]; then color='\033[33m'
  else color='\033[32m'
  fi
  printf "${color}%s: %s%%" "$label" "$pct"
  [ -n "$ts" ] && printf ' (resets %s)' "$(fmt_reset "$ts")"
  printf '\033[0m'
}

OUT="[$MODEL]"
[ -n "$CTX" ] && OUT="$OUT ctx: $CTX%"
FIVE_H=$(window 5h five_hour)
WEEK=$(window 7d seven_day)
[ -n "$FIVE_H" ] && OUT="$OUT | $FIVE_H"
[ -n "$WEEK" ] && OUT="$OUT | $WEEK"

echo "$OUT"
