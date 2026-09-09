# Brave — default web browser. Handles web/http(s) via the mime database and
# $BROWSER (for tools that consult the env var instead of xdg-open).
{lib, ...}: {
  flake.modules.homeManager.brave = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      brave-origin
    ];

    # Fallback for tools that consult $BROWSER instead of the mime database.
    home.sessionVariables.BROWSER = "brave-origin";

    xdg.mimeApps.defaultApplications = {
      "text/html" = ["brave-origin.desktop"];
      "application/xhtml+xml" = ["brave-origin.desktop"];
      "x-scheme-handler/http" = ["brave-origin.desktop"];
      "x-scheme-handler/https" = ["brave-origin.desktop"];
      "x-scheme-handler/about" = ["brave-origin.desktop"];
      "x-scheme-handler/unknown" = ["brave-origin.desktop"];
    };
  };
}
