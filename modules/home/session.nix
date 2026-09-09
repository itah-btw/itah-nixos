# Session glue: shell, aliases, and the X bootstrap that lands in oxwm.
# Also turns on xdg so the per-app mime/desktop settings take effect.
{lib, ...}: {
  flake.modules.homeManager.session = {lib, ...}: {
    # Boot into oxwm: auto-login on tty1 drops into a login shell, which runs
    # startx; xinitrc then starts oxwm. No display manager involved.
    programs.bash.profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec startx
      fi
    '';

    home.file.".xinitrc".text = ''
      dunst &
      exec oxwm
    '';

    # System-wide file associations framework. Individual apps declare their
    # own bindings in their aspect (xdg.mimeApps.defaultApplications).
    xdg = {
      enable = true;
      mimeApps.enable = true;
    };

    programs.bash = {
      enable = true;
      shellAliases = {
        # Rebuild & test
        nrs = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
        nrt = "sudo nixos-rebuild test --flake /etc/nixos#nixos";
        nbo = "sudo nixos-rebuild boot --flake /etc/nixos#nixos";

        # Edit config
        ne = "$EDITOR /etc/nixos/modules/hosts/nixos/default.nix";
        ns = "$EDITOR /etc/nixos/modules/nixos";
        nh = "$EDITOR /etc/nixos/modules/home/apps";
        nf = "$EDITOR /etc/nixos/flake.nix";

        # Format (Alejandra, the flake's formatter)
        nfmt = "alejandra /etc/nixos";
        nfmtc = "alejandra --check /etc/nixos";

        # Update inputs
        nu = "nix flake update /etc/nixos";

        # Generations & cleanup
        ngen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
        ngc = "sudo nix-collect-garbage -d";
        ngcu = "sudo nix-collect-garbage --delete-older-than 7d";

        # Quick info
        neval = "nix eval .#nixosConfigurations.nixos.config.system.stateVersion";

        # Cleanup backup dirs after rebuild
        nbc = "sudo rm -rf /etc/nixos.backup.*";
      };
    };
  };
}
