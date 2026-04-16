#!/bin/bash

# Claude Code Status Line
# Blocks:
#   1. Proxy: [P] if under proxy, ⚠️  if not
#   2. Model name (e.g. Opus 4.6)
#   3. Smart workdir (git-aware: repo-relative / ~/relative / absolute)
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

# --- Block 1: Proxy indicator (cached async check) ---
PROXY_EXPECTED_IP="xx.xx.xx.xx"
PROXY_CACHE="/tmp/.claude_proxy_status"
PROXY_CHECK_TTL=3600

proxy_status="none"

if [ -n "$HTTPS_PROXY" ] || [ -n "$HTTP_PROXY" ] || [ -n "$https_proxy" ] || [ -n "$http_proxy" ] || [ -n "$ALL_PROXY" ] || [ -n "$all_proxy" ]; then
    proxy_status="checking"

    if [ -f "$PROXY_CACHE" ]; then
        cache_mtime=$(stat -f %m "$PROXY_CACHE" 2>/dev/null || echo 0)
        now=$(date +%s)
        cache_age=$((now - cache_mtime))
        if [ "$cache_age" -lt "$PROXY_CHECK_TTL" ]; then
            proxy_status=$(cat "$PROXY_CACHE")
        fi
    fi

    if [ "$proxy_status" = "checking" ]; then
        (
            ip=$(curl -s --max-time 5 -x "http://127.0.0.1:7890" ipinfo.io/json 2>/dev/null \
                | sed -n 's/.*"ip" *: *"\([^"]*\)".*/\1/p')
            if [ -z "$ip" ]; then
                echo "fail"
            elif [ "$ip" = "$PROXY_EXPECTED_IP" ]; then
                echo "ok"
            else
                echo "mismatch"
            fi > "$PROXY_CACHE"
        ) </dev/null >/dev/null 2>&1 &
    fi
fi

case "$proxy_status" in
    ok)       proxy_block="${GREEN}[P✓]${RST}" ;;
    mismatch) proxy_block="${RED}[P✗]${RST}" ;;
    fail)     proxy_block="${YELLOW}[P!]${RST}" ;;
    checking) proxy_block="${YELLOW}[P…]${RST}" ;;
    *)        proxy_block="⚠️" ;;
esac

# --- Block 2: Model name (strip "Claude " prefix for brevity) ---
model_short="${model#Claude }"
model_block="${CYAN}${BOLD}${model_short}${RST}"

# --- Block 3: Smart workdir ---
# Rule 1: git repo → relative from repo root, keep last 1-2 levels; at root → basename
# Rule 2: under $HOME → ~/relative; at $HOME → 🏠
# Rule 3: elsewhere → absolute path
git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)

if [ -n "$git_root" ]; then
    if [ "$cwd" = "$git_root" ]; then
        short_dir="${git_root##*/}"
    else
        rel="${cwd#"$git_root"/}"
        last="${rel##*/}"
        rest="${rel%/*}"
        if [ "$rest" = "$rel" ]; then
            # 1 level deep: show as-is
            short_dir="$rel"
        else
            # 2+ levels: keep last 2 components
            short_dir="${rest##*/}/${last}"
        fi
    fi
elif [ "$cwd" = "$HOME" ]; then
    short_dir="🏠"
elif [ "${cwd#"$HOME"/}" != "$cwd" ]; then
    short_dir="~/${cwd#"$HOME"/}"
else
    short_dir="$cwd"
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
