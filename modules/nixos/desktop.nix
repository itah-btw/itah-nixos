# X11 server with the oxwm window manager (boots via startx, no display manager).
{lib, ...}: {
  flake.modules.nixos.desktop = {lib, ...}: {
    services.xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
      # Boot straight into oxwm from tty1 via `startx` (no display manager).
      displayManager.startx.enable = true;
    };

    # Auto-login as `itah` on tty1 once at boot so the machine lands in oxwm.
    services.getty.autologinUser = "itah";
    services.getty.autologinOnce = true;

    # The xserver module auto-enables speech-dispatcher (and with it
    # espeak-ng/mbrola-voices). Disable it; not needed without a screen reader.
    services.speechd.enable = false;
  };
}
