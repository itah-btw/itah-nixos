# dunst — notification daemon (launched in .xinitrc). Tuned for this machine:
# monospace nerd font, progress bars, click-to-activate, and rules that keep
# the nixos-upgrade systemd hooks (notify-itah) on screen long enough.
{lib, ...}: {
  flake.modules.homeManager.dunst = {lib, ...}: {
    xdg.configFile."dunst/dunstrc".text = ''
      [global]
          monitor = 0
          follow = mouse
          geometry = "310x-30+12+12"
          notification_limit = 6
          progress_bar = true
          progress_bar_height = 6
          progress_bar_frame_width = 0
          progress_bar_min_width = 150
          progress_bar_max_width = 300
          icon_position = left
          min_icon_size = 48
          max_icon_size = 64
          enable_recursive_icon_lookup = true
          stack_duplicates = true
          hide_duplicate_count = false
          show_age_threshold = 60
          history_length = 30
          font = "JetBrainsMono Nerd Font 10"
          line_height = 0
          markup = full
          format = "<i>%a</i>\n<b>%s</b>\n%b"
          alignment = left
          word_wrap = true
          ellipsize = middle
          ignore_newline = false
          show_indicators = true
          indicate_hidden = true
          idle_threshold = 10
          browser = brave-origin
          separator_color = frame
          separator_height = 2
          frame_width = 2
          padding = 6
          horizontal_padding = 8
          text_icon_padding = 8
          mouse_left_click = do_action
          mouse_middle_click = close_current
          mouse_right_click = close_all

      # Gruvbox dark palette.
      [urgency_low]
          background = "#282828"
          foreground = "#ebdbb2"
          frame_color = "#928374"
          highlight = "#a89984"
          timeout = 6

      [urgency_normal]
          background = "#282828"
          foreground = "#ebdbb2"
          frame_color = "#83a598"
          highlight = "#d79921"
          timeout = 10

      [urgency_critical]
          background = "#282828"
          foreground = "#ebdbb2"
          frame_color = "#fb4934"
          highlight = "#fe8019"
          timeout = 0

      # NixOS auto-upgrade hooks (notify-itah in maintenance.nix). Longer
      # timeout so start/finish of a slow upgrade isn't missed.
      [nixos-upgrade]
          appname = "nixos-upgrade"
          urgency = normal
          timeout = 30

      # Web notifications from Brave (Discord, mail, ...). Keep them visible a
      # while, but let them group so the corner doesn't fill up.
      [brave]
          appname = "Brave*"
          urgency = normal
          timeout = 8

      # OSD popups from the volume/brightness Fn keys (see sxhkdrc). Transient
      # and short so they never pile up or linger in history.
      [volume]
          appname = "volume"
          timeout = 2
          set_transient = true

      [mic]
          appname = "mic"
          timeout = 2
          set_transient = true

      [brightness]
          appname = "brightness"
          timeout = 2
          set_transient = true

      # Screenshots (oxwm Super+S). Normal (non-transient) so it stays until
      # closed; left-click opens the saved image in imv (see config.lua).
      [screenshot]
          appname = "screenshot"
          timeout = 5

      # Clipmenu paste (oxwm Super+V): transient preview of what was copied.
      [clipmenu]
          appname = "clipmenu"
          timeout = 3
          set_transient = true
    '';
  };
}
