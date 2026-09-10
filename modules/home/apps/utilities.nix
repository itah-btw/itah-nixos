# Everyday desktop utilities. These apps have no dotfiles of their own, so they
# share one aspect; anything that grows a config gets promoted to its own file.
{lib, ...}: {
  flake.modules.homeManager.utilities = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      # Launchers / clipboard (oxwm binds: dmenu for Super+D, clipmenu Super+V)
      dmenu
      clipmenu # clipboard history daemon + dmenu picker (st paste)
      xsel
      libnotify # notify-send, used by the systemd notify hooks

      # Fn-key / session support
      brightnessctl # backlight control (Fn keys)
      pamixer # volume control (Fn keys)
      playerctl # media keys
      upower # battery status
      sxhkd # X hotkey daemon for Fn/media keys

      # Wallpaper / screenshots / recording
      feh # wallpaper setter
      scrot # screenshot (oxwm Super+S)
      obs-studio # screen recording/streaming

      # System info
      btop # system monitor
      fastfetch # system info
      pciutils
      usbutils

      git # version control for /etc/nixos and projects

      # Files / devices
      localsend # LAN file sharing
      android-tools # adb/fastboot for phones
    ];
  };
}
