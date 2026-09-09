# imv — image viewer.
{lib, ...}: {
  flake.modules.homeManager.imv = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      imv
    ];

    xdg.mimeApps.defaultApplications = {
      "image/bmp" = ["imv.desktop"];
      "image/gif" = ["imv.desktop"];
      "image/jpeg" = ["imv.desktop"];
      "image/png" = ["imv.desktop"];
      "image/tiff" = ["imv.desktop"];
      "image/webp" = ["imv.desktop"];
      "image/svg+xml" = ["imv.desktop"];
      "image/avif" = ["imv.desktop"];
      "image/heic" = ["imv.desktop"];
      "image/heif" = ["imv.desktop"];
      "image/x-tga" = ["imv.desktop"];
      "image/x-portable-bitmap" = ["imv.desktop"];
      "image/x-portable-graymap" = ["imv.desktop"];
      "image/x-portable-pixmap" = ["imv.desktop"];
    };
  };
}
