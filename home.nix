{ config, pkgs, ... }:

let
  # Compress plugin for yazi: creates archives from selected files (`c a`).
  # Only main.lua is needed; the entry lives in ~/.config/yazi/plugins.
  compressPlugin = pkgs.fetchFromGitHub {
    owner = "KKV9";
    repo = "compress.yazi";
    rev = "80e5268ec74c7ac17d4d739e13a9958cba4c70d3";
    hash = "sha256-9cdA8D/TtwHcLqrtoyIixA0YJmTs+c8FSNrjxp8CYI0=";
  };
in
{
  home.username = "itah";
  home.homeDirectory = "/home/itah";

  home.stateVersion = "26.05";

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

  # Programs spawned by the default oxwm keybindings (Super+Return / Super+D).
  home.packages = with pkgs; [
    (st.overrideAttrs (old: {
      # JetBrains Mono Nerd Font at size 11 (inlined; see fonts.packages below).
      patches = (old.patches or [ ]) ++ [
        (pkgs.writeText "st-font.patch" ''
          diff --git a/config.def.h b/config.def.h
          index 1111111..2222222 100644
          --- a/config.def.h
          +++ b/config.def.h
          @@ -7,2 +7,2 @@
           */
          -static char *font = "Liberation Mono:pixelsize=12:antialias=true:autohint=true";
          +static char *font = "JetBrainsMono Nerd Font:size=11:antialias=true:autohint=true";
        '')
        (pkgs.writeText "st-shift-enter.patch" ''
          diff --git a/config.def.h b/config.def.h
          index 1111111..2222222 100644
          --- a/config.def.h
          +++ b/config.def.h
          @@ -336,4 +336,5 @@
          	{ XK_ISO_Left_Tab,  ShiftMask,      "\033[Z",        0,    0},
          	{ XK_Return,        Mod1Mask,       "\033\r",        0,    0},
          +	{ XK_Return,        ShiftMask,      "\033[13;2u",    0,    0},
          	{ XK_Return,        XK_ANY_MOD,     "\r",            0,    0},
          	{ XK_Insert,        ShiftMask,      "\033[4l",      -1,    0},
        '')
      ];
    }))
    dmenu
    feh # wallpaper setter
    brave-origin # browser
    yazi # terminal file manager
    ueberzugpp # image preview for yazi (X11 canvas; st has no kitty/sixel)
    chafa # image preview fallback for yazi (semi-graphics mode, no DISPLAY)
    zip # archive backend for yazi compress plugin
    unzip # archive backend for yazi compress plugin
    lz4 # archive backend for yazi compress plugin (tar.lz4)
    localsend # LAN file sharing
    libreoffice # office suite
    zathura # PDF viewer (bundles mupdf/poppler plugins)
    brightnessctl # backlight control (Fn keys)
    pamixer # volume control (Fn keys)
    playerctl # media keys
    upower # battery status
    pciutils
    usbutils
    sxhkd # X hotkey daemon for Fn/media keys
    android-tools # adb/fastboot for phones
    mpv # video player
    imv # image viewer
    btop # system monitor
    fastfetch # system info
    scrot # screenshot
    git # version control for /etc/nixos and projects
    obs-studio # screen recording/streaming
    clipmenu # clipboard history daemon + dmenu picker (st paste)
    xsel
    dunst # notification daemon (auto-upgrade, GC, git-sync alerts)
    libnotify # notify-send, used by the systemd notify hooks
  ];

  # System-wide file associations. Home Manager writes ~/.config/mimeapps.list,
  # so xdg-open, yazi, and anything else that opens files all use the same apps.
  xdg = {
    enable = true;
    mimeApps.enable = true;

    # Desktop entries for apps that ship none or need a terminal: nvim and yazi
    # open in an st terminal (overrides the packaged Terminal=true yazi.desktop).
    desktopEntries.nvim = {
      name = "Neovim";
      exec = "st -e nvim %F";
      terminal = false;
      noDisplay = true;
    };
    desktopEntries.yazi = {
      name = "Yazi File Manager";
      exec = "st -e yazi %F";
      terminal = false;
    };

    # compress.yazi plugin: create archives right from yazi (select files, `c a`).
    configFile."yazi/plugins/compress.yazi/main.lua".source = "${compressPlugin}/main.lua";
    # Prepend `c a` … compression keybindings to the default keymap.
    configFile."yazi/keymap.toml".text = ''
      [mgr]
      prepend_keymap = [
        { on = [ "c", "a", "a" ], run = "plugin compress", desc = "Archive selected files" },
        { on = [ "c", "a", "p" ], run = "plugin compress -p", desc = "Archive selected files (password)" },
        { on = [ "c", "a", "h" ], run = "plugin compress -ph", desc = "Archive selected files (password+header)" },
        { on = [ "c", "a", "l" ], run = "plugin compress -l", desc = "Archive selected files (compression level)" },
        { on = [ "c", "a", "u" ], run = "plugin compress -phl", desc = "Archive selected files (password+header+level)" },
      ]
    '';

    mimeApps.defaultApplications = {
      # Web / URLs → Brave
      "text/html" = [ "brave-origin.desktop" ];
      "application/xhtml+xml" = [ "brave-origin.desktop" ];
      "x-scheme-handler/http" = [ "brave-origin.desktop" ];
      "x-scheme-handler/https" = [ "brave-origin.desktop" ];
      "x-scheme-handler/about" = [ "brave-origin.desktop" ];
      "x-scheme-handler/unknown" = [ "brave-origin.desktop" ];

      # Images → imv
      "image/bmp" = [ "imv.desktop" ];
      "image/gif" = [ "imv.desktop" ];
      "image/jpeg" = [ "imv.desktop" ];
      "image/png" = [ "imv.desktop" ];
      "image/tiff" = [ "imv.desktop" ];
      "image/webp" = [ "imv.desktop" ];
      "image/svg+xml" = [ "imv.desktop" ];
      "image/avif" = [ "imv.desktop" ];
      "image/heic" = [ "imv.desktop" ];
      "image/heif" = [ "imv.desktop" ];
      "image/x-tga" = [ "imv.desktop" ];
      "image/x-portable-bitmap" = [ "imv.desktop" ];
      "image/x-portable-graymap" = [ "imv.desktop" ];
      "image/x-portable-pixmap" = [ "imv.desktop" ];

      # Video → mpv
      "video/mp4" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];
      "video/quicktime" = [ "mpv.desktop" ];
      "video/ogg" = [ "mpv.desktop" ];
      "video/x-msvideo" = [ "mpv.desktop" ];
      "video/x-flv" = [ "mpv.desktop" ];
      "video/mpeg" = [ "mpv.desktop" ];
      "video/x-m4v" = [ "mpv.desktop" ];
      "video/mp2t" = [ "mpv.desktop" ];
      "video/3gpp" = [ "mpv.desktop" ];
      "video/x-ms-wmv" = [ "mpv.desktop" ];
      "application/vnd.apple.mpegurl" = [ "mpv.desktop" ];
      "application/x-mpegurl" = [ "mpv.desktop" ];

      # Audio → mpv
      "audio/mpeg" = [ "mpv.desktop" ];
      "audio/mp4" = [ "mpv.desktop" ];
      "audio/x-m4a" = [ "mpv.desktop" ];
      "audio/aac" = [ "mpv.desktop" ];
      "audio/ogg" = [ "mpv.desktop" ];
      "audio/opus" = [ "mpv.desktop" ];
      "audio/vorbis" = [ "mpv.desktop" ];
      "audio/x-vorbis+ogg" = [ "mpv.desktop" ];
      "audio/flac" = [ "mpv.desktop" ];
      "audio/x-flac" = [ "mpv.desktop" ];
      "audio/wav" = [ "mpv.desktop" ];
      "audio/x-wav" = [ "mpv.desktop" ];
      "audio/x-aiff" = [ "mpv.desktop" ];
      "audio/midi" = [ "mpv.desktop" ];
      "audio/x-midi" = [ "mpv.desktop" ];
      "audio/x-matroska" = [ "mpv.desktop" ];
      "audio/webm" = [ "mpv.desktop" ];
      "audio/3gpp" = [ "mpv.desktop" ];

      # Documents → zathura
      "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
      "image/vnd.djvu" = [ "org.pwmt.zathura-djvu.desktop" ];
      "application/x-cbz" = [ "org.pwmt.zathura-cb.desktop" ];
      "application/postscript" = [ "org.pwmt.zathura-ps.desktop" ];
      "image/x-eps" = [ "org.pwmt.zathura-ps.desktop" ];

      # Word processing → LibreOffice Writer
      "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
      "application/vnd.oasis.opendocument.text-template" = [ "writer.desktop" ];
      "application/msword" = [ "writer.desktop" ];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
      "application/rtf" = [ "writer.desktop" ];
      "text/rtf" = [ "writer.desktop" ];

      # Spreadsheets → LibreOffice Calc
      "application/vnd.ms-excel" = [ "calc.desktop" ];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ];
      "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
      "application/vnd.oasis.opendocument.spreadsheet-template" = [ "calc.desktop" ];
      "text/csv" = [ "calc.desktop" ];

      # Presentations → LibreOffice Impress
      "application/vnd.ms-powerpoint" = [ "impress.desktop" ];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "impress.desktop" ];
      "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ];
      "application/vnd.oasis.opendocument.presentation-template" = [ "impress.desktop" ];

      # Text / source code → nvim (in st)
      "text/plain" = [ "nvim.desktop" ];
      "text/x-shellscript" = [ "nvim.desktop" ];
      "text/markdown" = [ "nvim.desktop" ];
      "text/x-markdown" = [ "nvim.desktop" ];
      "text/x-c" = [ "nvim.desktop" ];
      "text/x-csrc" = [ "nvim.desktop" ];
      "text/x-chdr" = [ "nvim.desktop" ];
      "text/x-c++src" = [ "nvim.desktop" ];
      "text/x-c++hdr" = [ "nvim.desktop" ];
      "text/x-python" = [ "nvim.desktop" ];
      "text/x-ruby" = [ "nvim.desktop" ];
      "text/x-perl" = [ "nvim.desktop" ];
      "text/x-java" = [ "nvim.desktop" ];
      "text/x-php" = [ "nvim.desktop" ];
      "text/x-rust" = [ "nvim.desktop" ];
      "text/x-go" = [ "nvim.desktop" ];
      "text/x-lisp" = [ "nvim.desktop" ];
      "text/x-scheme" = [ "nvim.desktop" ];
      "text/x-haskell" = [ "nvim.desktop" ];
      "text/x-lua" = [ "nvim.desktop" ];
      "text/x-tcl" = [ "nvim.desktop" ];
      "text/x-asm" = [ "nvim.desktop" ];
      "text/x-makefile" = [ "nvim.desktop" ];
      "application/x-makefile" = [ "nvim.desktop" ];
      "text/x-cmake" = [ "nvim.desktop" ];
      "text/x-json" = [ "nvim.desktop" ];
      "application/json" = [ "nvim.desktop" ];
      "text/x-yaml" = [ "nvim.desktop" ];
      "text/yaml" = [ "nvim.desktop" ];
      "text/xml" = [ "nvim.desktop" ];
      "application/xml" = [ "nvim.desktop" ];
      "text/x-sql" = [ "nvim.desktop" ];
      "text/x-diff" = [ "nvim.desktop" ];
      "text/x-patch" = [ "nvim.desktop" ];
      "text/x-vim" = [ "nvim.desktop" ];
      "text/x-tex" = [ "nvim.desktop" ];
      "text/x-nix" = [ "nvim.desktop" ];
      "application/x-nix" = [ "nvim.desktop" ];
      "text/x-dockerfile" = [ "nvim.desktop" ];
      "text/css" = [ "nvim.desktop" ];
      "text/x-javascript" = [ "nvim.desktop" ];
      "text/javascript" = [ "nvim.desktop" ];
      "application/javascript" = [ "nvim.desktop" ];

      # Archives → yazi (file manager)
      "application/zip" = [ "yazi.desktop" ];
      "application/x-zip-compressed" = [ "yazi.desktop" ];
      "application/gzip" = [ "yazi.desktop" ];
      "application/x-gzip" = [ "yazi.desktop" ];
      "application/x-tar" = [ "yazi.desktop" ];
      "application/x-compressed-tar" = [ "yazi.desktop" ];
      "application/x-bzip" = [ "yazi.desktop" ];
      "application/x-bzip2" = [ "yazi.desktop" ];
      "application/x-xz" = [ "yazi.desktop" ];
      "application/x-7z-compressed" = [ "yazi.desktop" ];
      "application/x-rar" = [ "yazi.desktop" ];
      "application/vnd.rar" = [ "yazi.desktop" ];
      "application/x-zstd" = [ "yazi.desktop" ];
      "application/zstd" = [ "yazi.desktop" ];
      "application/x-cpio" = [ "yazi.desktop" ];
      "application/x-deb" = [ "yazi.desktop" ];
    };
  };

  # Fallback for tools that consult $BROWSER instead of the mime database.
  home.sessionVariables.BROWSER = "brave-origin";

  programs.bash = {
    enable = true;
    shellAliases = {
      # Rebuild & test
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      nrt = "sudo nixos-rebuild test --flake /etc/nixos#nixos";
      nbo = "sudo nixos-rebuild boot --flake /etc/nixos#nixos";

      # Edit config
      ne = "$EDITOR /etc/nixos/configuration.nix";
      nh = "$EDITOR /etc/nixos/home.nix";
      nf = "$EDITOR /etc/nixos/flake.nix";

      # Format
      nfmt = "nixfmt /etc/nixos/flake.nix /etc/nixos/configuration.nix /etc/nixos/home.nix";
      nfmtc = "nixfmt --check /etc/nixos/flake.nix /etc/nixos/configuration.nix /etc/nixos/home.nix";

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

  # oxwm window-manager config (bindings, bar, autostart). Lives as a real file
  # in the repo (dotfiles/oxwm/config.lua) since oxwm reads it at startup and
  # on Mod+Shift+R; home-manager symlinks it into ~/.config/oxwm. force: the
  # file predates home-manager, so the plain file must be replaced once.
  xdg.configFile."oxwm/config.lua" = {
    source = ./dotfiles/oxwm/config.lua;
    force = true;
  };

  # Notification daemon config (launched in .xinitrc). Tuned for this machine:
  # monospace nerd font, progress bars, click-to-activate, and a rule that
  # keeps the nixos-upgrade systemd hooks (notify-itah) on screen long enough.
  xdg.configFile."dunst/dunstrc".text = ''
    [global]
        monitor = 0
        follow = mouse
        geometry = "310x-30+12+12"
        notification_limit = 6
        progress_bar = true
        progress_bar_height = 6
        progress_bar_frame_width = 0
        progress_bar_min_width = 150
        progress_bar_max_width = 300
        icon_position = left
        min_icon_size = 48
        max_icon_size = 64
        enable_recursive_icon_lookup = true
        stack_duplicates = true
        hide_duplicate_count = false
        show_age_threshold = 60
        history_length = 30
        font = "JetBrainsMono Nerd Font 10"
        line_height = 0
        markup = full
        format = "<i>%a</i>\n<b>%s</b>\n%b"
        alignment = left
        word_wrap = true
        ellipsize = middle
        ignore_newline = false
        show_indicators = true
        indicate_hidden = true
        idle_threshold = 10
        browser = brave-origin
        separator_color = frame
        separator_height = 2
        frame_width = 2
        padding = 6
        horizontal_padding = 8
        text_icon_padding = 8
        mouse_left_click = do_action
        mouse_middle_click = close_current
        mouse_right_click = close_all

    # Gruvbox dark palette.
    [urgency_low]
        background = "#282828"
        foreground = "#ebdbb2"
        frame_color = "#928374"
        highlight = "#a89984"
        timeout = 6

    [urgency_normal]
        background = "#282828"
        foreground = "#ebdbb2"
        frame_color = "#83a598"
        highlight = "#d79921"
        timeout = 10

    [urgency_critical]
        background = "#282828"
        foreground = "#ebdbb2"
        frame_color = "#fb4934"
        highlight = "#fe8019"
        timeout = 0

    # NixOS auto-upgrade hooks (notify-itah in configuration.nix). Longer
    # timeout so start/finish of a slow upgrade isn't missed.
    [nixos-upgrade]
        appname = "nixos-upgrade"
        urgency = normal
        timeout = 30

    # Web notifications from Brave (Discord, mail, ...). Keep them visible a
    # while, but let them group so the corner doesn't fill up.
    [brave]
        appname = "Brave*"
        urgency = normal
        timeout = 8

    # OSD popups from the volume/brightness Fn keys (see sxhkdrc). Transient
    # and short so they never pile up or linger in history.
    [volume]
        appname = "volume"
        timeout = 2
        set_transient = true

    [mic]
        appname = "mic"
        timeout = 2
        set_transient = true

    [brightness]
        appname = "brightness"
        timeout = 2
        set_transient = true

    # Screenshots (oxwm Super+S). Normal (non-transient) so it stays until
    # closed; left-click opens the saved image in imv (see config.lua).
    [screenshot]
        appname = "screenshot"
        timeout = 5

    # Clipmenu paste (oxwm Super+V): transient preview of what was copied.
    [clipmenu]
        appname = "clipmenu"
        timeout = 3
        set_transient = true
  '';

  # Fn (brightness/volume), media, and mic bindings for the laptop. Volume,
  # brightness, and mic changes show a transient dunst OSD with a progress bar
  # (matched by the [volume]/[brightness]/[mic] rules in dunstrc). OSDs use
  # dunstify with a fixed replace id so rapid/held keypresses update the single
  # live popup instead of spamming new ones.
  #
  # NOTE: sxhkd joins every line of a multi-line command with ';', so shell
  # backslash continuations are NOT possible here — keep each command on one
  # line, or the trailing '\' mangles the next statement.
  xdg.configFile."sxhkd/sxhkdrc".text = ''
    # Brightness
    XF86MonBrightnessUp
        brightnessctl set +5%
        b=$(( $(brightnessctl get) * 100 / $(brightnessctl max) ))
        dunstify -a brightness -r 3001 -u low -h int:value:$b "Brightness"
    XF86MonBrightnessDown
        brightnessctl set 5%-
        b=$(( $(brightnessctl get) * 100 / $(brightnessctl max) ))
        dunstify -a brightness -r 3001 -u low -h int:value:$b "Brightness"

    # Volume
    XF86AudioRaiseVolume
        pamixer --increase 5
        dunstify -a volume -r 3000 -u low -h int:value:$(pamixer --get-volume) "Volume $(pamixer --get-volume)%"
    XF86AudioLowerVolume
        pamixer --decrease 5
        dunstify -a volume -r 3000 -u low -h int:value:$(pamixer --get-volume) "Volume $(pamixer --get-volume)%"
    XF86AudioMute
        pamixer --toggle-mute
        if [ "$(pamixer --get-mute)" = "true" ]; then dunstify -a volume -r 3000 -u low "Volume" "Muted"; else dunstify -a volume -r 3000 -u low -h int:value:$(pamixer --get-volume) "Volume $(pamixer --get-volume)%"; fi

    # Media
    XF86AudioPlay
        playerctl play-pause
    XF86AudioNext
        playerctl next
    XF86AudioPrev
        playerctl previous

    # App launchers (Super+Shift+<key>; oxwm owns plain Super+<key>)
    super+shift+b
        brave-origin
    super+shift+e
        st -e yazi
    super+shift+a
        st -e opencode
    super+shift+s
        localsend
    super+shift+l
        libreoffice
    super+shift+o
        obs

    # Mic mute
    super+m
        pamixer --default-source --toggle-mute
        if [ "$(pamixer --default-source --get-mute)" = "true" ]; then dunstify -a mic -r 3002 -u low "Mic" "Muted"; else dunstify -a mic -r 3002 -u low "Mic" "Unmuted"; fi
  '';
}
