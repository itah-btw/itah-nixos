# Locale, timezone and fonts.
{lib, ...}: {
  flake.modules.nixos.locale = {
    lib,
    pkgs,
    ...
  }: {
    time.timeZone = "Asia/Jakarta";
    i18n.defaultLocale = "en_US.UTF-8";

    # Patched programming font with glyphs for the terminal/bar.
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };
}
