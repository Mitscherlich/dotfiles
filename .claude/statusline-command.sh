#!/bin/bash

# Claude Code Status Line
# Blocks:
#   1. Proxy: [P] if under proxy, ⚠️  if not
#   2. Model name (e.g. Opus 4.6)
#   3. Short workdir (last two path components)
#   4. Context window progress bar + percentage
#   5. Session cost
#   6. Usage: 5h:X% 7d:X%

input=$(cat)

if [ -z "$input" ]; then
    printf 'Claude Code'
    exit 0
fi

eval "$(echo "$input" | jq -r '
    @sh "model=\(.model.display_name // "?")",
    @sh "cwd=\(.workspace.current_dir // ".")",
    @sh "used_pct=\(.context_window.used_percentage // 0)",
    @sh "five_h_pct=\(.rate_limits.five_hour.used_percentage // "")",
    @sh "seven_d_pct=\(.rate_limits.seven_day.used_percentage // "")",
    @sh "cost=\(.cost // "")"
')"

# --- Colors ---
RST=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
BRIGHT_GREEN=$'\033[92m'
YELLOW=$'\033[33m'
BRIGHT_YELLOW=$'\033[93m'
RED=$'\033[31m'
BRIGHT_RED=$'\033[91m'
BLUE=$'\033[34m'

SEP="${DIM} │ ${RST}"
BAR_SEGMENTS=12

# --- Color helper ---
pct_color() {
    local pct=$1
    if [ "$pct" -lt 50 ]; then echo "$GREEN"
    elif [ "$pct" -lt 80 ]; then echo "$YELLOW"
    else echo "$RED"
    fi
}
pct_color_bright() {
    local pct=$1
    if [ "$pct" -lt 50 ]; then echo "$BRIGHT_GREEN"
    elif [ "$pct" -lt 80 ]; then echo "$BRIGHT_YELLOW"
    else echo "$BRIGHT_RED"
    fi
}

# --- Block 1: Proxy indicator ---
if [ -n "$HTTPS_PROXY" ] || [ -n "$HTTP_PROXY" ] || [ -n "$https_proxy" ] || [ -n "$http_proxy" ] || [ -n "$ALL_PROXY" ] || [ -n "$all_proxy" ]; then
    proxy_block="${GREEN}[P]${RST}"
else
    proxy_block="⚠️"
fi

# --- Block 2: Model name (strip "Claude " prefix for brevity) ---
model_short="${model#Claude }"
model_block="${CYAN}${BOLD}${model_short}${RST}"

# --- Block 3: Short workdir (last two path components) ---
parent="${cwd%/*}"
parent_short="${parent##*/}"
current_short="${cwd##*/}"
if [ -n "$parent_short" ] && [ "$parent_short" != "$current_short" ]; then
    short_dir="${parent_short}/${current_short}"
else
    short_dir="$current_short"
fi
dir_block="${BLUE}${short_dir}${RST}"

# --- Block 4: Context window progress bar + percentage ---
pct_int=${used_pct%.*}
pct_int=${pct_int:-0}
CTX_COLOR=$(pct_color "$pct_int")

filled=$(( (pct_int * BAR_SEGMENTS + 50) / 100 ))
[ "$filled" -gt "$BAR_SEGMENTS" ] && filled=$BAR_SEGMENTS
empty=$((BAR_SEGMENTS - filled))
filled_bar=$(printf "%${filled}s" | tr ' ' '█')
empty_bar=$(printf "%${empty}s" | tr ' ' '█')
bar="${CTX_COLOR}${filled_bar}${DIM}${CTX_COLOR}${empty_bar}${RST}"
CTX_BRIGHT=$(pct_color_bright "$pct_int")
ctx_block="${bar} ${CTX_BRIGHT}${BOLD}${pct_int}%${RST}"

# --- Block 5: Session cost ---
if [ -n "$cost" ] && [ "$cost" != "null" ]; then
    printf -v cost_str '$%.2f' "$cost"
    cost_block="${DIM}${cost_str}${RST}"
else
    cost_block=""
fi

# --- Block 6: Usage limits ---
usage_block=""
if [ -n "$five_h_pct" ] && [ "$five_h_pct" != "null" ]; then
    pct5=$(printf '%.0f' "$five_h_pct")
    C5=$(pct_color_bright "$pct5")
    usage_block="${DIM}5h:${RST}${C5}${BOLD}${pct5}%${RST}"
fi
if [ -n "$seven_d_pct" ] && [ "$seven_d_pct" != "null" ]; then
    pct7=$(printf '%.0f' "$seven_d_pct")
    C7=$(pct_color_bright "$pct7")
    [ -n "$usage_block" ] && usage_block="${usage_block} "
    usage_block="${usage_block}${DIM}7d:${RST}${C7}${BOLD}${pct7}%${RST}"
fi

# --- Assemble output ---
out="${proxy_block}${SEP}${model_block}${SEP}${dir_block}${SEP}${ctx_block}"
[ -n "$cost_block" ] && out="${out}${SEP}${cost_block}"
[ -n "$usage_block" ] && out="${out}${SEP}${usage_block}"

printf '%s' "$out"
