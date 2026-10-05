#!/usr/bin/env bash
# Click action for Herdr's desktop notifications (invoked by ../bin/notify-send
# via omarchy-notification-send --exec).
#
# There's no notification payload to tell us which pane fired — Herdr's own
# prefix+o hits the same wall for system/terminal delivery (herdrdev/herdr
# #2684), and Yoowatney/dotfiles@ec6677e worked around it the same way: the
# agent that most recently stopped working is simply the highest
# state_change_seq among panes no longer "working". Panes still working are
# excluded on purpose — a notification fires when work ENDS, and a pane that
# resumed since then outranks it without having notified.
#
# That commit rebuilt prefix+o inside Herdr, which only reaches a pane that
# already has keyboard focus inside Herdr's TUI. This script is the same
# recovery run from the notification click instead, so it also raises the
# Hyprland window hosting the herdr client — the thing a key press inside
# Herdr can't do for you.

export PATH="$HOME/.local/bin:/usr/bin:/bin:$PATH"

target_pane=$(herdr agent list 2>/dev/null | jq -r '
  .result.agents
  | map(select(.agent_status == "idle" or .agent_status == "blocked" or .agent_status == "done"))
  | sort_by(-.state_change_seq)
  | .[0].pane_id // empty')

if [[ -n "$target_pane" ]]; then
  herdr agent focus "$target_pane" >/dev/null 2>&1
fi

# Find the Hyprland window whose process tree contains the herdr client (not
# the detached `herdr server`), and raise it. Best-effort: picks the first
# match, which is enough for a single herdr instance.
#
# One `ps` snapshot up front, walked in pure bash from here: a per-node
# pgrep+ps spawns two subprocesses per descendant, and a browser window's
# couple hundred renderer/utility children turned that into a ~1s walk. A
# single table lookup doesn't care how big any window's tree is.
declare -A comm_of children_of
while read -r p pp c; do
  comm_of["$p"]="$c"
  children_of["$pp"]+="$p "
done < <(ps -eo pid=,ppid=,comm= 2>/dev/null)

is_herdr_descendant() {
  local pid="$1" queue=("$1") child
  while ((${#queue[@]})); do
    pid="${queue[-1]}"
    unset 'queue[-1]'
    for child in ${children_of[$pid]:-}; do
      [[ "${comm_of[$child]:-}" == "herdr" ]] && return 0
      queue+=("$child")
    done
  done
  return 1
}

found_address=""
while IFS=$'\t' read -r address pid; do
  if is_herdr_descendant "$pid"; then
    found_address="$address"
    break
  fi
done < <(hyprctl clients -j 2>/dev/null | jq -r '.[] | "\(.address)\t\(.pid)"')

if [[ -n "$found_address" ]]; then
  # Hyprland 0.55+ dropped the old `focuswindow address:0x...` dispatch
  # string for a Lua dispatcher table: `dispatch` now expects an expression
  # built from hl.dsp.*, not space-separated argv (see wiki.hypr.land
  # Configuring/Basics/Dispatchers — "focus({ window })" takes the same
  # window selectors, address: included, as a Lua string).
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$found_address\" })" >/dev/null 2>&1
fi
