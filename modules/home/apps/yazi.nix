# yazi — terminal file manager. Includes the compress.yazi plugin (archive
# selected files from yazi) and maps archives to yazi.
{lib, ...}: {
  flake.modules.homeManager.yazi = {
    lib,
    pkgs,
    ...
  }: let
    # Compress plugin: creates archives from selected files (`c a`).
    # Only main.lua is needed; the entry lives in ~/.config/yazi/plugins.
    compressPlugin = pkgs.fetchFromGitHub {
      owner = "KKV9";
      repo = "compress.yazi";
      rev = "80e5268ec74c7ac17d4d739e13a9958cba4c70d3";
      hash = "sha256-9cdA8D/TtwHcLqrtoyIixA0YJmTs+c8FSNrjxp8CYI0=";
    };
  in {
    home.packages = with pkgs; [
      yazi
      ueberzugpp # image preview on X11 canvas (st has no kitty/sixel)
      chafa # image preview fallback (semi-graphics mode, no DISPLAY)
      zip # archive backend for yazi compress plugin
      unzip # archive backend for yazi compress plugin
      lz4 # archive backend for yazi compress plugin (tar.lz4)
    ];

    # Desktop entry: yazi opens in an st terminal (overrides the packaged
    # Terminal=true yazi.desktop).
    xdg.desktopEntries.yazi = {
      name = "Yazi File Manager";
      exec = "st -e yazi %F";
      terminal = false;
    };

    # compress.yazi plugin: create archives right from yazi (select files, `c a`).
    xdg.configFile."yazi/plugins/compress.yazi/main.lua".source = "${compressPlugin}/main.lua";
    # Prepend `c a` … compression keybindings to the default keymap.
    xdg.configFile."yazi/keymap.toml".text = ''
      [mgr]
      prepend_keymap = [
        { on = [ "c", "a", "a" ], run = "plugin compress", desc = "Archive selected files" },
        { on = [ "c", "a", "p" ], run = "plugin compress -p", desc = "Archive selected files (password)" },
        { on = [ "c", "a", "h" ], run = "plugin compress -ph", desc = "Archive selected files (password+header)" },
        { on = [ "c", "a", "l" ], run = "plugin compress -l", desc = "Archive selected files (compression level)" },
        { on = [ "c", "a", "u" ], run = "plugin compress -phl", desc = "Archive selected files (password+header+level)" },
      ]
    '';

    xdg.mimeApps.defaultApplications = {
      # Archives → yazi (file manager)
      "application/zip" = ["yazi.desktop"];
      "application/x-zip-compressed" = ["yazi.desktop"];
      "application/gzip" = ["yazi.desktop"];
      "application/x-gzip" = ["yazi.desktop"];
      "application/x-tar" = ["yazi.desktop"];
      "application/x-compressed-tar" = ["yazi.desktop"];
      "application/x-bzip" = ["yazi.desktop"];
      "application/x-bzip2" = ["yazi.desktop"];
      "application/x-xz" = ["yazi.desktop"];
      "application/x-7z-compressed" = ["yazi.desktop"];
      "application/x-rar" = ["yazi.desktop"];
      "application/vnd.rar" = ["yazi.desktop"];
      "application/x-zstd" = ["yazi.desktop"];
      "application/zstd" = ["yazi.desktop"];
      "application/x-cpio" = ["yazi.desktop"];
      "application/x-deb" = ["yazi.desktop"];
    };
  };
}
