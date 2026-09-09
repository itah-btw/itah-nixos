# Scheduled maintenance: git auto-sync, auto-upgrade notifications, and low
# battery warnings. All notifications reach itah's X session via notifyItah.
{lib, ...}: {
  flake.modules.nixos.maintenance = {
    lib,
    pkgs,
    ...
  }: let
    # Send a desktop notification into itah's X session from a root systemd
    # unit. Discovers itah's DISPLAY/DBUS address by scanning its process
    # environments; silently exits if no session is up (e.g. headless boot).
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
  in {
    users.users."itah" = {
      isNormalUser = true;
      description = "itah";
      extraGroups = [
        "networkmanager"
        "wheel"
        "video" # backlight control (see udev rules in hardware.nix)
      ];
    };

    # Auto-commit and push /etc/nixos to GitHub. Runs as itah so it picks up
    # itah's SSH key and git identity. Scheduled before the 05:00 auto-upgrade
    # so the upgrade applies whatever is on the remote (including local edits
    # that were never manually committed).
    systemd.services.nixos-git-sync = {
      description = "Commit and push NixOS config changes";
      after = ["network-online.target"];
      wants = ["network-online.target"];
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
      wantedBy = ["timers.target"];
    };

    # When the machine was off at boot catch-up, make sure local config edits
    # are pushed before the upgrade pulls from the remote.
    systemd.services.nixos-upgrade.after = ["nixos-git-sync.service"];

    # Desktop notifications for the auto-upgrade, shown via dunst (see
    # modules/home/apps/dunst.nix).
    systemd.services.nixos-upgrade.serviceConfig = {
      ExecStartPre = ["${notifyItah} nixos-upgrade normal 'NixOS auto-upgrade starting'"];
      ExecStartPost = ["${notifyItah} nixos-upgrade normal 'NixOS auto-upgrade finished'"];
    };

    # Low-battery warnings shown via dunst. Uses notifyItah so hitting itah's
    # X session from this root unit works the same way as the upgrade hooks.
    # Runs every 5 minutes while on battery; notifies once per 5% bucket below
    # 15%.
    systemd.services.battery-low-check = {
      description = "Low battery notification";

      serviceConfig.Type = "oneshot";

      script = let
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
      in "${check}";
    };

    systemd.timers.battery-low-check = {
      description = "Periodic low battery check";
      timerConfig = {
        OnBootSec = "10m";
        OnUnitActiveSec = "5m";
        Persistent = true;
      };
      wantedBy = ["timers.target"];
    };
  };
}
