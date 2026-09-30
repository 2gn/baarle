{
  description = "Just a bunch of packages";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";

    crane.url = "github:ipetkov/crane";

    dnsglobe = {
      url = "github:514-labs/dnsglobe";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    concord = {
      url = "github:chojs23/concord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pwndbg = {
      url = "github:pwndbg/pwndbg";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    diskwatch = {
      url = "github:matthart1983/diskwatch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vortix = {
      url = "github:Harry-kp/vortix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mandible = {
      url = "github:AS-FOSS/mandible";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

      # Re-export the default package of every input under the input's own name,
      # so `nix build .#vortix` works for anything already vendored here.
      # Inputs without a `default` package for the given system (nixpkgs, crane,
      # treefmt-nix, non-flake inputs, ...) are skipped instead of erroring.
      packagesFromInputs =
        system:
        let
          mapped = lib.mapAttrs (_name: input: (input.packages or { }).${system}.default or null) (
            builtins.removeAttrs inputs [ "self" ]
          );
        in
        lib.filterAttrs (_: v: v != null) mapped;

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
      packages = forAllSystems (
        { pkgs, system, ... }:
        # `packages/` wins on name clashes with an input.
        lib.mergeAttrs (packagesFromInputs system) (packagesFromPkgsDir pkgs)
      );
      # The system is read from `prev`, not `final`: `final` already includes this
      # overlay, so touching it while building the overlay's result would recurse.
      overlays.default =
        final: prev:
        lib.mergeAttrs (packagesFromInputs prev.stdenv.hostPlatform.system) (packagesFromPkgsDir final);

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
