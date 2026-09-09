# System-wide packages (root-scoped tools; per-user apps live in modules/home).
{lib, ...}: {
  flake.modules.nixos.packages = {
    lib,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      neovim # editor used to edit this config; nano is also installed by default
      wget
      opencode
      lazygit
      ripgrep
      bat
      alejandra # nix code formatter (nix fmt / nfmtc)
      proton-vpn # official Proton VPN client
      wireguard-tools # backend used by the proton VPN client
    ];
  };
}
