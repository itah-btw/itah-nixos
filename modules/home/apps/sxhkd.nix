# sxhkd — X hotkey daemon for Fn/media keys (oxwm owns its own Super+ binds).
# Volume, brightness, and mic changes show a transient dunst OSD with a progress
# bar (matched by the [volume]/[brightness]/[mic] rules in dunst.nix). OSDs use
# dunstify with a fixed replace id so rapid/held keypresses update the single
# live popup instead of spamming new ones.
#
# NOTE: sxhkd joins every line of a multi-line command with ';', so shell
# backslash continuations are NOT possible here — keep each command on one
# line, or the trailing '\' mangles the next statement.
{lib, ...}: {
  flake.modules.homeManager.sxhkd = {lib, ...}: {
    xdg.configFile."sxhkd/sxhkdrc".text = ''
      # Brightness
      XF86MonBrightnessUp
          brightnessctl set +5%
          b=$(( $(brightnessctl get) * 100 / $(brightnessctl max) ))
          dunstify -a brightness -r 3001 -u low -h int:value:$b "Brightness"
      XF86MonBrightnessDown
          brightnessctl set 5%-
          b=$(( $(brightnessctl get) * 100 / $(brightnessctl max) ))
          dunstify -a brightness -r 3001 -u low -h int:value:$b "Brightness"

      # Volume
      XF86AudioRaiseVolume
          pamixer --increase 5
          dunstify -a volume -r 3000 -u low -h int:value:$(pamixer --get-volume) "Volume $(pamixer --get-volume)%"
      XF86AudioLowerVolume
          pamixer --decrease 5
          dunstify -a volume -r 3000 -u low -h int:value:$(pamixer --get-volume) "Volume $(pamixer --get-volume)%"
      XF86AudioMute
          pamixer --toggle-mute
          if [ "$(pamixer --get-mute)" = "true" ]; then dunstify -a volume -r 3000 -u low "Volume" "Muted"; else dunstify -a volume -r 3000 -u low -h int:value:$(pamixer --get-volume) "Volume $(pamixer --get-volume)%"; fi

      # Media
      XF86AudioPlay
          playerctl play-pause
      XF86AudioNext
          playerctl next
      XF86AudioPrev
          playerctl previous

      # App launchers (Super+Shift+<key>; oxwm owns plain Super+<key>)
      super+shift+b
          brave-origin
      super+shift+e
          st -e yazi
      super+shift+a
          st -e opencode
      super+shift+s
          localsend
      super+shift+l
          libreoffice
      super+shift+o
          obs

      # Mic mute
      super+m
          pamixer --default-source --toggle-mute
          if [ "$(pamixer --default-source --get-mute)" = "true" ]; then dunstify -a mic -r 3002 -u low "Mic" "Muted"; else dunstify -a mic -r 3002 -u low "Mic" "Unmuted"; fi
    '';
  };
}
