# Copy notifications — a tiny daemon that pops a dunst OSD whenever text is
# copied to the X CLIPBOARD (st Ctrl+Shift+C, Ctrl+C in browsers/office apps,
# ...). `copy-notify-daemon` sleeps on clipnotify (which blocks until the
# CLIPBOARD selection changes), then shows the copied snippet via dunstify.
# Launched from oxwm autostart (config.lua) like clipmenud/sxhkd. flock guards
# against duplicate instances across session restarts.
{lib, ...}: {
  flake.modules.homeManager.copy = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = [
      pkgs.clipnotify # blocks until the CLIPBOARD selection changes
      pkgs.xclip # read the copied text

      (pkgs.writeShellScriptBin "copy-notify-daemon" ''
        #!/bin/sh
        set -e
        # Only one daemon may run (e.g. stale one from a previous session).
        exec 9>/tmp/copy-notify.lock
        ${pkgs.util-linux}/bin/flock -n 9 || exit 0

        prev=""
        while :; do
          if ! ${pkgs.clipnotify}/bin/clipnotify; then
            sleep 1 # X not up (yet); retry instead of spinning
            continue
          fi
          # First line of the copied text is enough for a preview.
          cur="$(${pkgs.xclip}/bin/xclip -selection clipboard -o 2>/dev/null | ${pkgs.coreutils}/bin/tr -d '\r' | ${pkgs.coreutils}/bin/head -n1)"
          if [ -n "$cur" ] && [ "$cur" != "$prev" ]; then
            ${pkgs.dunst}/bin/dunstify -a copy -r 3005 -u low "Copied to clipboard" "$cur"
          fi
          prev="$cur"
        done
      '')
    ];
  };
}
