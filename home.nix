{ config, pkgs, ... }:

{
  home.username = "itah";
  home.homeDirectory = "/home/itah";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # Boot into oxwm: auto-login on tty1 drops into a login shell, which runs
  # startx; xinitrc then starts oxwm. No display manager involved.
  home.file.".bash_profile".text = ''
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec startx
    fi
  '';
  home.file.".xinitrc".text = ''
    exec oxwm
  '';

  # Programs spawned by the default oxwm keybindings (Super+Return / Super+D).
  home.packages = with pkgs; [
    (st.overrideAttrs (old: {
      # JetBrains Mono Nerd Font at size 11 (inlined; see fonts.packages below).
      patches = (old.patches or [ ]) ++ [
        (pkgs.writeText "st-font.patch" ''
          diff --git a/config.def.h b/config.def.h
          index 1111111..2222222 100644
          --- a/config.def.h
          +++ b/config.def.h
          @@ -7,2 +7,2 @@
            */
          -static char *font = "Liberation Mono:pixelsize=12:antialias=true:autohint=true";
          +static char *font = "JetBrainsMono Nerd Font:size=11:antialias=true:autohint=true";
        '')
      ];
    }))
    dmenu
    feh # wallpaper setter
    brave-origin # browser
    yazi # terminal file manager
    chafa # image preview for yazi (semi-graphics mode in terminal)
    localsend # LAN file sharing
    libreoffice # office suite
    zathura # PDF viewer (bundles mupdf/poppler plugins)
    brightnessctl # backlight control (Fn keys)
    pamixer # volume control (Fn keys)
    playerctl # media keys
    upower # battery status
    pciutils
    usbutils
    sxhkd # X hotkey daemon for Fn/media keys
    android-tools # adb/fastboot for phones
    mpv # video player
    imv # image viewer
    btop # system monitor
    fastfetch # system info
    scrot # screenshot
    git # version control for /etc/nixos and projects
    obs-studio # screen recording/streaming
    clipmenu # clipboard history daemon + dmenu picker (st paste)
    clipnotify
    xsel
  ];

  # Fn (brightness/volume) and media key bindings for the laptop.
  xdg.configFile."sxhkd/sxhkdrc".text = ''
    # Brightness
    XF86MonBrightnessUp
        brightnessctl set +5%
    XF86MonBrightnessDown
        brightnessctl set 5%-

    # Volume
    XF86AudioRaiseVolume
        pamixer --increase 5
    XF86AudioLowerVolume
        pamixer --decrease 5
    XF86AudioMute
        pamixer --toggle-mute

    # Media
    XF86AudioPlay
        playerctl play-pause
    XF86AudioNext
        playerctl next
    XF86AudioPrev
        playerctl previous
  '';
}
