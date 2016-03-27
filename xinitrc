CUSTOM_SCRIPTS=~/projects/dotfiles/scripts/
export PATH="$CUSTOM_SCRIPTS:${PATH}"

setxkbmap br
xsetroot -cursor_name left_ptr &
mopidy &
sxhkd & exec bspwm
