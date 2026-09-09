# Hardware support for this laptop.
{lib, ...}: {
  flake.modules.nixos.hardware = {
    lib,
    pkgs,
    ...
  }: {
    # libinput with natural (two-finger) scrolling on the touchpad.
    services.libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };

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
  };
}
