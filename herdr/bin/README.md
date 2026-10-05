# Herdr notification click shim (experimental)

Problem: Herdr's desktop notifications aren't clickable (herdrdev/herdr#2684,
closed upstream as intended). `notify-send` is the actual mechanism — see
`notify-send` and `herdr-notify-focus.sh` in this directory for the full story.

Not linked onto PATH yet. To test it:

```sh
mkdir -p ~/.local/bin
ln -s ~/.config/herdr/bin/notify-send ~/.local/bin/notify-send
```

`~/.local/bin` already comes before `/usr/bin` on PATH (see `mise` shims), so
this shadows the real `notify-send` for everything launched from a shell that
has sourced the usual profile. Trigger a Herdr notification (e.g. let an
agent pane go idle) and click the toast — it should jump to the most recently
finished agent and raise the window.

To remove: `rm ~/.local/bin/notify-send`.
