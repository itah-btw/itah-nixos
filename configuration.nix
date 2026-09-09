# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

let
  # Send a desktop notification into itah's X session from a root systemd unit.
  # Discovers itah's DISPLAY/DBUS address by scanning its process environments;
  # silently exits if no session is up (e.g. headless boot).
  # Usage: notifyItah <appname> <urgency> <summary> [body]
  notifyItah = pkgs.writeShellScript "notify-itah" ''
    set -eu
    export PATH=${pkgs.coreutils}/bin:${pkgs.procps}/bin:${pkgs.gnused}/bin:${pkgs.util-linux}/bin:${pkgs.libnotify}/bin:$PATH
    SESSION_USER="itah"
    _app="''${1:-nixos-upgrade}"
    _urgency="''${2:-normal}"
    _summary="$3"
    _body="$4"
    _display=""
    _dbus=""
    for _pid in $(pgrep -u "$SESSION_USER" || true); do
      _env="$(tr '\0' '\n' < /proc/$_pid/environ 2>/dev/null || true)"
      if [ -z "$_display" ]; then
        _display="$(printf '%s\n' "$_env" | sed -n 's/^DISPLAY=//p' | head -n1)"
      fi
      if [ -z "$_dbus" ]; then
        _dbus="$(printf '%s\n' "$_env" | sed -n 's/^DBUS_SESSION_BUS_ADDRESS=//p' | head -n1)"
      fi
      [ -n "$_display" ] && [ -n "$_dbus" ] && break
    done
    if [ -n "$_display" ] && [ -n "$_dbus" ]; then
      runuser -u "$SESSION_USER" -- env DISPLAY="$_display" DBUS_SESSION_BUS_ADDRESS="$_dbus" \
        notify-send -a "$_app" -u "$_urgency" -- "$_summary" "$_body"
    fi
  '';
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # X11 server with the oxwm window manager.
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    windowManager.oxwm.enable = true;
    # Boot straight into oxwm from tty1 via `startx` (no display manager).
    displayManager.startx.enable = true;
  };

  # Auto-login as `itah` on tty1 once at boot so the machine lands in oxwm.
  services.getty.autologinUser = "itah";
  services.getty.autologinOnce = true;

  # Use libinput with natural (two-finger) scrolling on the touchpad.
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };

  # The xserver module auto-enables speech-dispatcher (and with it
  # espeak-ng/mbrola-voices). Disable it; not needed without a screen reader.
  services.speechd.enable = false;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users."itah" = {
    isNormalUser = true;
    description = "itah";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video" # backlight control (see udev rules below)
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Proton VPN needs asymmetric/split routing for the tunnel.
  networking.firewall.checkReversePath = false;

  # Polkit rules: proton VPN + fingerprint sensor management.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.policykit.exec"
          && action.lookup("program") != null
          && action.lookup("program").indexOf("proton") !== -1
          && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("net.reactivated.fprint") === 0
          && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # Enable flakes and the new nix command
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.auto-optimise-store = true;

  # Daily garbage collection: keep 7 days of generations.
  nix.gc = {
    automatic = true;
    dates = "04:00";
    options = "--delete-older-than 7d";
  };

  # Daily auto-upgrade from the flake remote.
  system.autoUpgrade = {
    enable = true;
    flake = "github:itah-btw/itah-nixos";
    dates = "05:00";
    allowReboot = true;
  };

  # Auto-commit and push /etc/nixos to GitHub. Runs as itah so it picks up
  # itah's SSH key and git identity. Scheduled before the 05:00 auto-upgrade
  # so the upgrade applies whatever is on the remote (including local edits
  # that were never manually committed).
  systemd.services.nixos-git-sync = {
    description = "Commit and push NixOS config changes";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "itah";
      Group = "users";
      WorkingDirectory = "/etc/nixos";
    };
    script = ''
      ${pkgs.git}/bin/git config --global safe.directory /etc/nixos
      ${pkgs.git}/bin/git add -A
      if ! ${pkgs.git}/bin/git diff --cached --quiet; then
        ${pkgs.git}/bin/git commit -m "chore(config): auto-sync $(${pkgs.coreutils}/bin/date -u +%FT%TZ)"
        ${pkgs.git}/bin/git push origin HEAD
      fi
    '';
  };

  systemd.timers.nixos-git-sync = {
    description = "Daily auto-sync NixOS config to GitHub";
    timerConfig = {
      OnCalendar = "*-*-* 04:30:00";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

  # When the machine was off at boot catch-up, make sure local config edits
  # are pushed before the upgrade pulls from the remote.
  systemd.services.nixos-upgrade.after = [ "nixos-git-sync.service" ];

  # Desktop notifications for the auto-upgrade, shown via dunst (see home.nix).
  systemd.services.nixos-upgrade.serviceConfig = {
    ExecStartPre = [ "${notifyItah} nixos-upgrade normal 'NixOS auto-upgrade starting'" ];
    ExecStartPost = [ "${notifyItah} nixos-upgrade normal 'NixOS auto-upgrade finished'" ];
  };

  # Low-battery warnings shown via dunst. Uses notifyItah so hitting itah's X
  # session from this root unit works the same way as the upgrade hooks. Runs
  # every 5 minutes while on battery; notifies once per 5% bucket below 15%.
  systemd.services.battery-low-check = {
    description = "Low battery notification";

    serviceConfig.Type = "oneshot";

    script =
      let
        check = pkgs.writeShellScript "battery-low-check" ''
          set -eu
          battery_dir=""
          for _b in /sys/class/power_supply/BAT*; do
            if [ -d "$_b" ]; then battery_dir="$_b"; break; fi
          done
          [ -n "$battery_dir" ] || exit 0

          capacity="$(cat "$battery_dir/capacity")"
          status="$(cat "$battery_dir/status")"

          # Only warn while discharging; reset the "notified" tracker otherwise.
          if [ "$status" != "Discharging" ] || [ "$capacity" -gt 15 ]; then
            rm -f /var/cache/battery-low-level
            exit 0
          fi

          # Notify once per 5% bucket so it doesn't nag every single check.
          last="$(cat /var/cache/battery-low-level 2>/dev/null || echo 100)"
          last="$((last))"
          bucket="$((capacity / 5))"
          lastbucket="$((last / 5))"
          if [ "$bucket" -ge "$lastbucket" ]; then
            exit 0
          fi
          printf '%s\n' "$capacity" > /var/cache/battery-low-level

          if [ "$capacity" -le 5 ]; then
            "${notifyItah}" battery critical "Battery critical" "$capacity% remaining - plug in the charger!"
          else
            "${notifyItah}" battery normal "Battery low" "$capacity% remaining"
          fi
        '';
      in
      "${check}";
  };

  systemd.timers.battery-low-check = {
    description = "Periodic low battery check";
    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "5m";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

  # Laptop essentials.
  hardware.bluetooth.enable = true;
  services.fstrim.enable = true; # periodic TRIM for the SSD
  services.upower.enable = true; # battery reporting (battery block in the oxwm bar)

  # Fingerprint sensor (ELAN 04f3:0c9f).
  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = true;

  # Let the user control the backlight with brightnessctl without root.
  # Make the sysfs brightness file group-writable for the `video` group.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
  '';

  # Patched programming font with glyphs for the terminal/bar.
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    opencode
    lazygit
    ripgrep
    bat
    proton-vpn # official Proton VPN client
    wireguard-tools # backend used by the proton VPN client
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
