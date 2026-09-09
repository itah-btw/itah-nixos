# st — terminal emulator spawned by the oxwm defaults (Super+Return / Super+D).
# Patched: JetBrains Mono Nerd Font and a Shift+Enter escape binding.
{lib, ...}: {
  flake.modules.homeManager.st = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = [
      (pkgs.st.overrideAttrs (old: {
        # JetBrains Mono Nerd Font at size 11 (inlined; see locale.nix).
        patches =
          (old.patches or [])
          ++ [
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
    ];
  };
}
