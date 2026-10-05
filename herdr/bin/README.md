# Herdr notification click shim (experimental)

Problem: Herdr's desktop notifications aren't clickable (herdrdev/herdr#2684,
closed upstream as intended). `notify-send` is the actual mechanism — see
`notify-send` and `herdr-notify-focus.sh` in this directory for the full story.

Linked and verified working:

```sh
sudo ln -s ~/.config/herdr/bin/notify-send /usr/local/bin/notify-send
```

`~/.local/bin` does NOT work here — Omarchy's own bash bootstrap
(`/usr/share/omarchy/default/bash/env-bootstrap`) deliberately appends it
*after* `/usr/bin`, confirmed against herdr server's actual running
environment. `/usr/local/bin` is the one override directory that already
comes before `/usr/bin` for every process on this machine, including herdr's
already-running server, so this symlink takes effect immediately — no shell
restart, no PATH edit, no need to restart herdr.

Clicking a Herdr toast now jumps to the most recently finished agent and
raises the window, in well under a tenth of a second.

To remove: `sudo rm /usr/local/bin/notify-send`.
