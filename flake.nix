{
  description = "Provides Gitbutler binary distributions for Nix.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          inherit (pkgs) callPackage;
        in
        {
          default = self.packages.${system}.gitbutler;
          gitbutler = callPackage ./gitbutler.nix { };
          gitbutler-appimage = callPackage ./gitbutler-appimage.nix { };
        }
      );
    };
}
