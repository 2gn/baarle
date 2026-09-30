{ pkgs, craneLib }:
let
  # Load the automatically generated hashes

  sources = pkgs.callPackage ../../_sources/generated.nix { };

  inherit (sources.wstui) pname version src;
  commonArgs = {
    inherit pname version;

    src = pkgs.lib.cleanSourceWith {
      src = src;
      filter =
        path: type:
        craneLib.filterCargoSources path type
        || pkgs.lib.any (suffix: pkgs.lib.hasSuffix suffix (baseNameOf path)) [
          ".go"
          ".mod"
          ".sum"
        ];
    };

    preBuild = ''
      export GOPATH=$TMPDIR/go
      export GOCACHE=$TMPDIR/go-cache
      export GOMODCACHE=$TMPDIR/go/pkg/mod
    '';

    nativeBuildInputs = with pkgs; [
      pkg-config
      wayland
      chafa
      glib.dev
      go
    ];
    buildInputs = [
      pkgs.openssl
    ];
  };

  cargoArtifacts = craneLib.buildDepsOnly commonArgs;

  # Vendor the Go modules used by the whatsrust build script as a FOD
  # (fixed-output derivation, so it may reach the network even under the
  # sandbox). buildGoModule in nixpkgs uses the same pattern.
  whatsrustVendor = pkgs.stdenv.mkDerivation {
    name = "wstui-whatsrust-vendor";
    inherit version;

    src = pkgs.runCommand "wstui-whatsrust-src" { } ''
      mkdir -p $out
      cp -r ${src}/whatsrust $out/
    '';

    nativeBuildInputs = [ pkgs.go ];

    phases = [
      "unpackPhase"
      "patchPhase"
      "buildPhase"
      "installPhase"
    ];

    buildPhase = ''
      runHook preBuild
      export GOCACHE=$TMPDIR/go-cache
      export GOPATH=$TMPDIR/go
      export GOMODCACHE=$TMPDIR/go/pkg/mod
      ( cd whatsrust/lib && go mod vendor )
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r --reflink=auto whatsrust/lib/vendor $out
      runHook postInstall
    '';

    dontFixup = true;
    outputHashMode = "recursive";
    outputHash = "sha256-IhIFsXaPpgflfl9Si/dHDGb05vpelyLqPcghEIsdgx4=";
  };
in
craneLib.buildPackage (
  commonArgs
  // {
    inherit cargoArtifacts;
    preBuild = commonArgs.preBuild + ''

      cp -rT ${whatsrustVendor} whatsrust/lib/vendor
      export GOFLAGS=-mod=vendor
    '';
    # No more manual SHA hashes!
  }
)
