# Formatter for `nix fmt`: Alejandra, the uncompromising Nix code formatter.
# Uses the nixpkgs-packaged alejandra (no extra flake inputs needed).
# Registered via perSystem so flake-parts exposes `formatter.<system>`.
{inputs, ...}: {
  perSystem = {system, ...}: {
    formatter = inputs.nixpkgs.legacyPackages.${system}.alejandra;
  };
}
