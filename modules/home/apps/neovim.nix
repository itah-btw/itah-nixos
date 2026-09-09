# Neovim — editor for source/text files. The package itself lives in the system
# profile (modules/nixos/packages.nix) so it's available before the user logs
# in; this aspect only wires up its desktop entry and file associations.
{lib, ...}: {
  flake.modules.homeManager.neovim = {lib, ...}: {
    # Desktop entry: nvim opens in an st terminal.
    xdg.desktopEntries.nvim = {
      name = "Neovim";
      exec = "st -e nvim %F";
      terminal = false;
      noDisplay = true;
    };

    xdg.mimeApps.defaultApplications = {
      # Text / source code → nvim (in st)
      "text/plain" = ["nvim.desktop"];
      "text/x-shellscript" = ["nvim.desktop"];
      "text/markdown" = ["nvim.desktop"];
      "text/x-markdown" = ["nvim.desktop"];
      "text/x-c" = ["nvim.desktop"];
      "text/x-csrc" = ["nvim.desktop"];
      "text/x-chdr" = ["nvim.desktop"];
      "text/x-c++src" = ["nvim.desktop"];
      "text/x-c++hdr" = ["nvim.desktop"];
      "text/x-python" = ["nvim.desktop"];
      "text/x-ruby" = ["nvim.desktop"];
      "text/x-perl" = ["nvim.desktop"];
      "text/x-java" = ["nvim.desktop"];
      "text/x-php" = ["nvim.desktop"];
      "text/x-rust" = ["nvim.desktop"];
      "text/x-go" = ["nvim.desktop"];
      "text/x-lisp" = ["nvim.desktop"];
      "text/x-scheme" = ["nvim.desktop"];
      "text/x-haskell" = ["nvim.desktop"];
      "text/x-lua" = ["nvim.desktop"];
      "text/x-tcl" = ["nvim.desktop"];
      "text/x-asm" = ["nvim.desktop"];
      "text/x-makefile" = ["nvim.desktop"];
      "application/x-makefile" = ["nvim.desktop"];
      "text/x-cmake" = ["nvim.desktop"];
      "text/x-json" = ["nvim.desktop"];
      "application/json" = ["nvim.desktop"];
      "text/x-yaml" = ["nvim.desktop"];
      "text/yaml" = ["nvim.desktop"];
      "text/xml" = ["nvim.desktop"];
      "application/xml" = ["nvim.desktop"];
      "text/x-sql" = ["nvim.desktop"];
      "text/x-diff" = ["nvim.desktop"];
      "text/x-patch" = ["nvim.desktop"];
      "text/x-vim" = ["nvim.desktop"];
      "text/x-tex" = ["nvim.desktop"];
      "text/x-nix" = ["nvim.desktop"];
      "application/x-nix" = ["nvim.desktop"];
      "text/x-dockerfile" = ["nvim.desktop"];
      "text/css" = ["nvim.desktop"];
      "text/x-javascript" = ["nvim.desktop"];
      "text/javascript" = ["nvim.desktop"];
      "application/javascript" = ["nvim.desktop"];
    };
  };
}
