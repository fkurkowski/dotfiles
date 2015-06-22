CUSTOM_SCRIPTS=~/projects/dotfiles/scripts/
export PATH="$CUSTOM_SCRIPTS:${PATH}"

PANEL_FIFO=/tmp/panel-fifo
PANEL_HEIGHT=24
PANEL_FONT_FAMILY="-*-terminus-medium-r-normal-*-12-*-*-*-c-*-*-1"
export PANEL_FIFO PANEL_HEIGHT PANEL_FONTE_FAMILY

setxkbmap br
wmname LG3D
xsetroot -cursor_name left_ptr &
mopidy &
sxhkd & exec bspwm
