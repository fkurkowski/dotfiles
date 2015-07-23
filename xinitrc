CUSTOM_SCRIPTS=~/projects/dotfiles/scripts/
export PATH="$CUSTOM_SCRIPTS:${PATH}"

setxkbmap br
wmname LG3D
xsetroot -cursor_name left_ptr &
mopidy &
sxhkd & exec bspwm
