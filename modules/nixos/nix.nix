# Nix daemon settings, GC, and auto-upgrade.
{lib, ...}: {
  flake.modules.nixos.nix = {lib, ...}: {
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
  };
}
