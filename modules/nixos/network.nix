# Networking: hostname, NM, firewall.
{lib, ...}: {
  flake.modules.nixos.network = {lib, ...}: {
    networking.hostName = "nixos";
    networking.networkmanager.enable = true;
    # Proton VPN needs asymmetric/split routing for the tunnel.
    networking.firewall.checkReversePath = false;
  };
}
