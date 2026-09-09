# oxwm — dynamic window manager (also the desktop). Multi-context aspect:
# system side enables the WM, user side ships the config (config.lua).
{lib, ...}: {
  flake.modules.nixos.oxwm = {lib, ...}: {
    services.xserver.windowManager.oxwm.enable = true;
  };

  flake.modules.homeManager.oxwm = {lib, ...}: {
    # Lives as a real file in the repo (dotfiles/oxwm/config.lua) since oxwm
    # reads it at startup and on Mod+Shift+R; home-manager symlinks it into
    # ~/.config/oxwm. force: the file predates home-manager, so the plain file
    # must be replaced once.
    xdg.configFile."oxwm/config.lua" = {
      source = ../../../dotfiles/oxwm/config.lua;
      force = true;
    };
  };
}
