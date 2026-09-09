# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."itah" = {
    isNormalUser = true;
    description = "itah";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video" # backlight control (see udev rules below)
    ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Proton VPN needs asymmetric/split routing for the tunnel.
  networking.firewall.checkReversePath = false;

  # Let the proton VPN client elevate via pkexec without a polkit agent prompt.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.policykit.exec"
          && action.lookup("program") != null
          && action.lookup("program").indexOf("proton") !== -1
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

  # Laptop essentials.
  hardware.bluetooth.enable = true;
  services.fstrim.enable = true; # periodic TRIM for the SSD
  services.upower.enable = true; # battery reporting (battery block in the oxwm bar)

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
