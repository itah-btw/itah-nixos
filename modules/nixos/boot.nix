# Boot: systemd-boot with the latest kernel.
{lib, ...}: {
  flake.modules.nixos.boot = {
    lib,
    pkgs,
    ...
  }: {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
