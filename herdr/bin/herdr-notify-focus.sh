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

set -euo pipefail

export PATH="$HOME/.local/bin:/usr/bin:/bin:$PATH"

target_pane=$(herdr agent list 2>/dev/null | jq -r '
  .result.agents
  | map(select(.agent_status == "idle" or .agent_status == "blocked" or .agent_status == "done"))
  | sort_by(-.state_change_seq)
  | .[0].pane_id // empty')

if [[ -n "$target_pane" ]]; then
  herdr agent focus "$target_pane" >/dev/null 2>&1 || true
fi

# Find the Hyprland window whose process tree contains the herdr client (not
# the detached `herdr server`), and raise it. Best-effort: picks the first
# match, which is enough for a single herdr instance.
is_herdr_descendant() {
  local pid="$1" children child
  children=$(pgrep -P "$pid" 2>/dev/null) || return 1
  for child in $children; do
    [[ "$(ps -o comm= -p "$child" 2>/dev/null)" == "herdr" ]] && return 0
    is_herdr_descendant "$child" && return 0
  done
  return 1
}

hyprctl clients -j 2>/dev/null | jq -r '.[] | "\(.address)\t\(.pid)"' | while IFS=$'\t' read -r address pid; do
  if is_herdr_descendant "$pid"; then
    hyprctl dispatch focuswindow "address:$address" >/dev/null 2>&1
    break
  fi
done
