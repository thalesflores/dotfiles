#!/usr/bin/env bash
# Claude Code status line — dimmed, p10k-inspired segments:
# repo + git branch/dirty | model (+effort) | ctx remaining % | cost | time

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
age_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')

# Colors — all dim, in the spirit of a subdued p10k prompt
reset='\033[0m'
dir_color='\033[2;38;5;110m'
git_color='\033[2;38;5;114m'
dirty_color='\033[2;38;5;167m'
model_color='\033[2;38;5;183m'
effort_color='\033[2;38;5;140m'
ctx_ok='\033[2;38;5;114m'
ctx_warn='\033[2;38;5;179m'
ctx_crit='\033[2;38;5;167m'
cost_color='\033[2;38;5;245m'
age_ok='\033[2;38;5;114m'
age_warn='\033[2;38;5;179m'
age_crit='\033[1;38;5;167m'
limits_color='\033[2;38;5;109m'
sep_color='\033[2;38;5;238m'

dir_name=$(basename "${cwd:-$PWD}")

# --- Git branch + dirty state (skip optional locks; read-only, no repo mutation)
branch=""
dirty_count=0
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  # Repo name from the shared .git dir, so a worktree folder (<repo>-<branch slug>) shows as <repo>
  common_dir=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
  [ -n "$common_dir" ] && dir_name=$(basename "$(dirname "$common_dir")")
  if [ -n "$branch" ]; then
    dirty_count=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    [ "${#branch}" -gt 30 ] && branch="${branch:0:29}…"
  fi
fi

parts=()

# 1) repo + git branch (+ dirty marker)
loc="$(printf "${dir_color}%s${reset}" "$dir_name")"
if [ -n "$branch" ]; then
  loc="${loc}$(printf " ${git_color}⎇ %s${reset}" "$branch")"
  if [ "$dirty_count" -gt 0 ] 2>/dev/null; then
    loc="${loc}$(printf " ${dirty_color}●${reset}")"
  fi
fi
parts+=("$loc")

# 2) model (+ reasoning effort, if the harness exposes it)
if [ -n "$model" ]; then
  if [ -n "$effort" ]; then
    parts+=("$(printf "${model_color}%s${reset} ${effort_color}(%s)${reset}" "$model" "$effort")")
  else
    parts+=("$(printf "${model_color}%s${reset}" "$model")")
  fi
fi

# 3) context window used percentage
if [ -n "$remaining_pct" ]; then
  used_pct=$(echo "$remaining_pct" | awk '{printf "%.0f", 100 - $1}')
  ctx_color="$ctx_ok"
  if [ "$used_pct" -ge 80 ]; then
    ctx_color="$ctx_crit"
  elif [ "$used_pct" -ge 50 ]; then
    ctx_color="$ctx_warn"
  fi
  parts+=("$(printf "${ctx_color}ctx %s%%${reset}" "$used_pct")")
fi

# 4) session cost, if the harness reports it (omitted cleanly otherwise)
if [ -n "$cost" ]; then
  cost_display=$(printf '%.2f' "$cost")
  parts+=("$(printf "${cost_color}\$%s${reset}" "$cost_display")")
fi

# 5) session wall-clock age -- a "switch tasks, /clear" reminder (cache TTL is 1h since the last turn, not session start).
if [ -n "$age_ms" ]; then
  age_min=$(echo "$age_ms" | awk '{printf "%d", $1/60000}')
  age_color="$age_ok"
  age_suffix=""
  if [ "$age_min" -ge 90 ]; then
    age_color="$age_crit"
    age_suffix=" /clear"
  elif [ "$age_min" -ge 45 ]; then
    age_color="$age_warn"
  fi
  if [ "$age_min" -ge 60 ]; then
    age_label=$(printf '%dh%02dm' $((age_min / 60)) $((age_min % 60)))
  else
    age_label=$(printf '%dm' "$age_min")
  fi
  parts+=("$(printf "${age_color}age %s%s${reset}" "$age_label" "$age_suffix")")
fi

# 6) rate limits (5h / weekly / model-scoped weekly) + usage credits
limits=$(printf '%s' "$input" | python3 "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/my-usage/usage-limits-segment.py" 2>/dev/null)
credits=$(python3 "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/my-usage/usage-credits-segment.py" 2>/dev/null)
[ -n "$limits" ] && parts+=("$(printf "${limits_color}%s${reset}" "$limits")")
[ -n "$credits" ] && parts+=("$(printf "${cost_color}%s${reset}" "$credits")")

# Join with a dim separator
sep="$(printf "${sep_color} │ ${reset}")"
result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="${result}${sep}${part}"
  fi
done

printf "%b\n" "$result"
