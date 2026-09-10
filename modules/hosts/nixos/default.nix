# NixOS host configuration for the machine "nixos".
#
# This is the only file that composes aspects: it decides which
# `flake.modules.nixos.*` and `flake.modules.homeManager.*` modules are active
# for this machine. Every other `.nix` file under `modules/` is a feature
# module that nothing else knows about by path.
{
  config,
  inputs,
  ...
}: let
  username = "itah";
  stateVersion = "26.05";
in {
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      # Generated at install time, do not hand-edit.
      ../../../hardware-configuration.nix

      # home-manager as a NixOS module (from the flake input).
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;

          users.${username} = {
            imports = with config.flake.modules.homeManager; [
              session
              st
              oxwm
              dunst
              copy
              sxhkd
              yazi
              brave
              neovim
              imv
              mpv
              zathura
              libreoffice
              utilities
            ];
            home = {
              inherit username;
              homeDirectory = "/home/${username}";
              inherit stateVersion;
            };
          };
        };
      }

      # Per-machine versions; only bump after reading the release notes.
      {system.stateVersion = stateVersion;}

      # System aspects (NixOS).
      config.flake.modules.nixos.boot
      config.flake.modules.nixos.network
      config.flake.modules.nixos.locale
      config.flake.modules.nixos.hardware
      config.flake.modules.nixos.desktop
      config.flake.modules.nixos.oxwm
      config.flake.modules.nixos.security
      config.flake.modules.nixos.nix
      config.flake.modules.nixos.maintenance
      config.flake.modules.nixos.packages
    ];
  };
}
