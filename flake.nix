{
  description = "Just a bunch of packages";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";

    crane.url = "github:ipetkov/crane";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-update-soopy = {
      url = "github:soopyc/nix-update";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      crane,
      treefmt-nix,
      nix-update-soopy,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems =
        fn:
        nixpkgs.lib.genAttrs systems (
          system:
          fn {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );

      treefmtEval = forAllSystems ({ pkgs, ... }: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      # Auto-discover every `packages/<name>/package.nix` and build it with
      # `craneLib` in scope, which the crane-based packages require.
      #
      # `lib` is deliberately taken from the nixpkgs input rather than from
      # `pkgs`: when used as an overlay, `pkgs` is `final`, and resolving
      # `final.lib` would force the overlay's own result and recurse forever.
      packagesFromPkgsDir =
        pkgs:
        let
          craneLib = crane.mkLib pkgs;
        in
        lib.filesystem.packagesFromDirectoryRecursive {
          callPackage = lib.callPackageWith (pkgs // { inherit craneLib; });
          directory = ./packages;
        };
    in
    {
      packages = forAllSystems ({ pkgs, ... }: packagesFromPkgsDir pkgs);
      overlays.default = final: _prev: packagesFromPkgsDir final;

      formatter = forAllSystems ({ system, ... }: treefmtEval.${system}.config.build.wrapper);
      checks = forAllSystems (
        { system, ... }:
        {
          formatting = treefmtEval.${system}.config.build.check self;
        }
      );

      devShells = forAllSystems (
        { pkgs, system }:
        {
          default = pkgs.mkShellNoCC {
            packages = [
              nix-update-soopy.packages.${system}.default

              pkgs.nvfetcher
              pkgs.nix-fast-build
              pkgs.ratchet
            ];
          };
        }
      );

      # nixosModules = {
      # };

      # nixosTests = forAllSystems (
      #   { pkgs, ... }:
      #   {}
      # );
    };
}
