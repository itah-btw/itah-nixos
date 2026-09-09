# Security policy: unfree packages and polkit rules.
{lib, ...}: {
  flake.modules.nixos.security = {lib, ...}: {
    nixpkgs.config.allowUnfree = true;

    # Polkit rules: proton VPN + fingerprint sensor management.
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.policykit.exec"
            && action.lookup("program") != null
            && action.lookup("program").indexOf("proton") !== -1
            && subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
      polkit.addRule(function(action, subject) {
        if (action.id.indexOf("net.reactivated.fprint") === 0
            && subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
